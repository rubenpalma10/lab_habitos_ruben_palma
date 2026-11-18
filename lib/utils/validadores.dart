final RegExp _formatoCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Valida el correo del formulario de acceso. Devuelve null si es válido.
String? validarCorreo(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) return 'Ingresa tu correo';
  if (!_formatoCorreo.hasMatch(texto)) return 'Correo no válido';
  return null;
}

/// Valida la contraseña (Firebase Auth exige al menos 6 caracteres).
String? validarContrasena(String? valor) {
  final texto = valor ?? '';
  if (texto.isEmpty) return 'Ingresa tu contraseña';
  if (texto.length < 6) {
    return 'La contraseña debe tener al menos 6 caracteres';
  }
  return null;
}
