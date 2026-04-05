import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

/// Singleton service that handles login, logout and password changes.
///
/// Base credentials are loaded from assets/credentials.yaml.
/// Password overrides are persisted in SharedPreferences so changes
/// survive app restarts.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Map<String, String> _credentials = {};
  String? _currentUser;

  bool get isLoggedIn => _currentUser != null;
  String get currentUser => _currentUser ?? '';

  /// Must be called once in main() before runApp.
  Future<void> initialize() async {
    final raw = await rootBundle.loadString('assets/credentials.yaml');
    final doc = loadYaml(raw) as YamlMap;
    final users = doc['users'] as YamlMap;

    final prefs = await SharedPreferences.getInstance();
    _credentials = {};
    for (final entry in users.entries) {
      final username = (entry.key as String).toLowerCase();
      final defaultPwd = entry.value.toString();
      final override = prefs.getString('pwd_$username');
      _credentials[username] = override ?? defaultPwd;
    }
  }

  /// Returns true if credentials match. Stores the current user on success.
  bool login(String username, String password) {
    final key = username.toLowerCase().trim();
    final stored = _credentials[key];
    if (stored != null && stored == password) {
      _currentUser = key;
      return true;
    }
    return false;
  }

  /// Returns true and persists the new password if [oldPassword] is correct.
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;
    if (_credentials[_currentUser!] != oldPassword) return false;

    _credentials[_currentUser!] = newPassword;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pwd_$_currentUser', newPassword);
    return true;
  }

  void logout() => _currentUser = null;
}
