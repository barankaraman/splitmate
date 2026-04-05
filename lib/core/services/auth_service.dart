import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Singleton service that manages ALL users in a single writable YAML file.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Map<String, Map<String, String>> _users = {};
  String? _currentUser;

  bool get isLoggedIn => _currentUser != null;
  String get currentUser => _currentUser ?? '';

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/credentials.yaml');
  }

  /// Initialises credentials by merging assets and local storage.
  Future<void> initialize() async {
    final Map<String, Map<String, String>> mergedUsers = {};

    // 1. Load users from assets/credentials.yaml (Source of truth for initial setup)
    try {
      final rawAssets = await rootBundle.loadString('assets/credentials.yaml');
      final docAssets = loadYaml(rawAssets);
      if (docAssets is YamlMap && docAssets.containsKey('users')) {
        final usersMap = docAssets['users'] as YamlMap;
        for (final entry in usersMap.entries) {
          final uname = entry.key.toString().toLowerCase().trim();
          final val = entry.value;
          if (val is YamlMap) {
            mergedUsers[uname] = {
              'password': val['password']?.toString() ?? '',
              'email': val['email']?.toString() ?? '$uname@example.com',
            };
          } else {
            mergedUsers[uname] = {
              'password': val.toString(),
              'email': '$uname@example.com',
            };
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading assets YAML: $e');
    }

    // 2. Merge with local writable credentials.yaml (Persisted sign-ups)
    final file = await _localFile;
    if (await file.exists()) {
      try {
        final rawLocal = await file.readAsString();
        final docLocal = loadYaml(rawLocal);
        if (docLocal is YamlMap && docLocal.containsKey('users')) {
          final usersMap = docLocal['users'] as YamlMap;
          for (final entry in usersMap.entries) {
            final uname = entry.key.toString().toLowerCase().trim();
            final val = entry.value;
            if (val is YamlMap) {
              // Local data overrides assets
              mergedUsers[uname] = {
                'password': val['password']?.toString() ?? '',
                'email': val['email']?.toString() ?? '$uname@example.com',
              };
            }
          }
        }
      } catch (e) {
        debugPrint('Error loading local YAML: $e');
      }
    }

    // 3. Save the merged result back to local file to keep it updated
    _users = mergedUsers;
    await _saveAllToYaml();
    
    debugPrint('AuthService Initialized. Users loaded: ${_users.keys.join(", ")}');
  }

  Future<void> _saveAllToYaml() async {
    try {
      final file = await _localFile;
      final editor = YamlEditor('users: {}\n');
      for (final uname in _users.keys) {
        editor.update(['users', uname], _users[uname]);
      }
      await file.writeAsString(editor.toString());
    } catch (e) {
      debugPrint('Error saving YAML: $e');
    }
  }

  bool login(String username, String password) {
    final key = username.toLowerCase().trim();
    if (_users.containsKey(key) && _users[key]?['password'] == password) {
      _currentUser = key;
      debugPrint('Login successful for: $key');
      return true;
    }
    debugPrint('Login failed for: $key (Users in memory: ${_users.keys.join(", ")})');
    return false;
  }

  Future<bool> signUp(String username, String password, {String email = ''}) async {
    final key = username.toLowerCase().trim();
    if (_users.containsKey(key)) return false;

    _users[key] = {
      'password': password,
      'email': email.isEmpty ? '$key@example.com' : email,
    };

    await _saveAllToYaml();
    _currentUser = key;
    return true;
  }

  Future<bool> updateUser(String name, String email) async {
    if (_currentUser == null) return false;
    _users[_currentUser!]?['email'] = email;
    await _saveAllToYaml();
    return true;
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) return false;
    final currentKey = _currentUser!;
    if (_users[currentKey]?['password'] != oldPassword) return false;

    _users[currentKey]?['password'] = newPassword;
    await _saveAllToYaml();
    return true;
  }

  String getEmail() => _users[_currentUser]?['email'] ?? 'no-email@example.com';

  void logout() => _currentUser = null;
}
