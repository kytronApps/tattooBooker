import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 Iniciar sesión del administrador
  Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Login correcto: ${cred.user?.email}');
      return cred.user;
    } on FirebaseAuthException catch (e) {
      print('⚠️ Error de login: ${e.message}');
      return null;
    }
  }

  /// 🔹 Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
    print('👋 Sesión cerrada');
  }

  /// 🔹 Obtener usuario actual (si hay sesión abierta)
  User? get usuarioActual => _auth.currentUser;
}