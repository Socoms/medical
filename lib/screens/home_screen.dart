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
      final status = await Permission.location.request();
      if (status.isGranted) {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _currentPosition = null;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoading = false;
        _currentPosition = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Medical Korea',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
                      color: Colors.black,
                      fontSize: 16,
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Diagnosis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFeatureButton(
                      icon: Icons.link,
                      label: 'Chain',
                      color: Colors.black,
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
                      color: Colors.black,
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
                      color: Colors.black,
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
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nearby Hospitals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.black12,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : currentPosition == null
                              ? const Center(
                                  child: Text(
                                    '위치 정보를 가져올 수 없습니다.',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
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
                                    ),
                                    Positioned.fill(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
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
        ],
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 