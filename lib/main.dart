import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      Firebase.app(); // Usa la instancia existente
    }
  } catch (e) {
    debugPrint('⚠️ Firebase ya estaba inicializado: $e');
  }

  runApp(const TattooBookerApp(sessionActive: false));
}

class TattooBookerApp extends StatelessWidget {
  final bool sessionActive;
  const TattooBookerApp({super.key, required this.sessionActive});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TattooBooker',
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Hola mundo 👋',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      routes: {
        '/appointment-dashboard': (_) => const AppointmentDashboard(),
        '/login': (_) => const AdminLoginScreen(),
      },
    );
  }
}