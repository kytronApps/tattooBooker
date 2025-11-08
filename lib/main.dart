import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/firestore_test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TattooBookerApp());
}

class TattooBookerApp extends StatelessWidget {
  const TattooBookerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TattooBooker',
      theme: ThemeData.dark(),
      home: const FirestoreTestScreen(),
    );
  }
}