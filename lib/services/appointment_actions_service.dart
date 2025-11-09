import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/app_export.dart';
import '../widgets/custom_snackbar.dart';

class AppointmentActionsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Cancelar cita
  Future<void> cancelAppointment(BuildContext context, String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelado',
      });

      CustomSnackBar.show(
        context,
        message: 'Cita cancelada correctamente',
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
        message: 'Cita eliminada correctamente',
      );
    } catch (e) {
      CustomSnackBar.show(
        context,
        message: 'Error al eliminar la cita',
        isError: true,
      );
    }
  }

  // 🔹 Editar cita
  Future<void> editAppointment(
    BuildContext context,
    String appointmentId, {
    required String serviceType,
    required String timeSlot,
    required String price,
  }) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'serviceType': serviceType,
        'timeSlot': timeSlot,
        'price': price,
      });

      CustomSnackBar.show(
        context,
        message: 'Cita actualizada correctamente',
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