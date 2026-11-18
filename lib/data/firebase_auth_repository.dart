import 'package:firebase_auth/firebase_auth.dart';

import 'auth_repository.dart';

/// Implementación real de [AuthRepository] con Firebase Authentication
/// (correo y contraseña).
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Stream<String?> get cambiosDeUsuario =>
      _auth.authStateChanges().map((usuario) => usuario?.uid);

  @override
  String? get correoActual => _auth.currentUser?.email;

  @override
  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(mensajeParaCodigoAuth(e.code));
    }
  }

  @override
  Future<void> registrarse({
    required String correo,
    required String contrasena,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: correo.trim(),
        password: contrasena,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(mensajeParaCodigoAuth(e.code));
    }
  }

  @override
  Future<void> cerrarSesion() => _auth.signOut();
}
