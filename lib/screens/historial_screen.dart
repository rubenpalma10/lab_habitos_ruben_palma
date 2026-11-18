import 'package:flutter/material.dart';

import '../data/habitos_repository.dart';
import '../models/registro_dia.dart';

/// Lista de días cerrados del usuario, leída en tiempo real de Firestore.
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key, required this.uid, required this.habitos});

  final String uid;
  final HabitosRepository habitos;

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  // Se crea una sola vez para que StreamBuilder no se re-suscriba en cada build.
  late final Stream<List<RegistroDia>> _historial =
      widget.habitos.historial(widget.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: StreamBuilder<List<RegistroDia>>(
        stream: _historial,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _MensajeCentrado(
              key: Key('historial-error'),
              icono: Icons.cloud_off,
              texto: 'No se pudo cargar el historial.\n'
                  'Revisa tu conexión e intenta de nuevo.',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final dias = snapshot.data!;
          if (dias.isEmpty) {
            return const _MensajeCentrado(
              key: Key('historial-vacio'),
              icono: Icons.history_toggle_off,
              texto: 'Aún no tienes días registrados.\n'
                  'Usa "Reiniciar día" en el panel para cerrar un día.',
            );
          }
          return ListView.separated(
            key: const Key('lista-historial'),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: dias.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final dia = dias[i];
              return ListTile(
                leading: Icon(
                  dia.metaAlcanzada ? Icons.check_circle : Icons.circle_outlined,
                  color: dia.metaAlcanzada ? Colors.green : null,
                ),
                title: Text('${dia.cumplidos} / ${dia.total} hábitos'),
                subtitle: Text(
                  dia.nota.isEmpty
                      ? dia.fechaTexto
                      : '${dia.fechaTexto} · ${dia.nota}',
                ),
                trailing: Text('Meta ${dia.meta}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _MensajeCentrado extends StatelessWidget {
  const _MensajeCentrado({super.key, required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 48),
            const SizedBox(height: 12),
            Text(texto, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
