import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/services/auth_service.dart';

void main() async {
  // Ensure Flutter engine is initialised before any plugin calls.
  WidgetsFlutterBinding.ensureInitialized();

  // Load credentials from assets/credentials.yaml.
  await AuthService.instance.initialize();

  // Lock the app to portrait mode.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Use a transparent status bar with dark icons.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const SplitMateApp());
}
