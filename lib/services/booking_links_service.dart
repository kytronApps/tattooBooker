import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class BookingLinksService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String linksCollection = 'booking_links';
  final String appointmentsCollection = 'appointments';
  final Uuid _uuid = const Uuid();

  /// 🔹 Genera un link con token único y cita asociada
  Future<DocumentReference<Map<String, dynamic>>> createLink({
    bool active = true,
    DateTime? expiresAt,
  }) async {
    // ✅ Generar token UUID (único a nivel global)
    final String token = _uuid.v4().substring(0, 12); // más corto para URLs

    // 1️⃣ Crear cita base en `appointments`
    final appointmentRef =
        await _firestore.collection(appointmentsCollection).add({
      'clientName': '',
      'email': '',
      'phone': '',
      'serviceType': '',
      'status': 'pendiente',
      'isRead': false,
      'editToken': token, // 👈 clave única del cliente
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // 2️⃣ Crear documento en `booking_links` asociado
    final linkRef = await _firestore.collection(linksCollection).add({
      'appointmentId': appointmentRef.id,
      'editToken': token,
      'active': active,
      'uses': 0,
      'createdAt': DateTime.now().toIso8601String(),
      if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
    });

    return linkRef;
  }

  /// 🔹 Stream en vivo de todos los links
  Stream<QuerySnapshot<Map<String, dynamic>>> linksStream() {
    return _firestore
        .collection(linksCollection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// 🔹 Activar / revocar link
  Future<void> toggleActive(String id, bool active) async {
    await _firestore
        .collection(linksCollection)
        .doc(id)
        .update({'active': active});
  }

  /// 🔹 Eliminar link (y cita asociada)
  Future<void> deleteLink(String id) async {
    final doc = await _firestore.collection(linksCollection).doc(id).get();
    if (doc.exists) {
      final data = doc.data();
      final appointmentId = data?['appointmentId'];
      if (appointmentId != null) {
        await _firestore
            .collection(appointmentsCollection)
            .doc(appointmentId)
            .delete();
      }
    }
    await _firestore.collection(linksCollection).doc(id).delete();
  }

  /// 🔹 Incrementa el contador de usos
  Future<void> incrementUses(String id) async {
    await _firestore
        .collection(linksCollection)
        .doc(id)
        .update({'uses': FieldValue.increment(1)});
  }
}