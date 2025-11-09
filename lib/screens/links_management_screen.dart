import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class LinksManagementScreen extends StatefulWidget {
  const LinksManagementScreen({super.key});

  @override
  State<LinksManagementScreen> createState() => _LinksManagementScreenState();
}

class _LinksManagementScreenState extends State<LinksManagementScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();
  bool _loading = false;

  Future<void> _generateLink() async {
    setState(() => _loading = true);
    final id = _uuid.v4();
    final url = "https://kytron-apps.web.app/book";

    await _firestore.collection('links').doc(id).set({
      'url': url,
      'createdAt': DateTime.now().toIso8601String(),
      'active': true,
    });

    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Link generado: $url')),
    );
  }

  Future<void> _revokeLink(String id) async {
    await _firestore.collection('links').doc(id).update({'active': false});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link revocado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Links')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('links').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          return ListView(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['url']),
                subtitle: Text(data['active'] ? 'Activo' : 'Revocado'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _revokeLink(doc.id),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateLink,
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
      ),
    );
  }
}