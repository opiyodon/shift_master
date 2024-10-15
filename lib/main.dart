import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shift_master/firebase_options.dart';
import 'package:shift_master/screens/dashboard_screen.dart';
import 'package:shift_master/screens/employee_management_screen.dart';
import 'package:shift_master/screens/login_screen.dart';
import 'package:shift_master/screens/notification_screen.dart';
import 'package:shift_master/screens/register_screen.dart';
import 'package:shift_master/screens/report_screen.dart';
import 'package:shift_master/screens/settings_screen.dart';
import 'package:shift_master/screens/shift_management_screen.dart';
import 'package:shift_master/screens/splash_screen.dart';
import 'package:shift_master/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const ShiftMasterApp());
}

class ShiftMasterApp extends StatelessWidget {
  const ShiftMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shift Master',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/shifts': (context) => const ShiftManagementScreen(),
        '/employees': (context) => const EmployeeManagementScreen(),
        '/reports': (context) => const ReportScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
