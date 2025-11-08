import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTestScreen extends StatefulWidget {
  const FirestoreTestScreen({super.key});

  @override
  State<FirestoreTestScreen> createState() => _FirestoreTestScreenState();
}

class _FirestoreTestScreenState extends State<FirestoreTestScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userName;
  String? _userEmail;
  String _status = 'Cargando datos...';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .where('rol', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final user = snapshot.docs.first.data();
        setState(() {
          _userName = user['nombre'];
          _userEmail = user['email'];
          _status = '✅ Datos cargados correctamente';
        });
      } else {
        setState(() => _status = '⚠️ No se encontró ningún administrador');
      }
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba Firestore')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, style: const TextStyle(fontSize: 16)),
            if (_userName != null) ...[
              const SizedBox(height: 16),
              Text('Admin: $_userName', style: const TextStyle(fontSize: 20)),
              Text('Email: $_userEmail', style: const TextStyle(fontSize: 16)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAdminData,
              child: const Text('🔄 Recargar'),
            ),
          ],
        ),
      ),
    );
  }
}