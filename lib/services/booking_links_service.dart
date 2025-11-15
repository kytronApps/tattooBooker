import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class BookingLinksService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String linksCollection = 'booking_links';
  final String appointmentsCollection = 'appointments';
  final Uuid _uuid = const Uuid();

  /// 🔹 Genera un link con token único SIN crear cita
  Future<DocumentReference<Map<String, dynamic>>> createLink({
    bool active = true,
    DateTime? expiresAt,
  }) async {
    // 1️⃣ Token único
    final String token = _uuid.v4().substring(0, 12);

    // 2️⃣ Registrar solo el link (SIN crear appointment)
    final linkRef = await _firestore.collection(linksCollection).add({
      'appointmentId': null, // 👈 NO crear cita
      'editToken': token,
      'active': active,
      'uses': 0,
      'createdAt': DateTime.now().toIso8601String(),
      if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
    });

    print('✅ Link creado: https://kytron-apps.web.app/book/$token');
    return linkRef;
  }

  /// 🔹 Escucha en tiempo real todos los links
  Stream<QuerySnapshot<Map<String, dynamic>>> linksStream() {
    return _firestore
        .collection(linksCollection)
        .where('active', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// 🔹 Activar / Revocar link
  Future<void> toggleActive(String id, bool active) async {
    await _firestore.collection(linksCollection).doc(id).update({
      'active': active,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// 🔹 Eliminar link y SU cita asociada si la hubiera
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

  /// 🔹 Incrementar contador de usos
  Future<void> incrementUses(String id) async {
    await _firestore.collection(linksCollection).doc(id).update({
      'uses': FieldValue.increment(1),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// 🔹 Mueve link revocado al histórico
  Future<void> moveLinkToHistory(String id) async {
    final docRef = _firestore.collection(linksCollection).doc(id);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data();
      if (data != null) {
        // 1️⃣ Guardar copia en booking_links_history
        await _firestore.collection('booking_links_history').add({
          ...data,
          'active': false,
          'revokedAt': DateTime.now().toIso8601String(),
        });

        // 2️⃣ Si hay cita asociada, moverla al historial
        final appointmentId = data['appointmentId'];
        if (appointmentId != null) {
          await moveAppointmentToHistory(appointmentId);
        }

        // 3️⃣ Eliminar el link original
        await docRef.delete();
      }
    }
  }

  /// 🔹 Mover cita a appointments_history
  Future<void> moveAppointmentToHistory(String appointmentId) async {
    final appointmentRef =
        _firestore.collection(appointmentsCollection).doc(appointmentId);
    final snapshot = await appointmentRef.get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        await _firestore.collection('appointments_history').add({
          ...data,
          'movedToHistoryAt': DateTime.now().toIso8601String(),
        });

        await appointmentRef.delete();
      }
    }
  }

  /// 🔹 Eliminar cita del histórico
  Future<void> deleteFromHistory(String historyId) async {
    await _firestore
        .collection('appointments_history')
        .doc(historyId)
        .delete();
  }
}