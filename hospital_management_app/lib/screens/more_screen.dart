import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hospital_management_app/screens/auth/login_screen.dart';
import 'package:hospital_management_app/screens/language_settings_screen.dart';
import 'package:hospital_management_app/screens/my_profile_screen.dart';
import 'recent_hospitals_screen.dart';
import 'country_info_screen.dart';
import 'appointments_screen.dart';
import 'hospital_reviews_screen.dart';
import 'about_screen.dart';
import 'help_screen.dart';
import 'settings_screen.dart';
import 'package:hospital_management_app/main.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreenWithHome()),
                    (route) => false,
                  );
                }
              },
              child: const Text('YES'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'More',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildSection('Personal Information', [
            _buildMenuItem(context, Icons.person, 'My Profile'),
            _buildMenuItem(context, Icons.history, 'Recent Hospitals'),
            _buildMenuItem(context, Icons.public, 'Country Information'),
          ]),
          const SizedBox(height: 20),
          _buildSection('Medical Services', [
            _buildMenuItem(context, Icons.calendar_today, 'Appointments'),
            _buildMenuItem(context, Icons.rate_review, 'Hospital Reviews'),
          ]),
          const SizedBox(height: 20),
          _buildSection('App Information', [
            _buildMenuItem(context, Icons.info, 'About'),
            _buildMenuItem(context, Icons.help, 'Help'),
            _buildMenuItem(context, Icons.settings, 'Settings'),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        if (title == 'Language') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LanguageSettingsScreen(),
            ),
          );
        } else if (title == 'My Profile') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MyProfileScreen(),
            ),
          );
        } else if (title == 'Recent Hospitals') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RecentHospitalsScreen(),
            ),
          );
        } else if (title == 'Country Information') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CountryInfoScreen(),
            ),
          );
        } else if (title == 'Appointments') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AppointmentsScreen(),
            ),
          );
        } else if (title == 'Hospital Reviews') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HospitalReviewsScreen(),
            ),
          );
        } else if (title == 'About') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AboutScreen(),
            ),
          );
        } else if (title == 'Help') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HelpScreen(),
            ),
          );
        } else if (title == 'Settings') {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.blue,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
} 