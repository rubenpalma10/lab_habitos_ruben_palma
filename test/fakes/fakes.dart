import 'dart:async';

import 'package:lab_habitos_ruben_palma/data/auth_repository.dart';
import 'package:lab_habitos_ruben_palma/data/habitos_repository.dart';
import 'package:lab_habitos_ruben_palma/models/progreso_dia.dart';
import 'package:lab_habitos_ruben_palma/models/registro_dia.dart';

/// Autenticación en memoria: no toca Firebase.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({String? uidInicial, this.errorAlIniciar})
      : _uid = uidInicial;

  /// Usuario y contraseña que el fake acepta como válidos.
  static const correoValido = 'prueba@demo.com';
  static const contrasenaValida = 'secreta123';

  final _cambios = StreamController<String?>.broadcast();
  String? _uid;
  String? _correo;

  /// Si se define, [iniciarSesion] lanza este error (p. ej. sin red).
  AuthException? errorAlIniciar;

  int llamadasIniciar = 0;
  int llamadasRegistrar = 0;
  int llamadasCerrar = 0;

  @override
  Stream<String?> get cambiosDeUsuario async* {
    yield _uid;
    yield* _cambios.stream;
  }

  @override
  String? get correoActual => _uid == null ? null : _correo;

  @override
  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    llamadasIniciar++;
    if (errorAlIniciar != null) throw errorAlIniciar!;
    if (correo.trim() != correoValido || contrasena != contrasenaValida) {
      throw AuthException(mensajeParaCodigoAuth('invalid-credential'));
    }
    _iniciar(correo.trim());
  }

  @override
  Future<void> registrarse({
    required String correo,
    required String contrasena,
  }) async {
    llamadasRegistrar++;
    _iniciar(correo.trim());
  }

  @override
  Future<void> cerrarSesion() async {
    llamadasCerrar++;
    _uid = null;
    _correo = null;
    _cambios.add(null);
  }

  void _iniciar(String correo) {
    _uid = 'uid-${correo.hashCode}';
    _correo = correo;
    _cambios.add(_uid);
  }
}

/// Persistencia en memoria que imita a Firestore.
class FakeHabitosRepository implements HabitosRepository {
  final Map<String, ProgresoDia> dias = {};
  final Map<String, List<RegistroDia>> historiales = {};

  bool fallarAlCargar = false;
  bool fallarHistorial = false;

  int guardados = 0;
  int cerrados = 0;

  @override
  Future<ProgresoDia?> cargarDia(String uid) async {
    if (fallarAlCargar) throw Exception('Sin conexión');
    return dias[uid];
  }

  @override
  Future<void> guardarDia(String uid, ProgresoDia dia) async {
    guardados++;
    dias[uid] = dia;
  }

  @override
  Future<void> cerrarDia(String uid, ProgresoDia dia) async {
    cerrados++;
    historiales.putIfAbsent(uid, () => []).insert(
          0,
          RegistroDia(
            fecha: DateTime(2026, 11, 16, 20, 30),
            cumplidos: dia.totalCumplidos,
            total: dia.totalHabitos,
            meta: dia.meta,
            nota: dia.nota,
          ),
        );
    dias[uid] = ProgresoDia.inicial(totalHabitos: dia.totalHabitos);
  }

  @override
  Stream<List<RegistroDia>> historial(String uid) {
    if (fallarHistorial) return Stream.error(Exception('Sin conexión'));
    return Stream.value(
      List<RegistroDia>.unmodifiable(historiales[uid] ?? const <RegistroDia>[]),
    );
  }
}
