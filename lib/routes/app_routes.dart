import 'package:flutter/material.dart';
import '../screens/admin_login_screen.dart';
import '../screens/settings_management_screen.dart';
import '../screens/appointment_dashboard.dart';

class AppRoutes {
  static const String initial = '/';
  static const String adminLogin = '/admin-login-screen';
  static const String appointmentDashboard = '/appointment-dashboard';
  static const String settingsManagement = '/settings-management';

  static Map<String, WidgetBuilder> routes = {
    adminLogin: (context) => const AdminLoginScreen(),
    appointmentDashboard: (context) => const AppointmentDashboard(),
    settingsManagement: (context) => const SettingsManagementScreen(),
  };
}