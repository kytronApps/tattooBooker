import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sizer/sizer.dart';

import 'firebase_options.dart';
import 'core/app_export.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 🔹 Inicializa Firebase solo si no hay instancias activas
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("✅ Firebase inicializado correctamente");
    } else {
      Firebase.app(); // Usa la instancia existente
      debugPrint("ℹ️ Firebase ya estaba inicializado");
    }
  } catch (e) {
    // Evitar log verbose de duplicate-app: ya existe la instancia por hot-reload u otra inicialización
    debugPrint("⚠️ Firebase init skipped (already initialized)");
  }

  // 🔹 Recuperar sesión actual (si existe)
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

          // ✅ Ruta inicial según sesión
          initialRoute:
              sessionActive ? AppRoutes.mainLayout : AppRoutes.adminLogin,

          // ✅ Rutas centralizadas
          routes: AppRoutes.routes,
        );
      },
    );
  }
}