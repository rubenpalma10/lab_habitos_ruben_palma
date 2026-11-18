import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Agranda la superficie de prueba para que toda la pantalla quede visible
/// dentro del ListView y se pueda interactuar con cualquier control.
void usarPantallaGrande(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
