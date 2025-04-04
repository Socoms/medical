import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical App',
      debugShowCheckedModeBanner: false,
      home: NearbyHospitalsPage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class NearbyHospitalsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 상단 앱바
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Row(
                children: [
                  Icon(Icons.menu, size: isMobile ? 24 : 28),
                  SizedBox(width: isMobile ? 12 : 16),
                  Text(
                    'Nearby Hospitals',
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.search, size: isMobile ? 24 : 28),
                ],
              ),
            ),

            // 배너
            Container(
              height: isMobile ? 150 : 200,
              width: double.infinity,
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Text(
                  'Find the nearest\nhospital now!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 메인 버튼들
            Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                children: [
                  _buildButton('Hospital Search', true, isMobile),
                  SizedBox(height: isMobile ? 8 : 12),
                  _buildButton('Online Consultation', false, isMobile),
                  SizedBox(height: isMobile ? 8 : 12),
                  _buildButton('Pharmacy Finder', true, isMobile),
                  SizedBox(height: isMobile ? 8 : 12),
                  _buildButton('Emergency Guide', false, isMobile),
                ],
              ),
            ),

            // 필터 버튼들
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
              child: Row(
                children: [
                  _buildFilterChip('All', isMobile),
                  SizedBox(width: isMobile ? 6 : 8),
                  _buildFilterChip('Internal Medicine', isMobile),
                  SizedBox(width: isMobile ? 6 : 8),
                  _buildFilterChip('Surgery', isMobile),
                ],
              ),
            ),

            // 병원 리스트
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                children: [
                  _buildHospitalCard(
                    'City Hospital',
                    'Open 24/7, 2 miles away',
                    isMobile,
                  ),
                  SizedBox(height: isMobile ? 8 : 12),
                  _buildHospitalCard(
                    'Sunrise Clinic',
                    'Open until 8 PM, 1.5 miles away',
                    isMobile,
                  ),
                ],
              ),
            ),

            // 하단 네비게이션 바
            BottomNavigationBar(
              currentIndex: 0,
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: isMobile ? 20 : 24),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite, size: isMobile ? 20 : 24),
                  label: 'Health',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today, size: isMobile ? 20 : 24),
                  label: 'Appointments',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu, size: isMobile ? 20 : 24),
                  label: 'More',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, bool isDark, bool isMobile) {
    return Container(
      width: double.infinity,
      height: isMobile ? 45 : 50,
      child: ElevatedButton(
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(fontSize: isMobile ? 14 : 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.black : Colors.grey[200],
          foregroundColor: isDark ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 20 : 25),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isMobile) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(fontSize: isMobile ? 12 : 14),
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildHospitalCard(String name, String info, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
            ),
            child: Icon(
              Icons.local_hospital,
              size: isMobile ? 30 : 40,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  info,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.favorite_border,
            size: isMobile ? 20 : 24,
          ),
        ],
      ),
    );
  }
}