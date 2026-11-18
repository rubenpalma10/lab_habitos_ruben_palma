/// Error de autenticación con un mensaje listo para mostrar al usuario.
class AuthException implements Exception {
  const AuthException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Contrato de autenticación. La app solo conoce esta interfaz, de modo que
/// en las pruebas se puede reemplazar Firebase por un fake.
abstract class AuthRepository {
  /// Emite el uid del usuario con sesión iniciada, o null si no hay sesión.
  Stream<String?> get cambiosDeUsuario;

  /// Correo del usuario actual (para mostrarlo en la UI), o null.
  String? get correoActual;

  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  Future<void> registrarse({
    required String correo,
    required String contrasena,
  });

  Future<void> cerrarSesion();
}

/// Traduce los códigos de error de Firebase Auth a mensajes claros.
String mensajeParaCodigoAuth(String codigo) {
  switch (codigo) {
    case 'invalid-email':
      return 'El correo no tiene un formato válido.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
    case 'INVALID_LOGIN_CREDENTIALS':
      return 'Correo o contraseña incorrectos.';
    case 'email-already-in-use':
      return 'Ya existe una cuenta con ese correo.';
    case 'weak-password':
      return 'La contraseña es muy débil (mínimo 6 caracteres).';
    case 'user-disabled':
      return 'Esta cuenta está deshabilitada.';
    case 'too-many-requests':
      return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
    case 'network-request-failed':
      return 'Sin conexión. Revisa tu internet e intenta de nuevo.';
    case 'operation-not-allowed':
      return 'El acceso con correo no está habilitado en Firebase.';
    default:
      return 'No se pudo completar la operación ($codigo).';
  }
}
