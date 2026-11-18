import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_habitos_ruben_palma/data/auth_repository.dart';
import 'package:lab_habitos_ruben_palma/screens/login_screen.dart';

import '../fakes/fakes.dart';

Future<void> _montar(WidgetTester tester, FakeAuthRepository auth) {
  return tester.pumpWidget(MaterialApp(home: LoginScreen(auth: auth)));
}

Future<void> _llenar(WidgetTester tester, String correo, String clave) async {
  await tester.enterText(find.byKey(const Key('campo-correo')), correo);
  await tester.enterText(find.byKey(const Key('campo-contrasena')), clave);
}

void main() {
  testWidgets('CP-04: formulario vacío muestra validaciones y no llama al '
      'servicio', (tester) async {
    final auth = FakeAuthRepository();
    await _montar(tester, auth);

    await tester.tap(find.byKey(const Key('boton-ingresar')));
    await tester.pump();

    expect(find.text('Ingresa tu correo'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    expect(auth.llamadasIniciar, 0);
  });

  testWidgets('CP-04b: correo mal escrito y contraseña corta no llaman al '
      'servicio', (tester) async {
    final auth = FakeAuthRepository();
    await _montar(tester, auth);

    await _llenar(tester, 'ruben@correo', '123');
    await tester.tap(find.byKey(const Key('boton-ingresar')));
    await tester.pump();

    expect(find.text('Correo no válido'), findsOneWidget);
    expect(
      find.text('La contraseña debe tener al menos 6 caracteres'),
      findsOneWidget,
    );
    expect(auth.llamadasIniciar, 0);
  });

  testWidgets('CP-03: contraseña incorrecta muestra un mensaje claro y sigue '
      'en login', (tester) async {
    final auth = FakeAuthRepository();
    await _montar(tester, auth);

    await _llenar(tester, FakeAuthRepository.correoValido, 'incorrecta');
    await tester.tap(find.byKey(const Key('boton-ingresar')));
    await tester.pumpAndSettle();

    expect(auth.llamadasIniciar, 1);
    expect(find.byKey(const Key('mensaje-error-auth')), findsOneWidget);
    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    expect(find.byKey(const Key('boton-ingresar')), findsOneWidget);
  });

  testWidgets('CP-12 (auth): sin red se informa y no se cierra la app',
      (tester) async {
    final auth = FakeAuthRepository(
      errorAlIniciar: AuthException(
        mensajeParaCodigoAuth('network-request-failed'),
      ),
    );
    await _montar(tester, auth);

    await _llenar(
      tester,
      FakeAuthRepository.correoValido,
      FakeAuthRepository.contrasenaValida,
    );
    await tester.tap(find.byKey(const Key('boton-ingresar')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Sin conexión'), findsOneWidget);
  });

  testWidgets('CP-02: credenciales válidas llaman una vez al servicio sin '
      'mostrar error', (tester) async {
    final auth = FakeAuthRepository();
    await _montar(tester, auth);

    await _llenar(
      tester,
      FakeAuthRepository.correoValido,
      FakeAuthRepository.contrasenaValida,
    );
    await tester.tap(find.byKey(const Key('boton-ingresar')));
    await tester.pumpAndSettle();

    expect(auth.llamadasIniciar, 1);
    expect(find.byKey(const Key('mensaje-error-auth')), findsNothing);
  });

  testWidgets('el enlace cambia entre iniciar sesión y crear cuenta',
      (tester) async {
    await _montar(tester, FakeAuthRepository());

    expect(find.text('Ingresar'), findsOneWidget);
    await tester.tap(find.byKey(const Key('boton-cambiar-modo')));
    await tester.pump();
    expect(find.widgetWithText(AppBar, 'Crear cuenta'), findsOneWidget);
  });
}
