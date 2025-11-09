import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sizer/sizer.dart';

import 'firebase_options.dart';
import 'screens/admin_login_screen.dart';
 import 'layout/main_layout.dart';
import 'screens/appointment_dashboard.dart';
import 'screens/settings_management_screen.dart';
import 'core/app_export.dart'; // si tu AppTheme está ahí

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

          // ✅ Tema claro de tu AppTheme
          theme: AppTheme.lightTheme,

          // ✅ Soporte completo para localización (soluciona el DatePicker)
          // No usar `const` aquí porque los delegates no son constantes en tiempo de compilación
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'),
            Locale('en', 'US'),
          ],

          // ✅ Define la pantalla inicial según sesión activa
           home: sessionActive
               ? const MainLayout()
               : const AdminLoginScreen(),

          // ✅ Rutas limpias y consistentes
          routes: {
            '/appointment-dashboard': (_) => const AppointmentDashboard(),
            '/admin-login-screen': (_) => const AdminLoginScreen(),
            '/settings-management': (_) => const SettingsManagementScreen(),
             '/main': (_) => const MainLayout(),
          },
        );
      },
    );
  }
}