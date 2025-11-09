import 'package:flutter/material.dart';
import '../screens/admin_login_screen.dart';
import '../screens/settings_management_screen.dart';
import '../screens/appointment_dashboard.dart';
import '../screens/appointment_form_screen.dart'; 
import '../layout/main_layout.dart';
import '../screens/calendar_management_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String adminLogin = '/admin-login-screen';
  static const String appointmentDashboard = '/appointment-dashboard';
  static const String settingsManagement = '/settings-management';
  static const String newAppointment = '/new-appointment';
  static const String calendarManagement = '/calendar-management-screen';
  static const String mainLayout = '/main';

  static Map<String, WidgetBuilder> routes = {
    adminLogin: (context) => const AdminLoginScreen(),
    appointmentDashboard: (context) => const AppointmentDashboard(),
    settingsManagement: (context) => const SettingsManagementScreen(),
    mainLayout: (context) => const MainLayout(),
    calendarManagement: (context) => const CalendarManagementScreen(),
    newAppointment: (context) => const AppointmentFormScreen(), // ✅ aquí usamos tu formulario
  };
}