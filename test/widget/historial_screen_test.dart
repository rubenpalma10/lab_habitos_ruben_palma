import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_habitos_ruben_palma/models/registro_dia.dart';
import 'package:lab_habitos_ruben_palma/screens/historial_screen.dart';

import '../fakes/fakes.dart';

Future<void> _montar(WidgetTester tester, FakeHabitosRepository repo) async {
  await tester.pumpWidget(
    MaterialApp(home: HistorialScreen(uid: 'u1', habitos: repo)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('CP-12: sin días muestra el estado vacío', (tester) async {
    await _montar(tester, FakeHabitosRepository());

    expect(find.byKey(const Key('historial-vacio')), findsOneWidget);
    expect(find.byKey(const Key('lista-historial')), findsNothing);
  });

  testWidgets('CP-08: con datos muestra la lista de días', (tester) async {
    final repo = FakeHabitosRepository()
      ..historiales['u1'] = [
        RegistroDia(
          fecha: DateTime(2026, 11, 16, 20, 30),
          cumplidos: 3,
          total: 5,
          meta: 3,
          nota: 'Buen día',
        ),
        RegistroDia(
          fecha: DateTime(2026, 11, 15, 21, 5),
          cumplidos: 1,
          total: 5,
          meta: 4,
        ),
      ];
    await _montar(tester, repo);

    expect(find.byKey(const Key('lista-historial')), findsOneWidget);
    expect(find.text('3 / 5 hábitos'), findsOneWidget);
    expect(find.text('16/11/2026 20:30 · Buen día'), findsOneWidget);
    expect(find.text('1 / 5 hábitos'), findsOneWidget);
    expect(find.text('15/11/2026 21:05'), findsOneWidget);
  });

  testWidgets('CP-12: error de red muestra un mensaje sin cerrar la app',
      (tester) async {
    final repo = FakeHabitosRepository()..fallarHistorial = true;
    await _montar(tester, repo);

    expect(find.byKey(const Key('historial-error')), findsOneWidget);
  });
}
