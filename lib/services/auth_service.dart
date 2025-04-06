import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userKey = 'user';

  // 회원가입
  static Future<bool> signUp(String name, String email, String password) async {
    try {
      // 이미 가입된 이메일인지 확인
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList('users') ?? [];
      
      for (final userJson in users) {
        final user = jsonDecode(userJson);
        if (user['email'] == email) {
          return false; // 이미 존재하는 이메일
        }
      }

      // 새 사용자 추가
      final newUser = {
        'name': name,
        'email': email,
        'password': password,
      };
      users.add(jsonEncode(newUser));
      await prefs.setStringList('users', users);
      
      // 로그인 처리
      await prefs.setString(_userKey, jsonEncode(newUser));
      return true;
    } catch (e) {
      return false;
    }
  }

  // 로그인
  static Future<bool> signIn(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = prefs.getStringList('users') ?? [];
      
      for (final userJson in users) {
        final user = jsonDecode(userJson);
        if (user['email'] == email && user['password'] == password) {
          await prefs.setString(_userKey, userJson);
          return true;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // 로그아웃
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // 현재 로그인된 사용자 확인
  static Future<bool> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      return userJson != null;
    } catch (e) {
      return false;
    }
  }
} 