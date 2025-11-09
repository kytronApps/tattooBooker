import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/app_export.dart';
import '../widgets/custom_snackbar.dart';

class AppointmentActionsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Confirmar cita
  Future<void> confirmAppointment(BuildContext context, String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'confirmado',
        'isRead': 'true', // se marca como leída al confirmar (string para compatibilidad)
        'updatedAt': DateTime.now().toIso8601String(),
      });

      CustomSnackBar.show(
        context,
        message: '✅ Cita confirmada correctamente',
      );
    } catch (e) {
      CustomSnackBar.show(
        context,
        message: 'Error al confirmar la cita',
        isError: true,
      );
    }
  }

  // 🔹 Cancelar cita
  Future<void> cancelAppointment(BuildContext context, String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelado',
        'updatedAt': DateTime.now().toIso8601String(),
      });

      CustomSnackBar.show(
        context,
        message: '🟠 Cita cancelada correctamente',
      );
    } catch (e) {
      CustomSnackBar.show(
        context,
        message: 'Error al cancelar la cita',
        isError: true,
      );
    }
  }

  // 🔹 Eliminar cita
  Future<void> deleteAppointment(BuildContext context, String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();

      CustomSnackBar.show(
        context,
        message: '🗑️ Cita eliminada correctamente',
      );
    } catch (e) {
      CustomSnackBar.show(
        context,
        message: 'Error al eliminar la cita',
        isError: true,
      );
    }
  }

  // 🔹 Editar cita (si cambia fecha u horario → vuelve a pendiente)
  Future<void> editAppointment(
    BuildContext context,
    String appointmentId, {
    required String serviceType,
    required String timeSlot,
    required String price,
    String? newDate,
  }) async {
    try {
      final docRef = _firestore.collection('appointments').doc(appointmentId);
      final existing = await docRef.get();
      final oldData = existing.data() ?? {};

      // Detectar cambio en fecha u horario
      bool horarioCambio = false;
      // Normalizar el valor antiguo de fecha para comparar (soporta Timestamp o String)
      String? oldDateStr;
      if (oldData.containsKey('date')) {
        final od = oldData['date'];
        if (od is Timestamp) {
          oldDateStr = od.toDate().toIso8601String();
        } else {
          oldDateStr = od?.toString();
        }
      }

      if (newDate != null) {
        // newDate viene como ISO string desde el modal
        final newDateNorm = newDate.toString();
        if (oldDateStr == null || newDateNorm != oldDateStr) horarioCambio = true;
      }

      if (timeSlot != (oldData['timeSlot']?.toString() ?? '')) horarioCambio = true;

      final newStatus = horarioCambio ? 'pendiente' : (oldData['status'] ?? 'pendiente');

      // Preparar payload con normalización de fecha y día de la semana
      final Map<String, Object?> dataToUpdate = {
        'serviceType': serviceType,
        'timeSlot': timeSlot,
        'price': price,
        'status': newStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (newDate != null) {
        // Normalizar newDate a ISO y calcular dayOfWeek en español (minuscula)
        DateTime parsed;
        try {
          parsed = DateTime.parse(newDate);
        } catch (_) {
          // si no parsea, no incluimos cambios de fecha
          parsed = DateTime.tryParse(newDate) ?? DateTime.now();
        }

        final days = ['lunes','martes','miércoles','jueves','viernes','sábado','domingo'];
        final dayOfWeek = days[(parsed.weekday - 1) % 7];

        dataToUpdate['date'] = parsed.toIso8601String();
        dataToUpdate['dayOfWeek'] = dayOfWeek;
      }

      await docRef.update(dataToUpdate);

      CustomSnackBar.show(
        context,
        message: horarioCambio
            ? '📅 Cita modificada, vuelve a pendiente'
            : '✏️ Cita actualizada correctamente',
      );
    } catch (e) {
      CustomSnackBar.show(
        context,
        message: 'Error al actualizar la cita',
        isError: true,
      );
    }
  }
}