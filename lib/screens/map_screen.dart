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
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permission denied.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permission permanently denied. Please enable it in settings.';
          _isLoading = false;
        });
        return;
      }

      await _getCurrentLocation();
    } catch (e) {
      setState(() {
        _error = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      setState(() {
        _currentPosition = position;
        _error = null;
      });

      await _searchNearbyHospitals();

      if (_mapController != null) {
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
      setState(() {
        _error = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchNearbyHospitals() async {
    if (_currentPosition == null) return;

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
        'location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
        '&radius=5000'
        '&type=hospital'
        '&language=en'
        '&key=$_apiKey'
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final List<dynamic> results = data['results'];
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
              'name': place['name'],
              'address': place['vicinity'],
              'distance': distance,
              'rating': place['rating']?.toString() ?? 'N/A',
              'lat': lat,
              'lng': lng,
              'place_id': place['place_id'],
            };
          }).toList();

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
                  infoWindow: const InfoWindow(title: 'Current Location'),
                ),
              );
            }

            _error = null;
            _isLoading = false;
          });
        } else {
          throw Exception('Places API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching hospital information: $e';
        _isLoading = false;
      });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Nearby Hospitals'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
                _showHospitalDetails = false;
              });
              _initializeLocation();
            },
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _error = null;
                        });
                        _initializeLocation();
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  flex: 4,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              _currentPosition?.latitude ?? 37.5665,
                              _currentPosition?.longitude ?? 126.9780,
                            ),
                            zoom: 14,
                          ),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: true,
                          markers: _markers,
                          onMapCreated: (controller) {
                            _mapController = controller;
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