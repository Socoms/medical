import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCWYmx1wgOx_2u4FOqjqF-6xSNjMPuG0gI",
      authDomain: "medical-895d5.firebaseapp.com",
      projectId: "medical-895d5",
      storageBucket: "medical-895d5.firebasestorage.app",
      messagingSenderId: "324537336133",
      appId: "1:324537336133:web:907496c163b88ca631be2c",
      measurementId: "G-QS6B8SC97Q",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<bool>(
        future: AuthService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.data == true) {
            return const HomePage();
          }
          
          return const LoginPage();
        },
      ),
      routes: {
        '/signup': (context) => const SignupPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Korea'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // App Bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () {},
                            ),
                            const Text(
                              'Nearby Hospitals',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                      
                      // Banner Image
                      Container(
                        height: 200,
                        width: double.infinity,
                        color: const Color(0xFFE8F5E9),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              right: 0,
                              child: Image.asset(
                                'assets/images/hospital_illustration.png',
                                height: 200,
                                width: MediaQuery.of(context).size.width * 0.7,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    const Color(0xFFE8F5E9),
                                    const Color(0xFFE8F5E9),
                                    const Color(0xFFE8F5E9).withOpacity(0.9),
                                    const Color(0xFFE8F5E9).withOpacity(0.6),
                                    const Color(0xFFE8F5E9).withOpacity(0.2),
                                  ],
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 20,
                              bottom: 40,
                              child: Text(
                                'Find the nearest\nhospital now!',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quick Actions
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildActionButton(
                              'Hospital Search',
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Online Consultation',
                              backgroundColor: Colors.grey[200]!,
                              textColor: Colors.black,
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Pharmacy Finder',
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                            ),
                            const SizedBox(height: 12),
                            _buildActionButton(
                              'Emergency Guide',
                              backgroundColor: Colors.grey[200]!,
                              textColor: Colors.black,
                            ),
                          ],
                        ),
                      ),

                      // Category Filter
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildFilterChip('All'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Internal Medicine'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Surgery'),
                          ],
                        ),
                      ),

                      // Hospital List
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildHospitalCard(
                              'City Hospital',
                              'Open 24/7, 2 miles away',
                              'assets/images/hospital1.jpg',
                            ),
                            const SizedBox(height: 12),
                            _buildHospitalCard(
                              'Sunrise Clinic',
                              'Open until 8 PM, 1.5 miles away',
                              'assets/images/hospital2.jpg',
                            ),
                          ],
                        ),
                      ),
                      
                      // Add some bottom padding for better scrolling
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'More',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, {
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHospitalCard(String name, String description, String imagePath) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.asset(
              imagePath,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}