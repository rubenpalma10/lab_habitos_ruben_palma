import 'package:flutter_test/flutter_test.dart';
import 'package:lab_habitos_ruben_palma/models/progreso_dia.dart';

ProgresoDia _conCumplidos(int n) {
  var dia = ProgresoDia.inicial();
  for (var i = 0; i < n; i++) {
    dia = dia.alternar(i);
  }
  return dia;
}

void main() {
  group('ProgresoDia (INC-002: lógica extraída del widget)', () {
    test('el día inicial no tiene cumplidos, meta 3 y sin nota', () {
      final dia = ProgresoDia.inicial();

      expect(dia.totalHabitos, 5);
      expect(dia.totalCumplidos, 0);
      expect(dia.porcentaje, 0);
      expect(dia.meta, ProgresoDia.metaInicial);
      expect(dia.nota, '');
      expect(dia.mensaje, '¡Empecemos!');
      expect(dia.metaAlcanzada, isFalse);
    });

    test('porcentaje y mensaje cambian por tramos', () {
      expect(_conCumplidos(1).porcentaje, 20);
      expect(_conCumplidos(1).mensaje, 'Buen inicio');

      expect(_conCumplidos(2).porcentaje, 40);
      expect(_conCumplidos(2).mensaje, 'Buen inicio');

      expect(_conCumplidos(3).porcentaje, 60);
      expect(_conCumplidos(3).mensaje, '¡Vas muy bien!');

      expect(_conCumplidos(5).porcentaje, 100);
      expect(_conCumplidos(5).mensaje, '¡Día completado! 🎉');
    });

    test('la meta se alcanza al llegar exactamente a ella', () {
      expect(_conCumplidos(2).metaAlcanzada, isFalse);
      expect(_conCumplidos(3).metaAlcanzada, isTrue);
      expect(_conCumplidos(1).copyWith(meta: 1).metaAlcanzada, isTrue);
    });

    test('alternar devuelve una copia y no modifica el original', () {
      final original = ProgresoDia.inicial();
      final cambiado = original.alternar(2);

      expect(original.totalCumplidos, 0);
      expect(cambiado.cumplidos[2], isTrue);
      expect(cambiado.alternar(2).totalCumplidos, 0);
    });

    test('alternar con un índice fuera de rango no hace nada', () {
      final dia = ProgresoDia.inicial();
      expect(dia.alternar(-1).totalCumplidos, 0);
      expect(dia.alternar(99).totalCumplidos, 0);
    });

    test('toMap y fromMap conservan los datos (ida y vuelta)', () {
      final dia = _conCumplidos(2).copyWith(meta: 4, nota: 'Buen día');
      final restaurado = ProgresoDia.fromMap(dia.toMap());

      expect(restaurado.cumplidos, dia.cumplidos);
      expect(restaurado.meta, 4);
      expect(restaurado.nota, 'Buen día');
    });

    test('fromMap tolera datos incompletos o fuera de rango', () {
      final dia = ProgresoDia.fromMap({
        'cumplidos': [true, 'x', null],
        'meta': 99,
      });

      expect(dia.totalHabitos, 5);
      expect(dia.cumplidos, [true, false, false, false, false]);
      expect(dia.meta, 5);
      expect(dia.nota, '');

      final vacio = ProgresoDia.fromMap(const {});
      expect(vacio.totalCumplidos, 0);
      expect(vacio.meta, ProgresoDia.metaInicial);
    });
  });
}
