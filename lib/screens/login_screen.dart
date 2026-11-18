import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../utils/validadores.dart';

/// Pantalla de acceso: iniciar sesión o crear una cuenta con correo.
///
/// No navega por sí misma: cuando Firebase confirma la sesión, [AuthGate]
/// cambia a la pantalla de hábitos.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth});

  final AuthRepository auth;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();

  bool _modoRegistro = false;
  bool _enviando = false;
  bool _verContrasena = false;
  String? _error;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    setState(() => _error = null);
    // CP-04: si el formulario no es válido, no se llama al servicio.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _enviando = true);
    try {
      if (_modoRegistro) {
        await widget.auth.registrarse(
          correo: _correoCtrl.text,
          contrasena: _contrasenaCtrl.text,
        );
      } else {
        await widget.auth.iniciarSesion(
          correo: _correoCtrl.text,
          contrasena: _contrasenaCtrl.text,
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Ocurrió un error inesperado. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _alternarModo() {
    setState(() {
      _modoRegistro = !_modoRegistro;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_modoRegistro ? 'Crear cuenta' : 'Iniciar sesión'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.track_changes,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Panel de hábitos',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const Key('campo-correo'),
                      controller: _correoCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: validarCorreo,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('campo-contrasena'),
                      controller: _contrasenaCtrl,
                      obscureText: !_verContrasena,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_enviando) _enviar();
                      },
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _verContrasena
                              ? 'Ocultar contraseña'
                              : 'Mostrar contraseña',
                          icon: Icon(
                            _verContrasena
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _verContrasena = !_verContrasena,
                          ),
                        ),
                      ),
                      validator: validarContrasena,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        key: const Key('mensaje-error-auth'),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('boton-ingresar'),
                      onPressed: _enviando ? null : _enviar,
                      child: _enviando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_modoRegistro ? 'Crear cuenta' : 'Ingresar'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      key: const Key('boton-cambiar-modo'),
                      onPressed: _enviando ? null : _alternarModo,
                      child: Text(
                        _modoRegistro
                            ? '¿Ya tienes cuenta? Inicia sesión'
                            : '¿No tienes cuenta? Regístrate',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
