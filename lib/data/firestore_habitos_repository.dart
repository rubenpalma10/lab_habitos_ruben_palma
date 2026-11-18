import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/progreso_dia.dart';
import '../models/registro_dia.dart';
import 'habitos_repository.dart';

/// Implementación de [HabitosRepository] con Cloud Firestore.
///
/// Estructura de datos (cada usuario solo ve lo suyo, ver firestore.rules):
///
///     usuarios/{uid}/estado/dia_actual      -> ProgresoDia
///     usuarios/{uid}/historial/{autoId}     -> RegistroDia
class FirestoreHabitosRepository implements HabitosRepository {
  FirestoreHabitosRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _diaRef(String uid) => _db
      .collection('usuarios')
      .doc(uid)
      .collection('estado')
      .doc('dia_actual');

  CollectionReference<Map<String, dynamic>> _historialRef(String uid) =>
      _db.collection('usuarios').doc(uid).collection('historial');

  @override
  Future<ProgresoDia?> cargarDia(String uid) async {
    final snap = await _diaRef(uid).get();
    final data = snap.data();
    if (data == null) return null;
    return ProgresoDia.fromMap(data, totalHabitos: habitosDelDia.length);
  }

  @override
  Future<void> guardarDia(String uid, ProgresoDia dia) {
    return _diaRef(uid).set({
      ...dia.toMap(),
      'actualizado': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> cerrarDia(String uid, ProgresoDia dia) {
    final lote = _db.batch();
    lote.set(_historialRef(uid).doc(), {
      'fecha': FieldValue.serverTimestamp(),
      'cumplidos': dia.totalCumplidos,
      'total': dia.totalHabitos,
      'meta': dia.meta,
      'nota': dia.nota,
    });
    lote.set(_diaRef(uid), {
      ...ProgresoDia.inicial(totalHabitos: dia.totalHabitos).toMap(),
      'actualizado': FieldValue.serverTimestamp(),
    });
    return lote.commit();
  }

  @override
  Stream<List<RegistroDia>> historial(String uid) {
    return _historialRef(uid)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(
          (consulta) => consulta.docs.map((doc) {
            final data = doc.data();
            final fecha = data['fecha'];
            return RegistroDia.fromMap({
              ...data,
              'fecha': fecha is Timestamp ? fecha.toDate() : null,
            });
          }).toList(),
        );
  }
}
