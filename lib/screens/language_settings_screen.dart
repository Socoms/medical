import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', '한국어'];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final language = _languages[index];
          return ListTile(
            title: Text(
              language,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: _selectedLanguage == language
                ? const Icon(
                    Icons.check,
                    color: Colors.purple,
                  )
                : null,
            onTap: () {
              _saveLanguage(language);
            },
          );
        },
      ),
    );
  }
} 