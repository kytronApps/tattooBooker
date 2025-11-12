import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class BookingLinksService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String linksCollection = 'booking_links';
  final String appointmentsCollection = 'appointments';
  final Uuid _uuid = const Uuid();

  /// 🔹 Genera un link con token único y crea la cita base
  Future<DocumentReference<Map<String, dynamic>>> createLink({
    bool active = true,
    DateTime? expiresAt,
  }) async {
    // ✅ 1️⃣ Generar token único global
    final String token = _uuid.v4().substring(0, 12);

    // ✅ 2️⃣ Crear cita base en `appointments`
    final appointmentRef =
        await _firestore.collection(appointmentsCollection).add({
      'clientName': '',
      'phone': '',
      'email': '',
      'serviceType': '',
      'price': '',
      'date': '',
      'timeSlot': '',
      'status': 'pendiente',
      'isRead': false,
      'editToken': token, // 👈 vinculado a link web
      'active': true,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'lastChangeSource': 'admin',
    });

    // ✅ 3️⃣ Crear registro en `booking_links`
    final linkRef = await _firestore.collection(linksCollection).add({
      'appointmentId': appointmentRef.id,
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
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// 🔹 Activar / Revocar link
  Future<void> toggleActive(String id, bool active) async {
    await _firestore.collection(linksCollection).doc(id).update({'active': active});
  }

  /// 🔹 Eliminar link y su cita asociada
  Future<void> deleteLink(String id) async {
    final doc = await _firestore.collection(linksCollection).doc(id).get();
    if (doc.exists) {
      final data = doc.data();
      final appointmentId = data?['appointmentId'];
      if (appointmentId != null) {
        await _firestore.collection(appointmentsCollection).doc(appointmentId).delete();
      }
    }
    await _firestore.collection(linksCollection).doc(id).delete();
  }

  /// 🔹 Incrementar contador de usos
  Future<void> incrementUses(String id) async {
    await _firestore.collection(linksCollection).doc(id).update({
      'uses': FieldValue.increment(1),
    });
  }



  /// 🔹 Mueve link revocado al histórico y lo elimina de los activos
Future<void> moveLinkToHistory(String id) async {
  final docRef = _firestore.collection(linksCollection).doc(id);
  final docSnap = await docRef.get();

  if (docSnap.exists) {
    final data = docSnap.data();
    if (data != null) {
      // 1️⃣ Crear copia del link en su histórico
      await _firestore.collection('booking_links_history').add({
        ...data,
        'active': false,
        'revokedAt': DateTime.now().toIso8601String(),
      });

      // 2️⃣ Mover la cita asociada a appointments_history
      final appointmentId = data['appointmentId'];
      if (appointmentId != null) {
        await moveAppointmentToHistory(appointmentId);
      }

      // 3️⃣ Eliminar el link original
      await docRef.delete();

      print('✅ Link revocado y movido a histórico');
    }
  }
}


/// 🔹 Mueve la cita asociada a appointments_history y la elimina del listado activo
Future<void> moveAppointmentToHistory(String appointmentId) async {
  final appointmentRef = _firestore.collection(appointmentsCollection).doc(appointmentId);
  final snapshot = await appointmentRef.get();

  if (snapshot.exists) {
    final data = snapshot.data();
    if (data != null) {
      // 1️⃣ Crear copia en appointments_history
      await _firestore.collection('appointments_history').add({
        ...data,
        'movedToHistoryAt': DateTime.now().toIso8601String(),
      });

      // 2️⃣ Eliminar cita activa
      await appointmentRef.delete();

      print('✅ Cita movida a appointments_history');
    }
  }
}

/// 🔹 Elimina una cita del histórico
Future<void> deleteFromHistory(String historyId) async {
  await _firestore.collection('appointments_history').doc(historyId).delete();
  print('🗑️ Cita eliminada del histórico');
}


}