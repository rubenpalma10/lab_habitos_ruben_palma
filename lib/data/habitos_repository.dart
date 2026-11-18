import '../models/progreso_dia.dart';
import '../models/registro_dia.dart';

/// Contrato de persistencia de los hábitos. La UI depende solo de esta
/// interfaz; en producción la implementa Firestore y en pruebas un fake.
abstract class HabitosRepository {
  /// Devuelve el progreso guardado del día en curso, o null si no hay.
  Future<ProgresoDia?> cargarDia(String uid);

  /// Guarda el progreso del día en curso.
  Future<void> guardarDia(String uid, ProgresoDia dia);

  /// Archiva [dia] en el historial y deja el día en curso vacío.
  Future<void> cerrarDia(String uid, ProgresoDia dia);

  /// Días cerrados, del más reciente al más antiguo.
  Stream<List<RegistroDia>> historial(String uid);
}
