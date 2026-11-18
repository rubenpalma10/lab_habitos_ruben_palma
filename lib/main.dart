import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'data/firebase_auth_repository.dart';
import 'data/firestore_habitos_repository.dart';
// Lo genera `flutterfire configure`. No se sube al repositorio (.gitignore).
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    HabitosApp(
      auth: FirebaseAuthRepository(),
      habitos: FirestoreHabitosRepository(),
    ),
  );
}
