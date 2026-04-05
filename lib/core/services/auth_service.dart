import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Singleton service that manages users in YAML.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Map<String, Map<String, String>> _users = {};
  String? _currentUser;

  bool get isLoggedIn => _currentUser != null;
  String get currentUser => _currentUser ?? '';

  static const String _assetPath = 'assets/credentials.yaml';
  static const String _prefKeyUser = 'logged_in_username';

  Future<File> get _targetFile async {
    if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
      final file = File(_assetPath);
      if (await file.exists()) return file;
    }
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/credentials.yaml');
  }

  /// Initialises credentials and restores session if "Remember Me" was used.
  Future<void> initialize() async {
    _users = {};

    // 1. Load defaults
    try {
      final raw = await rootBundle.loadString(_assetPath);
      _parseYaml(raw);
    } catch (_) {}

    // 2. Load and merge from writable file
    try {
      final file = await _targetFile;
      if (await file.exists()) {
        final raw = await file.readAsString();
        _parseYaml(raw);
      }
    } catch (_) {}

    // 3. Restore session
    final prefs = await SharedPreferences.getInstance();
    final rememberedUser = prefs.getString(_prefKeyUser);
    if (rememberedUser != null && _users.containsKey(rememberedUser)) {
      _currentUser = rememberedUser;
    }
    
    debugPrint('AUTH: Initialized. Logged in as: $_currentUser');
  }

  void _parseYaml(String content) {
    final doc = loadYaml(content);
    if (doc is YamlMap && doc.containsKey('users')) {
      final usersMap = doc['users'] as YamlMap;
      for (final entry in usersMap.entries) {
        final uname = entry.key.toString().toLowerCase().trim();
        final val = entry.value;
        if (val is YamlMap) {
          _users[uname] = {
            'password': val['password']?.toString() ?? '',
            'email': val['email']?.toString() ?? '$uname@example.com',
          };
        } else {
          _users[uname] = {
            'password': val.toString(),
            'email': '$uname@example.com',
          };
        }
      }
    }
  }

  Future<void> _saveToYaml() async {
    try {
      final file = await _targetFile;
      if (!await file.exists()) {
        await file.writeAsString('users: {}\n');
      }
      final content = await file.readAsString();
      final editor = YamlEditor(content.isEmpty ? 'users: {}\n' : content);
      for (final uname in _users.keys) {
        editor.update(['users', uname], _users[uname]);
      }
      await file.writeAsString(editor.toString());
    } catch (e) {
      debugPrint('AUTH ERROR: Could not save YAML: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    final key = username.toLowerCase().trim();
    if (_users.containsKey(key) && _users[key]?['password'] == password) {
      _currentUser = key;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyUser, key);
      return true;
    }
    return false;
  }

  Future<bool> signUp(String username, String password, {String email = ''}) async {
    final key = username.toLowerCase().trim();
    if (_users.containsKey(key)) return false;

    _users[key] = {
      'password': password,
      'email': email.isEmpty ? '$key@example.com' : email,
    };

    await _saveToYaml();
    _currentUser = key;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyUser, key);
    
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyUser);
  }

  Future<bool> updateUser(String name, String email) async {
    if (_currentUser == null) return false;
    _users[_currentUser!]?['email'] = email;
    await _saveToYaml();
    return true;
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;
    final currentKey = _currentUser!;
    if (_users[currentKey]?['password'] != oldPassword) return false;
    _users[currentKey]?['password'] = newPassword;
    await _saveToYaml();
    return true;
  }

  String getEmail() => _users[_currentUser]?['email'] ?? 'no-email@example.com';
}
