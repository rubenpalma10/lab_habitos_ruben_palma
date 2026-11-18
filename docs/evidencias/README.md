# Evidencias

Guarda cada archivo en su carpeta con el nombre que indica `03-plantilla-pruebas.md`. **No incluyas** contraseñas, el `google-services.json`, claves de la consola ni correos personales reales en ninguna captura.

| Carpeta | Qué va | Archivos esperados |
|---|---|---|
| `capturas-aplicacion/` | Pantallas de la app durante cada caso y el video del flujo principal (≤ 2 min) | `cp01-arranque.png`, `cp02-login-ok.png`, `cp03-login-error.png`, `cp04-validacion.png`, `cp05-historial.png`, `cp06-atras.mp4`, `cp08-lectura.png`, `cp12-vacio.png`, `cp12-sin-red.png`, `cp18-logout.png`, `cp19-reabrir.mp4`, `video-flujo-principal.mp4` |
| `capturas-aplicacion/version-inicial/` | Capturas del laboratorio anterior (rama `main`), como punto de partida | `p1-…`, `p2-…`, `p6-…`, `p10-…` |
| `firebase/` | Consola de Firebase: usuarios en Authentication, documentos creados o modificados en Firestore, reglas publicadas y Rules Playground | ✅ `auth-metodo-acceso.png`, ✅ `firestore-modo-produccion.png`, ✅ `firestore-estructura-usuario.png`, `auth-usuarios.png`, `cp07-dia-actual.png`, `cp09-nota.png`, `cp10-historial.png`, `reglas-publicadas.png`, `cp11-reglas-denied.png` |
| `notificaciones-fcm/` | No aplica: FCM está fuera del alcance (ver `01-declaracion-alcance.md`) | — |
| `pruebas-y-analisis/` | Salidas de consola | ✅ `flutter-analyze.txt`, ✅ `flutter-test.txt`, ✅ `git-log.txt`, ✅ `inc-004-flutterfire.txt`, ✅ `inc-005-ndk.txt`; opcional: `analyze-final.png`, `flutter-test.png` |
