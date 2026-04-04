import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';

  String _userName = 'Misafir';
  String _userEmail = 'misafir@example.com';

  String get userName => _userName;
  String get userEmail => _userEmail;

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString(_keyName) ?? 'Kullanıcı Adı';
    _userEmail = prefs.getString(_keyEmail) ?? 'kullanici@email.com';
    notifyListeners();
  }

  Future<void> updateUserData(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    _userName = name;
    _userEmail = email;
    notifyListeners();
  }
}
