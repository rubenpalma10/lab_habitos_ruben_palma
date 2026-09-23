import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 2 - Hábitos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const PanelHabitos(),
    );
  }
}

/// Pantalla principal del laboratorio.
///
/// Es un [StatefulWidget] (RT-1): todo el estado mutable vive en
/// [_PanelHabitosState] y toda modificación ocurre dentro de `setState()`.
class PanelHabitos extends StatefulWidget {
  const PanelHabitos({super.key});

  @override
  State<PanelHabitos> createState() => _PanelHabitosState();
}

class _PanelHabitosState extends State<PanelHabitos> {
  // --------------------------------------------------------------------
  // Datos fijos (no son estado: nunca cambian durante la vida del widget)
  // --------------------------------------------------------------------
  final List<String> _habitos = const [
    'Beber 2 L de agua',
    'Leer 20 minutos',
    'Caminar 30 minutos',
    'Estudiar Flutter',
    'Dormir 8 horas',
  ];

  static const int _metaInicial = 3;

  // --------------------------------------------------------------------
  // Estado (RT-2: cinco variables independientes)
  // --------------------------------------------------------------------

  /// Cumplimiento de cada hábito; el índice corresponde al de [_habitos].
  late List<bool> _cumplidos;

  /// Cuántos hábitos se propone cumplir la persona hoy (RF-5).
  int _meta = _metaInicial;

  /// Cuando está activo se ocultan los hábitos ya cumplidos (RF-6).
  bool _enfoque = false;

  /// Nota del día ya confirmada por la persona usuaria (RF-7).
  String _nota = '';

  /// Extensión opcional: cumplidos de cada "día" al reiniciar.
  final List<int> _historial = <int>[];

  /// Controlador del campo de texto; se libera en [dispose] (RT-9).
  final TextEditingController _notaCtrl = TextEditingController();

  // --------------------------------------------------------------------
  // Ciclo de vida
  // --------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _cumplidos = List<bool>.filled(_habitos.length, false);
    // Extensión opcional: habilitar/deshabilitar "Guardar nota" al escribir.
    _notaCtrl.addListener(_alCambiarTextoNota);
  }

  @override
  void dispose() {
    _notaCtrl.removeListener(_alCambiarTextoNota);
    _notaCtrl.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------
  // Información derivada (RT-4: getters, nunca estado duplicado)
  // --------------------------------------------------------------------

  int get _totalCumplidos => _cumplidos.where((c) => c).length;

  double get _progreso =>
      _habitos.isEmpty ? 0 : _totalCumplidos / _habitos.length;

  int get _porcentaje => (_progreso * 100).round();

  bool get _metaAlcanzada => _totalCumplidos >= _meta;

  /// El campo de texto está vacío (se lee del controlador, no se duplica).
  bool get _campoNotaVacio => _notaCtrl.text.trim().isEmpty;

  String get _mensaje {
    final p = _porcentaje;
    if (p == 0) return '¡Empecemos!';
    if (p < 50) return 'Buen inicio';
    if (p < 100) return '¡Vas muy bien!';
    return '¡Día completado! 🎉';
  }

  /// Extensión opcional: color de la barra por tramos.
  Color get _colorProgreso {
    if (_porcentaje == 100) return Colors.green;
    if (_porcentaje >= 50) return Colors.amber.shade700;
    return Colors.red;
  }

  // --------------------------------------------------------------------
  // Acciones (RT-3: toda mutación dentro de setState)
  // --------------------------------------------------------------------

  void _alternarHabito(int index) {
    setState(() => _cumplidos[index] = !_cumplidos[index]);
  }

  void _cambiarMeta(double v) {
    setState(() => _meta = v.round());
  }

  void _alternarEnfoque(bool v) {
    setState(() => _enfoque = v);
  }

  void _guardarNota() {
    setState(() => _nota = _notaCtrl.text.trim());
  }

  void _borrarNota() {
    setState(() {
      _nota = '';
      _notaCtrl.clear();
    });
  }

  void _alCambiarTextoNota() {
    if (!mounted) return;
    setState(() {});
  }

  void _reiniciarDia() {
    setState(() {
      _historial.add(_totalCumplidos);
      _cumplidos = List<bool>.filled(_habitos.length, false);
      _meta = _metaInicial;
      _enfoque = false;
      _nota = '';
      _notaCtrl.clear();
    });
  }

  // --------------------------------------------------------------------
  // Interfaz (RT-5: build solo describe la UI a partir del estado)
  // --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hábitos — Cumplidos: $_totalCumplidos / ${_habitos.length}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _construirProgreso(theme),
          const SizedBox(height: 20),
          _construirMeta(theme),
          const Divider(height: 24),
          SwitchListTile(
            title: const Text('Modo enfoque'),
            subtitle: const Text('Oculta los hábitos ya cumplidos'),
            value: _enfoque,
            onChanged: _alternarEnfoque,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 8),
          ..._construirListaHabitos(),
          const Divider(height: 24),
          _construirNota(theme),
          const SizedBox(height: 20),
          _construirHistorial(theme),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _reiniciarDia,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reiniciar día'),
            ),
          ),
        ],
      ),
    );
  }

  /// RF-3 y RF-4: barra de progreso, porcentaje y mensaje motivacional.
  Widget _construirProgreso(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progreso,
            minHeight: 14,
            color: _colorProgreso,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Progreso: $_porcentaje %',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          _mensaje,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: _colorProgreso,
          ),
        ),
      ],
    );
  }

  /// RF-5: slider de meta del día y distintivo "Meta alcanzada".
  Widget _construirMeta(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          value: _meta.toDouble(),
          min: 1,
          max: _habitos.length.toDouble(),
          divisions: _habitos.length - 1,
          label: '$_meta',
          onChanged: _cambiarMeta,
        ),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Meta: $_meta hábitos',
              style: theme.textTheme.titleMedium,
            ),
            if (_metaAlcanzada)
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

  /// RF-1 y RF-6: lista fija de hábitos, filtrada por el modo enfoque.
  List<Widget> _construirListaHabitos() {
    final tiles = <Widget>[];
    for (var i = 0; i < _habitos.length; i++) {
      if (_enfoque && _cumplidos[i]) continue;
      tiles.add(
        CheckboxListTile(
          value: _cumplidos[i],
          onChanged: (_) => _alternarHabito(i),
          title: Text(_habitos[i]),
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

  /// RF-7: campo de texto, guardado y tarjeta con la nota del día.
  Widget _construirNota(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nota del día', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
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
              // Extensión opcional: deshabilitado mientras el campo esté vacío.
              onPressed: _campoNotaVacio ? null : _guardarNota,
              icon: const Icon(Icons.save),
              label: const Text('Guardar nota'),
            ),
            OutlinedButton.icon(
              onPressed: _nota.isEmpty && _campoNotaVacio ? null : _borrarNota,
              icon: const Icon(Icons.backspace_outlined),
              label: const Text('Borrar nota'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.sticky_note_2_outlined),
            title: Text(_nota.isEmpty ? 'Sin nota' : _nota),
          ),
        ),
      ],
    );
  }

  /// Extensión opcional: historial de días reiniciados.
  Widget _construirHistorial(ThemeData theme) {
    if (_historial.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        'Días anteriores: ${_historial.join(', ')}',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
