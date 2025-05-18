import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'map_screen.dart';
import 'pain_area_screen.dart';
import 'ai_medical_screen.dart';
import 'text_medical_screen.dart';
import 'chain_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_management_app/screens/auth/login_screen.dart';
import 'package:hospital_management_app/screens/auth/register_screen.dart';
import 'package:hospital_management_app/screens/translator_screen.dart';
import 'package:hospital_management_app/screens/more_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Position? _currentPosition;
  GoogleMapController? _mapController;
  bool _isLoading = true;
  bool _isMapReady = false;

  final List<Widget> _screens = [
    SizedBox.shrink(),
    const TranslatorScreen(),
    const MoreScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // 위치 서비스가 활성화되어 있는지 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _currentPosition = null;
        });
        // 위치 서비스 활성화 안내 다이얼로그 표시
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('위치 서비스 비활성화'),
              content: const Text('위치 서비스를 활성화해주세요.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _currentPosition = null;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _currentPosition = null;
        });
        // 설정으로 이동하는 다이얼로그 표시
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('위치 권한 필요'),
              content: const Text('앱 설정에서 위치 권한을 허용해주세요.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Geolocator.openAppSettings();
                  },
                  child: const Text('설정으로 이동'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // 위치 정보 가져오기 (타임아웃 증가)
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // 정확도 낮춤
        timeLimit: const Duration(seconds: 15), // 타임아웃 증가
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () async {
          // 타임아웃 시 마지막 알려진 위치 시도
          final lastPosition = await Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            return lastPosition;
          }
          throw Exception('위치 정보를 가져올 수 없습니다.');
        },
      );
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoading = false;
        _currentPosition = null;
      });
      // 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('위치 정보를 가져오는데 실패했습니다: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Medical Korea',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _HomeContent(
              currentPosition: _currentPosition,
              isLoading: _isLoading,
            )
          : _screens[_selectedIndex],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class _HomeContent extends StatelessWidget {
  final Position? currentPosition;
  final bool isLoading;
  const _HomeContent({Key? key, required this.currentPosition, required this.isLoading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('HomeContent build - isLoading: $isLoading, currentPosition: $currentPosition');
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.blue.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Diagnosis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFeatureButton(
                          icon: Icons.link,
                          label: 'Chain',
                          color: Colors.blueAccent.withOpacity(0.8),
                          backgroundColor: Colors.white.withOpacity(0.8),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PainAreaScreen(),
                              ),
                            );
                          },
                        ),
                        _buildFeatureButton(
                          icon: Icons.mic,
                          label: 'Voice',
                          color: Colors.blueAccent.withOpacity(0.8),
                          backgroundColor: Colors.white.withOpacity(0.8),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AIMedicalScreen(),
                              ),
                            );
                          },
                        ),
                        _buildFeatureButton(
                          icon: Icons.text_fields,
                          label: 'Text',
                          color: Colors.blueAccent.withOpacity(0.8),
                          backgroundColor: Colors.white.withOpacity(0.8),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TextMedicalScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.green.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '주변 병원 찾기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        print('지도 화면으로 이동 시도');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: isLoading
                              ? Container(
                                  color: Colors.white.withOpacity(0.8),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                                    ),
                                  ),
                                )
                              : currentPosition == null
                                  ? Container(
                                      color: Colors.white.withOpacity(0.8),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.location_off,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              '위치 정보를 가져올 수 없습니다.\n위치 권한을 확인해주세요.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Stack(
                                      children: [
                                        GoogleMap(
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(
                                              currentPosition!.latitude,
                                              currentPosition!.longitude,
                                            ),
                                            zoom: 14,
                                          ),
                                          myLocationEnabled: true,
                                          myLocationButtonEnabled: false,
                                          zoomControlsEnabled: false,
                                          onMapCreated: (GoogleMapController controller) {
                                            print('지도 생성 완료');
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
                                        Positioned.fill(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () {
                                                print('지도 화면으로 이동 시도 (InkWell)');
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => const MapScreen(),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
} 