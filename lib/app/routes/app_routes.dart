import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/welcome_screen.dart';
import '../../features/auth/presentation/pages/signup_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/upload/presentation/pages/device_upload_screen.dart';
import '../../features/upload/presentation/pages/link_upload_screen.dart';
import '../../features/history/presentation/pages/history_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/premium/presentation/pages/premium_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String deviceUpload = '/upload/device';
  static const String linkUpload = '/upload/link';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String premium = '/premium';

  static Map<String, WidgetBuilder> routes = {
    welcome: (context) => const WelcomeScreen(),
    signup: (context) => const SignUpScreen(),
    home: (context) => const HomeScreen(),
    deviceUpload: (context) => const DeviceUploadScreen(),
    linkUpload: (context) => const LinkUploadScreen(),
    history: (context) => const HistoryScreen(),
    settings: (context) => const SettingsScreen(),
    premium: (context) => const PremiumScreen(),
  };
}
