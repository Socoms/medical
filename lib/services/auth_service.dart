import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userKey = 'user_email';
  static const String _passwordKey = 'user_password';

  static Future<bool> signInWithEmailAndPassword(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_userKey);
    final savedPassword = prefs.getString(_passwordKey);

    if (savedEmail == email && savedPassword == password) {
      return true;
    }
    return false;
  }

  static Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, email);
      await prefs.setString(_passwordKey, password);
      return true;
    } catch (e) {
      debugPrint('Error during sign up: $e');
      return false;
    }
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_passwordKey);
  }

  static Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }

  static Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }
} 