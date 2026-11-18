// Prueba de integración del flujo principal en un emulador o dispositivo.
//
// Usa los mismos fakes que las pruebas de widget, así que no necesita
// conexión ni usuarios reales de Firebase. Ejecutar con:
//
//     flutter test integration_test -d <id-del-emulador>
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lab_habitos_ruben_palma/app.dart';

import '../test/fakes/fakes.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Flujo 1 y 2: iniciar sesión, marcar hábitos y cerrar el día',
      (tester) async {
    final auth = FakeAuthRepository();
    final habitos = FakeHabitosRepository();

    await tester.pumpWidget(HabitosApp(auth: auth, habitos: habitos));
    await tester.pumpAndSettle();

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

    await tester.tap(find.text('Beber 2 L de agua'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Leer 20 minutos'));
    await tester.pumpAndSettle();
    expect(find.text('Hábitos — Cumplidos: 2 / 5'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('boton-reiniciar')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('boton-reiniciar')));
    await tester.pumpAndSettle();
    expect(habitos.cerrados, 1);

    await tester.tap(find.byKey(const Key('boton-historial')));
    await tester.pumpAndSettle();
    expect(find.text('2 / 5 hábitos'), findsOneWidget);
  });
}
