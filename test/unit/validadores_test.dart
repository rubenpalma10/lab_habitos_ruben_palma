import 'package:flutter_test/flutter_test.dart';
import 'package:lab_habitos_ruben_palma/data/auth_repository.dart';
import 'package:lab_habitos_ruben_palma/utils/validadores.dart';

void main() {
  group('validarCorreo', () {
    test('rechaza vacío o solo espacios', () {
      expect(validarCorreo(null), 'Ingresa tu correo');
      expect(validarCorreo(''), 'Ingresa tu correo');
      expect(validarCorreo('   '), 'Ingresa tu correo');
    });

    test('rechaza formatos inválidos', () {
      expect(validarCorreo('ruben'), 'Correo no válido');
      expect(validarCorreo('ruben@'), 'Correo no válido');
      expect(validarCorreo('ruben@correo'), 'Correo no válido');
      expect(validarCorreo('ru ben@correo.com'), 'Correo no válido');
    });

    test('acepta un correo válido aunque tenga espacios alrededor', () {
      expect(validarCorreo('prueba@demo.com'), isNull);
      expect(validarCorreo('  prueba@demo.com  '), isNull);
    });
  });

  group('validarContrasena', () {
    test('rechaza vacía', () {
      expect(validarContrasena(null), 'Ingresa tu contraseña');
      expect(validarContrasena(''), 'Ingresa tu contraseña');
    });

    test('rechaza menos de 6 caracteres', () {
      expect(
        validarContrasena('12345'),
        'La contraseña debe tener al menos 6 caracteres',
      );
    });

    test('acepta 6 o más caracteres', () {
      expect(validarContrasena('123456'), isNull);
    });
  });

  group('mensajeParaCodigoAuth', () {
    test('credenciales incorrectas dan un mensaje claro y único', () {
      const esperado = 'Correo o contraseña incorrectos.';
      expect(mensajeParaCodigoAuth('wrong-password'), esperado);
      expect(mensajeParaCodigoAuth('user-not-found'), esperado);
      expect(mensajeParaCodigoAuth('invalid-credential'), esperado);
    });

    test('sin red explica el problema', () {
      expect(
        mensajeParaCodigoAuth('network-request-failed'),
        contains('Sin conexión'),
      );
    });

    test('un código desconocido no se pierde', () {
      expect(mensajeParaCodigoAuth('algo-raro'), contains('algo-raro'));
    });
  });
}
