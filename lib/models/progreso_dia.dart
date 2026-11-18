/// Lista fija de hábitos del día (no cambia durante la ejecución).
const List<String> habitosDelDia = [
  'Beber 2 L de agua',
  'Leer 20 minutos',
  'Caminar 30 minutos',
  'Estudiar Flutter',
  'Dormir 8 horas',
];

int _limitar(int valor, int minimo, int maximo) {
  if (valor < minimo) return minimo;
  if (valor > maximo) return maximo;
  return valor;
}

/// Progreso de un día: qué hábitos se cumplieron, la meta y la nota.
///
/// Es una clase inmutable y sin dependencias de Flutter ni Firebase, para
/// poder probar toda la lógica con pruebas unitarias (INC-002).
class ProgresoDia {
  const ProgresoDia({
    required this.cumplidos,
    required this.meta,
    this.nota = '',
  });

  /// Día vacío: ningún hábito cumplido, meta inicial y sin nota.
  factory ProgresoDia.inicial({int totalHabitos = 5}) {
    return ProgresoDia(
      cumplidos: List<bool>.filled(totalHabitos, false),
      meta: _limitar(metaInicial, 1, totalHabitos < 1 ? 1 : totalHabitos),
    );
  }

  /// Reconstruye un día a partir de un documento de Firestore.
  ///
  /// Es tolerante a datos incompletos o de otra versión: ajusta la longitud
  /// de la lista al número de hábitos actual y limita la meta a un rango válido.
  factory ProgresoDia.fromMap(
    Map<String, dynamic> map, {
    int totalHabitos = 5,
  }) {
    final crudos = map['cumplidos'];
    final cumplidos = List<bool>.filled(totalHabitos, false);
    if (crudos is List) {
      for (var i = 0; i < totalHabitos && i < crudos.length; i++) {
        cumplidos[i] = crudos[i] == true;
      }
    }

    final maximo = totalHabitos < 1 ? 1 : totalHabitos;
    final metaCruda = map['meta'];
    final meta = metaCruda is num ? metaCruda.round() : metaInicial;

    final nota = map['nota'];

    return ProgresoDia(
      cumplidos: cumplidos,
      meta: _limitar(meta, 1, maximo),
      nota: nota is String ? nota : '',
    );
  }

  static const int metaInicial = 3;

  final List<bool> cumplidos;
  final int meta;
  final String nota;

  // ------------------------------------------------------------------
  // Información derivada (nunca se guarda: se calcula)
  // ------------------------------------------------------------------

  int get totalHabitos => cumplidos.length;

  int get totalCumplidos => cumplidos.where((c) => c).length;

  double get progreso => totalHabitos == 0 ? 0 : totalCumplidos / totalHabitos;

  int get porcentaje => (progreso * 100).round();

  bool get metaAlcanzada => totalCumplidos >= meta;

  String get mensaje {
    final p = porcentaje;
    if (p == 0) return '¡Empecemos!';
    if (p < 50) return 'Buen inicio';
    if (p < 100) return '¡Vas muy bien!';
    return '¡Día completado! 🎉';
  }

  // ------------------------------------------------------------------
  // Transformaciones (devuelven una copia; no mutan el original)
  // ------------------------------------------------------------------

  ProgresoDia alternar(int index) {
    if (index < 0 || index >= cumplidos.length) return this;
    final nuevos = List<bool>.of(cumplidos);
    nuevos[index] = !nuevos[index];
    return copyWith(cumplidos: nuevos);
  }

  ProgresoDia copyWith({List<bool>? cumplidos, int? meta, String? nota}) {
    return ProgresoDia(
      cumplidos: List<bool>.unmodifiable(cumplidos ?? this.cumplidos),
      meta: meta ?? this.meta,
      nota: nota ?? this.nota,
    );
  }

  Map<String, dynamic> toMap() => {
        'cumplidos': List<bool>.of(cumplidos),
        'meta': meta,
        'nota': nota,
      };
}
