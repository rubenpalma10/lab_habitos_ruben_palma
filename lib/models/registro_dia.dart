/// Un día ya cerrado, tal como se guarda en el historial.
class RegistroDia {
  const RegistroDia({
    required this.fecha,
    required this.cumplidos,
    required this.total,
    required this.meta,
    this.nota = '',
  });

  /// [map] debe traer `fecha` ya convertida a [DateTime] (o null mientras
  /// Firestore aún no asigna la marca de tiempo del servidor).
  factory RegistroDia.fromMap(Map<String, dynamic> map) {
    final fecha = map['fecha'];
    final cumplidos = map['cumplidos'];
    final total = map['total'];
    final meta = map['meta'];
    final nota = map['nota'];
    return RegistroDia(
      fecha: fecha is DateTime ? fecha : DateTime.now(),
      cumplidos: cumplidos is num ? cumplidos.round() : 0,
      total: total is num ? total.round() : 0,
      meta: meta is num ? meta.round() : 0,
      nota: nota is String ? nota : '',
    );
  }

  final DateTime fecha;
  final int cumplidos;
  final int total;
  final int meta;
  final String nota;

  bool get metaAlcanzada => cumplidos >= meta;

  /// Fecha en formato dd/mm/aaaa hh:mm (sin depender del paquete intl).
  String get fechaTexto {
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year} '
        '${dos(fecha.hour)}:${dos(fecha.minute)}';
  }

  Map<String, dynamic> toMap() => {
        'fecha': fecha,
        'cumplidos': cumplidos,
        'total': total,
        'meta': meta,
        'nota': nota,
      };
}
