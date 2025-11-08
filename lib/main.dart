import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sizer/sizer.dart';
import 'firebase_options.dart';
import 'screens/admin_login_screen.dart';
import 'screens/appointment_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      Firebase.app();
    }
  } catch (e) {
    debugPrint('⚠️ Firebase ya inicializado: $e');
  }

  final user = FirebaseAuth.instance.currentUser;
  runApp(TattooBookerApp(sessionActive: user != null));
}

class TattooBookerApp extends StatelessWidget {
  final bool sessionActive;
  const TattooBookerApp({super.key, required this.sessionActive});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TattooBooker',
          theme: ThemeData.dark(),
          home: sessionActive
              ? const AppointmentDashboard()
              : const AdminLoginScreen(),
          routes: {
            '/appointment-dashboard': (_) => const AppointmentDashboard(),
            '/login': (_) => const AdminLoginScreen(),
          },
        );
      },
    );
  }
}