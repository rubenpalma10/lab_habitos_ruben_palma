import 'package:flutter/material.dart';

import 'data/auth_repository.dart';
import 'data/habitos_repository.dart';
import 'screens/login_screen.dart';
import 'screens/panel_habitos_screen.dart';

/// Raíz de la app. Recibe los repositorios por constructor para poder
/// inyectar fakes en las pruebas.
class HabitosApp extends StatelessWidget {
  const HabitosApp({super.key, required this.auth, required this.habitos});

  final AuthRepository auth;
  final HabitosRepository habitos;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panel de hábitos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: AuthGate(auth: auth, habitos: habitos),
    );
  }
}

/// Decide qué pantalla mostrar según haya o no sesión iniciada.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.auth, required this.habitos});

  final AuthRepository auth;
  final HabitosRepository habitos;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<String?> _usuario = widget.auth.cambiosDeUsuario;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: _usuario,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final uid = snapshot.data;
        if (uid == null) {
          return LoginScreen(auth: widget.auth);
        }
        // La key por uid descarta el estado del usuario anterior (CP-18).
        return PanelHabitosScreen(
          key: ValueKey(uid),
          uid: uid,
          auth: widget.auth,
          habitos: widget.habitos,
        );
      },
    );
  }
}
