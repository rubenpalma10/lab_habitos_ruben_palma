import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab_habitos_ruben_palma/main.dart';

/// Agranda la superficie de prueba para que toda la pantalla quede visible
/// dentro del ListView y se pueda interactuar con cualquier control.
void _usarPantallaGrande(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('P-1: marcar un hábito actualiza AppBar, barra y mensaje',
      (WidgetTester tester) async {
    _usarPantallaGrande(tester);
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hábitos — Cumplidos: 0 / 5'), findsOneWidget);
    expect(find.text('¡Empecemos!'), findsOneWidget);
    expect(find.text('Sin nota'), findsOneWidget);

    await tester.tap(find.text('Leer 20 minutos'));
    await tester.pump();

    expect(find.text('Hábitos — Cumplidos: 1 / 5'), findsOneWidget);
    expect(find.text('Buen inicio'), findsOneWidget);
    expect(find.text('Progreso: 20 %'), findsOneWidget);
  });

  testWidgets('P-6 y P-7: el modo enfoque oculta y vuelve a mostrar',
      (WidgetTester tester) async {
    _usarPantallaGrande(tester);
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Beber 2 L de agua'));
    await tester.pump();
    expect(find.text('Beber 2 L de agua'), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    expect(find.text('Beber 2 L de agua'), findsNothing);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    expect(find.text('Beber 2 L de agua'), findsOneWidget);
  });

  testWidgets('P-8: guardar la nota la muestra en la tarjeta',
      (WidgetTester tester) async {
    _usarPantallaGrande(tester);
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField), 'Día productivo');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Guardar nota'));
    await tester.pump();

    expect(find.text('Sin nota'), findsNothing);
    expect(find.text('Día productivo'), findsWidgets);
  });

  testWidgets('P-10: reiniciar día deja todo en el estado inicial',
      (WidgetTester tester) async {
    _usarPantallaGrande(tester);
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Caminar 30 minutos'));
    await tester.pump();
    expect(find.text('Hábitos — Cumplidos: 1 / 5'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Reiniciar día'));
    await tester.pump();

    expect(find.text('Hábitos — Cumplidos: 0 / 5'), findsOneWidget);
    expect(find.text('Meta: 3 hábitos'), findsOneWidget);
    expect(find.text('Sin nota'), findsOneWidget);
    expect(find.text('Días anteriores: 1'), findsOneWidget);
  });
}
