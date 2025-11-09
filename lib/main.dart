import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sizer/sizer.dart';

import 'firebase_options.dart';
import 'core/app_export.dart';
import 'routes/app_routes.dart'; // ✅ importa las rutas centralizadas

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
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'),
            Locale('en', 'US'),
          ],

          // ✅ Pantalla inicial según sesión
          initialRoute: sessionActive
              ? AppRoutes.mainLayout
              : AppRoutes.adminLogin,

          // ✅ Usa las rutas centralizadas
          routes: AppRoutes.routes,
        );
      },
    );
  }
}