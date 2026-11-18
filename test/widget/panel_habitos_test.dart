import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_habitos_ruben_palma/models/progreso_dia.dart';
import 'package:lab_habitos_ruben_palma/screens/panel_habitos_screen.dart';

import '../fakes/fakes.dart';
import 'utilidades.dart';

const _uid = 'u1';

Future<void> _montarPanel(
  WidgetTester tester,
  FakeHabitosRepository repo, {
  FakeAuthRepository? auth,
}) async {
  usarPantallaGrande(tester);
  await tester.pumpWidget(
    MaterialApp(
      home: PanelHabitosScreen(
        uid: _uid,
        auth: auth ?? FakeAuthRepository(uidInicial: _uid),
        habitos: repo,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('P-1: marcar un hábito actualiza AppBar, barra y mensaje',
      (tester) async {
    await _montarPanel(tester, FakeHabitosRepository());

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
      (tester) async {
    await _montarPanel(tester, FakeHabitosRepository());

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

  testWidgets('P-8 / CP-09: guardar la nota la muestra y la persiste',
      (tester) async {
    final repo = FakeHabitosRepository();
    await _montarPanel(tester, repo);

    await tester.enterText(find.byKey(const Key('campo-nota')), 'Día productivo');
    await tester.pump();
    await tester.tap(find.byKey(const Key('boton-guardar-nota')));
    await tester.pump();

    expect(find.text('Sin nota'), findsNothing);
    expect(find.text('Día productivo'), findsWidgets);
    expect(repo.dias[_uid]?.nota, 'Día productivo');
  });

  testWidgets('P-10 / CP-07: reiniciar día lo archiva en el historial y deja '
      'todo en el estado inicial', (tester) async {
    final repo = FakeHabitosRepository();
    await _montarPanel(tester, repo);

    await tester.tap(find.text('Caminar 30 minutos'));
    await tester.pump();
    expect(find.text('Hábitos — Cumplidos: 1 / 5'), findsOneWidget);

    await tester.tap(find.byKey(const Key('boton-reiniciar')));
    await tester.pumpAndSettle();

    expect(find.text('Hábitos — Cumplidos: 0 / 5'), findsOneWidget);
    expect(find.text('Meta: 3 hábitos'), findsOneWidget);
    expect(find.text('Sin nota'), findsOneWidget);
    expect(repo.cerrados, 1);
    expect(repo.historiales[_uid]?.first.cumplidos, 1);
  });

  testWidgets('INC-001 (regresión): el progreso sobrevive a cerrar y reabrir '
      'la pantalla', (tester) async {
    final repo = FakeHabitosRepository();
    await _montarPanel(tester, repo);

    await tester.tap(find.text('Beber 2 L de agua'));
    await tester.pump();
    await tester.tap(find.text('Estudiar Flutter'));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('campo-nota')), 'Persistente');
    await tester.pump();
    await tester.tap(find.byKey(const Key('boton-guardar-nota')));
    await tester.pump();

    // "Cerrar la app": se desmonta todo el árbol de widgets.
    await tester.pumpWidget(const SizedBox.shrink());
    expect(find.byType(PanelHabitosScreen), findsNothing);

    // "Reabrir la app" con el mismo almacenamiento.
    await _montarPanel(tester, repo);

    expect(find.text('Hábitos — Cumplidos: 2 / 5'), findsOneWidget);
    expect(find.text('Persistente'), findsOneWidget);
  });

  testWidgets('CP-08: muestra el progreso guardado previamente', (tester) async {
    final repo = FakeHabitosRepository()
      ..dias[_uid] = ProgresoDia.inicial().alternar(0).copyWith(meta: 1);
    await _montarPanel(tester, repo);

    expect(find.text('Hábitos — Cumplidos: 1 / 5'), findsOneWidget);
    expect(find.text('Meta: 1 hábitos'), findsOneWidget);
    expect(find.text('Meta alcanzada'), findsOneWidget);
  });

  testWidgets('CP-12: error al cargar muestra mensaje y permite reintentar',
      (tester) async {
    final repo = FakeHabitosRepository()..fallarAlCargar = true;
    await _montarPanel(tester, repo);

    expect(find.byKey(const Key('panel-error')), findsOneWidget);
    expect(find.byKey(const Key('boton-reintentar')), findsOneWidget);

    repo.fallarAlCargar = false;
    await tester.tap(find.byKey(const Key('boton-reintentar')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('panel-error')), findsNothing);
    expect(find.text('Hábitos — Cumplidos: 0 / 5'), findsOneWidget);
  });

  testWidgets('CP-05 y CP-06: abre el historial y regresa con "atrás"',
      (tester) async {
    await _montarPanel(tester, FakeHabitosRepository());

    await tester.tap(find.byKey(const Key('boton-historial')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Historial'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Hábitos — Cumplidos: 0 / 5'), findsOneWidget);
  });

  testWidgets('el botón de salir llama a cerrar sesión', (tester) async {
    final auth = FakeAuthRepository(uidInicial: _uid);
    await _montarPanel(tester, FakeHabitosRepository(), auth: auth);

    await tester.tap(find.byKey(const Key('boton-cerrar-sesion')));
    await tester.pump();

    expect(auth.llamadasCerrar, 1);
  });
}
