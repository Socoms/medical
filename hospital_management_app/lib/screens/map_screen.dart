import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _hospitals = [];
  Set<Marker> _markers = {};
  final String _apiKey = 'AIzaSyBPXXLHl6SIJwocTbTyVbUePcy3Kv2UO1U';
  Map<String, dynamic>? _selectedHospital;
  bool _showHospitalDetails = false;

  @override
  void initState() {
    super.initState();
    print('MapScreen initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  Future<void> _initializeLocation() async {
    print('위치 초기화 시작');
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('위치 서비스 상태: $serviceEnabled');
      
      if (!serviceEnabled) {
        setState(() {
          _error = '위치 서비스가 비활성화되어 있습니다.\n설정에서 위치 서비스를 활성화해주세요.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print('현재 위치 권한 상태: $permission');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('위치 권한 요청 결과: $permission');
        
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = '위치 권한이 거부되었습니다.\n앱 설정에서 위치 권한을 허용해주세요.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = '위치 권한이 영구적으로 거부되었습니다.\n앱 설정에서 위치 권한을 허용해주세요.';
          _isLoading = false;
        });
        return;
      }

      await _getCurrentLocation();
    } catch (e) {
      print('위치 초기화 오류: $e');
      setState(() {
        _error = '위치 정보를 가져오는데 실패했습니다.\n다시 시도해주세요.';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () async {
          // 타임아웃 시 마지막 알려진 위치 시도
          try {
            final lastPosition = await Geolocator.getLastKnownPosition();
            if (lastPosition != null) {
              return lastPosition;
            }
            throw Exception('위치 정보를 가져올 수 없습니다.');
          } catch (e) {
            throw Exception('위치 정보를 가져올 수 없습니다.');
          }
        },
      );

      setState(() {
        _currentPosition = position;
        _error = null;
      });

      // 병원 검색은 위치 정보를 성공적으로 가져온 후에 실행
      if (mounted) {
        await _searchNearbyHospitals();
      }

      if (_mapController != null && mounted) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '위치 정보를 가져오는데 실패했습니다.\n다시 시도해주세요.';
          _isLoading = false;
        });
        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('위치 정보 오류: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _searchNearbyHospitals() async {
    if (_currentPosition == null) return;

    try {
      print('병원 검색 시작 - 위치: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
        'location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
        '&radius=5000'
        '&type=hospital'
        '&language=ko'
        '&key=$_apiKey'
      );

      print('API 요청 URL: $url');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('병원 정보를 가져오는데 시간이 너무 오래 걸립니다.');
        },
      );

      print('API 응답 상태 코드: ${response.statusCode}');
      print('API 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final List<dynamic> results = data['results'];
          print('검색된 병원 수: ${results.length}');

          if (results.isEmpty) {
            setState(() {
              _error = '주변에 병원이 없습니다.';
              _isLoading = false;
            });
            return;
          }

          final hospitals = results.map((place) {
            final location = place['geometry']['location'];
            final lat = location['lat'] as double;
            final lng = location['lng'] as double;
            
            double distanceInMeters = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              lat,
              lng,
            );
            
            String distance = distanceInMeters > 1000
                ? '${(distanceInMeters / 1000).toStringAsFixed(1)}km'
                : '${distanceInMeters.toStringAsFixed(0)}m';

            return {
              'name': place['name'] ?? '이름 없음',
              'address': place['vicinity'] ?? '주소 없음',
              'distance': distance,
              'rating': place['rating']?.toString() ?? 'N/A',
              'lat': lat,
              'lng': lng,
              'place_id': place['place_id'] ?? '',
            };
          }).toList();

          if (mounted) {
            setState(() {
              _hospitals = hospitals;
              _hospitals.sort((a, b) {
                final aDistance = double.parse(a['distance'].replaceAll(RegExp(r'[^0-9.]'), ''));
                final bDistance = double.parse(b['distance'].replaceAll(RegExp(r'[^0-9.]'), ''));
                return aDistance.compareTo(bDistance);
              });

              _markers = _hospitals.map((hospital) {
                return Marker(
                  markerId: MarkerId(hospital['name']),
                  position: LatLng(hospital['lat'], hospital['lng']),
                  infoWindow: InfoWindow(
                    title: hospital['name'],
                    snippet: '${hospital['distance']} • ${hospital['rating']}★',
                  ),
                  onTap: () {
                    _onHospitalSelected(hospital);
                  },
                );
              }).toSet();

              if (_currentPosition != null) {
                _markers.add(
                  Marker(
                    markerId: const MarkerId('current_location'),
                    position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                    infoWindow: const InfoWindow(title: '현재 위치'),
                  ),
                );
              }

              _error = null;
              _isLoading = false;
            });
          }
        } else if (data['status'] == 'ZERO_RESULTS') {
          setState(() {
            _error = '주변에 병원이 없습니다.';
            _isLoading = false;
          });
        } else if (data['status'] == 'OVER_QUERY_LIMIT') {
          setState(() {
            _error = 'API 호출 한도를 초과했습니다. 잠시 후 다시 시도해주세요.';
            _isLoading = false;
          });
        } else if (data['status'] == 'REQUEST_DENIED') {
          setState(() {
            _error = 'API 키가 유효하지 않습니다.';
            _isLoading = false;
          });
        } else {
          throw Exception('Places API 오류: ${data['status']} - ${data['error_message'] ?? '알 수 없는 오류'}');
        }
      } else {
        throw Exception('HTTP 오류: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('병원 검색 오류: $e');
      if (mounted) {
        setState(() {
          _error = '병원 정보를 가져오는데 실패했습니다.\n다시 시도해주세요.';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('병원 정보 오류: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _fetchHospitalDetails(String placeId) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?'
        'place_id=$placeId'
        '&fields=name,formatted_address,opening_hours,types'
        '&language=en'
        '&key=$_apiKey'
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          setState(() {
            if (_selectedHospital != null) {
              _selectedHospital!['opening_hours'] = result['opening_hours']?['weekday_text'] ?? [];
              _selectedHospital!['is_open'] = result['opening_hours']?['open_now'] ?? false;
              _selectedHospital!['types'] = result['types'] ?? [];
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching hospital details: $e');
    }
  }

  Widget _buildHospitalDetails() {
    if (_selectedHospital == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _showHospitalDetails = false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    _selectedHospital!['name'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedHospital!['address'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Rating: ${_selectedHospital!['rating']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.directions, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Distance: ${_selectedHospital!['distance']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _selectedHospital!['is_open'] == true ? 'Open Now' : 'Closed',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedHospital!['is_open'] == true ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (_selectedHospital!['opening_hours'] != null) ...[
              const SizedBox(height: 8),
              const Text(
                'Opening Hours:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ...List.generate(
                _selectedHospital!['opening_hours'].length,
                (index) => Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    _selectedHospital!['opening_hours'][index],
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (_selectedHospital!['types'] != null) ...[
              const Text(
                'Medical Departments:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_selectedHospital!['types'] as List<dynamic>)
                    .where((type) => type.toString().startsWith('medical'))
                    .map((type) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type.toString().replaceAll('medical_', '').replaceAll('_', ' '),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.purple,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('MapScreen build - isLoading: $_isLoading, error: $_error, currentPosition: $_currentPosition');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('주변 병원 찾기'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('새로고침 버튼 클릭');
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _initializeLocation();
            },
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      print('다시 시도 버튼 클릭');
                      setState(() {
                        _error = null;
                        _isLoading = true;
                      });
                      _initializeLocation();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시도'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 4,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _currentPosition == null
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '위치 정보를 가져올 수 없습니다.\n위치 권한을 확인해주세요.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                                zoom: 14,
                              ),
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              zoomControlsEnabled: true,
                              markers: _markers,
                              onMapCreated: (controller) {
                                print('지도 생성 완료');
                                setState(() {
                                  _mapController = controller;
                                });
                                try {
                                  controller.setMapStyle('''
                                    [
                                      {
                                        "featureType": "all",
                                        "elementType": "all",
                                        "stylers": [
                                          {
                                            "visibility": "on"
                                          }
                                        ]
                                      }
                                    ]
                                  ''');
                                } catch (e) {
                                  print('지도 스타일 설정 오류: $e');
                                }
                              },
                            ),
                ),
                Expanded(
                  flex: 6,
                  child: _showHospitalDetails
                      ? _buildHospitalDetails()
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, -3),
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _hospitals.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No hospitals found nearby.\nPlease try refreshing.',
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _hospitals.length,
                                      itemBuilder: (context, index) {
                                        final hospital = _hospitals[index];
                                        return ListTile(
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          leading: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.purple.shade50,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.local_hospital,
                                              color: Colors.purple,
                                            ),
                                          ),
                                          title: Text(
                                            hospital['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(hospital['address']),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: Colors.grey,
                                                  ),
                                                  Text(' ${hospital['distance']}'),
                                                  const SizedBox(width: 8),
                                                  if (hospital['rating'] != 'N/A') ...[
                                                    const Icon(
                                                      Icons.star,
                                                      size: 16,
                                                      color: Colors.amber,
                                                    ),
                                                    Text(' ${hospital['rating']}'),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            _onHospitalSelected(hospital);
                                          },
                                        );
                                      },
                                    ),
                        ),
                ),
              ],
            ),
    );
  }

  void _onHospitalSelected(Map<String, dynamic> hospital) {
    setState(() {
      _selectedHospital = hospital;
      _showHospitalDetails = true;
    });
    _fetchHospitalDetails(hospital['place_id']);
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(hospital['lat'], hospital['lng']),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
} 