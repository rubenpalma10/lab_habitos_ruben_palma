import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_habitos_ruben_palma/app.dart';

import '../fakes/fakes.dart';
import 'utilidades.dart';

Future<void> _iniciarSesion(WidgetTester tester) async {
  await tester.enterText(
    find.byKey(const Key('campo-correo')),
    FakeAuthRepository.correoValido,
  );
  await tester.enterText(
    find.byKey(const Key('campo-contrasena')),
    FakeAuthRepository.contrasenaValida,
  );
  await tester.tap(find.byKey(const Key('boton-ingresar')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('CP-20: login → marcar → historial → atrás → salir → volver a '
      'entrar', (tester) async {
    usarPantallaGrande(tester);
    final auth = FakeAuthRepository();
    final habitos = FakeHabitosRepository();

    await tester.pumpWidget(HabitosApp(auth: auth, habitos: habitos));
    await tester.pumpAndSettle();

    // Sin sesión: pantalla de login.
    expect(find.byKey(const Key('boton-ingresar')), findsOneWidget);

    // CP-02: iniciar sesión lleva al panel.
    await _iniciarSesion(tester);
    expect(find.text('Hábitos — Cumplidos: 0 / 5'), findsOneWidget);

    // Marcar un hábito.
    await tester.tap(find.text('Dormir 8 horas'));
    await tester.pump();
    expect(find.text('Hábitos — Cumplidos: 1 / 5'), findsOneWidget);

    // CP-05 / CP-06: historial y regreso.
    await tester.tap(find.byKey(const Key('boton-historial')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Historial'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Hábitos — Cumplidos: 1 / 5'), findsOneWidget);

    // CP-18: cerrar sesión vuelve al login y oculta los datos.
    await tester.tap(find.byKey(const Key('boton-cerrar-sesion')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('boton-ingresar')), findsOneWidget);
    expect(find.textContaining('Cumplidos'), findsNothing);

    // CP-19: al volver a entrar, el progreso sigue ahí.
    await _iniciarSesion(tester);
    expect(find.text('Hábitos — Cumplidos: 1 / 5'), findsOneWidget);
  });
}
