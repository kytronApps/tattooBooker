import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String rol; // 'admin' o 'cliente'
  final bool activo;
  final Timestamp creadoEn;
  final Timestamp actualizadoEn;

  UsuarioModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.rol,
    required this.activo,
    required this.creadoEn,
    required this.actualizadoEn,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UsuarioModel(
      id: documentId,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      telefono: data['telefono'] ?? '',
      rol: data['rol'] ?? 'cliente',
      activo: data['activo'] ?? true,
      creadoEn: data['creado_en'] ?? Timestamp.now(),
      actualizadoEn: data['actualizado_en'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'rol': rol,
      'activo': activo,
      'creado_en': creadoEn,
      'actualizado_en': actualizadoEn,
    };
  }
}