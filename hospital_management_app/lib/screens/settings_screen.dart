import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hospital_management_app/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSettingSection('Notification Settings', [
              _buildSwitchSetting(
                'Receive Notifications',
                'Get app notifications',
                _notificationsEnabled,
                (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ]),
            const SizedBox(height: 20),
            _buildSettingSection('Display Settings', [
              _buildSwitchSetting(
                'Dark Mode',
                'Switch to dark theme',
                _darkModeEnabled,
                (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
              ),
            ]),
            const SizedBox(height: 20),
            _buildSettingSection('Location Services', [
              _buildSwitchSetting(
                'Share Location',
                'Share location for nearby hospital search',
                _locationEnabled,
                (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
              ),
            ]),
            const SizedBox(height: 20),
            _buildSettingSection('Language Settings', [
              _buildLanguageSetting(),
            ]),
            const SizedBox(height: 20),
            _buildSettingSection('Account', [
              _buildAccountSetting('Delete Account', Icons.delete, () {
                // 계정 삭제 로직
              }),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSection(String title, List<Widget> items) {
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

  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildLanguageSetting() {
    return ListTile(
      title: const Text('Language'),
      subtitle: Text(
        _selectedLanguage,
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption('English'),
                _buildLanguageOption('한국어'),
                _buildLanguageOption('日本語'),
                _buildLanguageOption('中文'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language),
      trailing: _selectedLanguage == language
          ? const Icon(
              Icons.check,
              color: Colors.blue,
            )
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildAccountSetting(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.red,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
      onTap: onTap,
    );
  }
} 