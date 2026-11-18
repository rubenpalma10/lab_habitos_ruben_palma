import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../data/habitos_repository.dart';
import '../models/progreso_dia.dart';
import 'historial_screen.dart';

/// Pantalla principal: hábitos del día del usuario con sesión iniciada.
///
/// El progreso se carga de [HabitosRepository] al abrir y se guarda en cada
/// cambio, para que sobreviva a cerrar y reabrir la app (INC-001).
class PanelHabitosScreen extends StatefulWidget {
  const PanelHabitosScreen({
    super.key,
    required this.uid,
    required this.auth,
    required this.habitos,
  });

  final String uid;
  final AuthRepository auth;
  final HabitosRepository habitos;

  @override
  State<PanelHabitosScreen> createState() => _PanelHabitosScreenState();
}

class _PanelHabitosScreenState extends State<PanelHabitosScreen> {
  // --------------------------------------------------------------------
  // Estado
  // --------------------------------------------------------------------

  /// Progreso del día; null mientras se carga o si la carga falló.
  ProgresoDia? _dia;

  bool _cargando = true;
  String? _errorCarga;

  /// Preferencia de vista; no se persiste.
  bool _enfoque = false;

  final TextEditingController _notaCtrl = TextEditingController();

  // --------------------------------------------------------------------
  // Ciclo de vida
  // --------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _notaCtrl.addListener(_alCambiarTextoNota);
    _cargar();
  }

  @override
  void dispose() {
    _notaCtrl.removeListener(_alCambiarTextoNota);
    _notaCtrl.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------
  // Datos
  // --------------------------------------------------------------------

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });
    try {
      final guardado = await widget.habitos.cargarDia(widget.uid);
      if (!mounted) return;
      setState(() {
        _dia = guardado ??
            ProgresoDia.inicial(totalHabitos: habitosDelDia.length);
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorCarga = 'No se pudo cargar tu progreso.\n'
            'Revisa tu conexión e intenta de nuevo.';
        _cargando = false;
      });
    }
  }

  /// Cambia el estado en pantalla y, si [guardar] es true, lo persiste.
  void _actualizar(ProgresoDia nuevo, {bool guardar = true}) {
    setState(() => _dia = nuevo);
    if (guardar) _guardar(nuevo);
  }

  Future<void> _guardar(ProgresoDia dia) async {
    try {
      await widget.habitos.guardarDia(widget.uid, dia);
    } catch (_) {
      _avisar('No se pudo guardar el cambio. Revisa tu conexión.');
    }
  }

  void _avisar(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // --------------------------------------------------------------------
  // Acciones
  // --------------------------------------------------------------------

  void _alternarHabito(int index) => _actualizar(_dia!.alternar(index));

  /// Mientras se arrastra solo se actualiza la UI...
  void _moverMeta(double v) =>
      _actualizar(_dia!.copyWith(meta: v.round()), guardar: false);

  /// ...y se guarda una sola vez al soltar el slider.
  void _soltarMeta(double v) => _actualizar(_dia!.copyWith(meta: v.round()));

  void _alternarEnfoque(bool v) => setState(() => _enfoque = v);

  void _guardarNota() {
    _actualizar(_dia!.copyWith(nota: _notaCtrl.text.trim()));
  }

  void _borrarNota() {
    _notaCtrl.clear();
    _actualizar(_dia!.copyWith(nota: ''));
  }

  void _alCambiarTextoNota() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _reiniciarDia() async {
    final cerrado = _dia!;
    setState(() {
      _dia = ProgresoDia.inicial(totalHabitos: habitosDelDia.length);
      _enfoque = false;
      _notaCtrl.clear();
    });
    try {
      await widget.habitos.cerrarDia(widget.uid, cerrado);
    } catch (_) {
      _avisar('No se pudo guardar el día en el historial.');
    }
  }

  void _abrirHistorial() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            HistorialScreen(uid: widget.uid, habitos: widget.habitos),
      ),
    );
  }

  Future<void> _cerrarSesion() => widget.auth.cerrarSesion();

  // --------------------------------------------------------------------
  // Interfaz
  // --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final dia = _dia;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          dia == null
              ? 'Hábitos'
              : 'Hábitos — Cumplidos: ${dia.totalCumplidos} / ${dia.totalHabitos}',
        ),
        actions: [
          IconButton(
            key: const Key('boton-historial'),
            tooltip: 'Historial',
            icon: const Icon(Icons.history),
            onPressed: _abrirHistorial,
          ),
          IconButton(
            key: const Key('boton-cerrar-sesion'),
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: _construirCuerpo(context),
    );
  }

  Widget _construirCuerpo(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    final dia = _dia;
    if (_errorCarga != null || dia == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 12),
              Text(
                _errorCarga ?? 'Sin datos',
                key: const Key('panel-error'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                key: const Key('boton-reintentar'),
                onPressed: _cargar,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final correo = widget.auth.correoActual;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        if (correo != null) ...[
          Text('Sesión: $correo', style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
        ],
        _construirProgreso(theme, dia),
        const SizedBox(height: 20),
        _construirMeta(theme, dia),
        const Divider(height: 24),
        SwitchListTile(
          title: const Text('Modo enfoque'),
          subtitle: const Text('Oculta los hábitos ya cumplidos'),
          value: _enfoque,
          onChanged: _alternarEnfoque,
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(height: 8),
        ..._construirListaHabitos(dia),
        const Divider(height: 24),
        _construirNota(theme, dia),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('boton-reiniciar'),
            onPressed: _reiniciarDia,
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reiniciar día'),
          ),
        ),
      ],
    );
  }

  Color _colorProgreso(ProgresoDia dia) {
    if (dia.porcentaje == 100) return Colors.green;
    if (dia.porcentaje >= 50) return Colors.amber.shade700;
    return Colors.red;
  }

  Widget _construirProgreso(ThemeData theme, ProgresoDia dia) {
    final color = _colorProgreso(dia);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: dia.progreso,
            minHeight: 14,
            color: color,
          ),
        ),
        const SizedBox(height: 10),
        Text('Progreso: ${dia.porcentaje} %', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          dia.mensaje,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _construirMeta(ThemeData theme, ProgresoDia dia) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          value: dia.meta.toDouble(),
          min: 1,
          max: dia.totalHabitos.toDouble(),
          divisions: dia.totalHabitos - 1,
          label: '${dia.meta}',
          onChanged: _moverMeta,
          onChangeEnd: _soltarMeta,
        ),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('Meta: ${dia.meta} hábitos', style: theme.textTheme.titleMedium),
            if (dia.metaAlcanzada)
              const Chip(
                avatar: Icon(Icons.check_circle, size: 18, color: Colors.green),
                label: Text('Meta alcanzada'),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _construirListaHabitos(ProgresoDia dia) {
    final tiles = <Widget>[];
    for (var i = 0; i < habitosDelDia.length && i < dia.totalHabitos; i++) {
      if (_enfoque && dia.cumplidos[i]) continue;
      tiles.add(
        CheckboxListTile(
          value: dia.cumplidos[i],
          onChanged: (_) => _alternarHabito(i),
          title: Text(habitosDelDia[i]),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      );
    }
    if (tiles.isEmpty) {
      tiles.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text('No queda nada pendiente. ¡Excelente trabajo!'),
          ),
        ),
      );
    }
    return tiles;
  }

  Widget _construirNota(ThemeData theme, ProgresoDia dia) {
    final campoVacio = _notaCtrl.text.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nota del día', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          key: const Key('campo-nota'),
          controller: _notaCtrl,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _guardarNota(),
          decoration: const InputDecoration(
            labelText: '¿Cómo te fue hoy?',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              key: const Key('boton-guardar-nota'),
              onPressed: campoVacio ? null : _guardarNota,
              icon: const Icon(Icons.save),
              label: const Text('Guardar nota'),
            ),
            OutlinedButton.icon(
              key: const Key('boton-borrar-nota'),
              onPressed: dia.nota.isEmpty && campoVacio ? null : _borrarNota,
              icon: const Icon(Icons.backspace_outlined),
              label: const Text('Borrar nota'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.sticky_note_2_outlined),
            title: Text(dia.nota.isEmpty ? 'Sin nota' : dia.nota),
          ),
        ),
      ],
    );
  }
}
