import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Managed user data strictly using AuthService (which uses YAML storage).
class UserProvider extends ChangeNotifier {
  String get userName => AuthService.instance.currentUser.isNotEmpty 
      ? AuthService.instance.currentUser 
      : 'Guest';
      
  String get userEmail => AuthService.instance.isLoggedIn 
      ? AuthService.instance.getEmail() 
      : 'guest@example.com';

  /// Updates user data in the YAML file via AuthService.
  Future<void> updateUserData(String name, String email) async {
    // Note: Since usernames are our primary keys in YAML, 
    // we primarily update the email here.
    await AuthService.instance.updateUser(name, email);
    notifyListeners();
  }

  void refresh() => notifyListeners();
}
