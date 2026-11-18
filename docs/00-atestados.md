# 00 — Índice de atestados (sección 10.3)

Repositorio: `practica-integracion-pruebas-flutter` · Rama de trabajo: `semana16-integracion` · Autor: Rubén Palma

| N.º | Atestado | Contenido requerido | Dónde está | Estado |
|---|---|---|---|---|
| 1 | Código fuente | Proyecto Flutter funcional y actualizado | [`lib/`](../lib), [`test/`](../test), [`integration_test/`](../integration_test), [`pubspec.yaml`](../pubspec.yaml), [`firestore.rules`](../firestore.rules) | ✅ |
| 2 | Declaración de alcance | Módulos y servicios del proyecto | [`01-declaracion-alcance.md`](01-declaracion-alcance.md) | ✅ |
| 3 | Mapa de flujos críticos | Entre 3 y 5 flujos | [`02-mapa-flujos-criticos.md`](02-mapa-flujos-criticos.md): 5 flujos (F1–F5) | ✅ |
| 4 | Plantilla de pruebas | Casos ejecutados, esperados y obtenidos | [`03-plantilla-pruebas.md`](03-plantilla-pruebas.md): 15 casos aplicables, 5 justificados como No aplica | ⏳ Completar *Resultado obtenido* y *Estado* |
| 5 | Registro de incidencias | Mínimo 3 incidencias | [`04-registro-incidencias.md`](04-registro-incidencias.md): INC-001 a INC-005 con severidad, prioridad, origen, causa y corrección | ✅ |
| 6 | Evidencias visuales | Capturas o video de la app | [`evidencias/capturas-aplicacion/`](evidencias/capturas-aplicacion) | ⏳ Faltan capturas de la versión nueva y el video del flujo |
| 7 | Evidencias Firebase | Capturas de operaciones en Firebase | [`evidencias/firebase/`](evidencias/firebase): método de acceso, modo producción, estructura `usuarios/{uid}/estado` | ⏳ Faltan `dia_actual` con campos, nota, historial, reglas y Rules Playground |
| 8 | Pruebas automatizadas | Resultados de `flutter test` | [`evidencias/pruebas-y-analisis/flutter-test.txt`](evidencias/pruebas-y-analisis/flutter-test.txt): **35 pruebas, todas aprobadas** | ✅ (captura opcional) |
| 9 | Análisis estático | Resultados de `flutter analyze` | [`evidencias/pruebas-y-analisis/flutter-analyze.txt`](evidencias/pruebas-y-analisis/flutter-analyze.txt): 2 errores → **No issues found!** | ✅ (captura opcional) |
| 10 | Historial de Git | Commits que demuestren correcciones | [`evidencias/pruebas-y-analisis/git-log.txt`](evidencias/pruebas-y-analisis/git-log.txt) y el historial de la rama `semana16-integracion` | ✅ Correcciones en `caf1430` (ver la nota de trazabilidad en el registro) |
| 11 | Reflexión final | 5 a 8 líneas | [`05-reflexion-final.md`](05-reflexion-final.md) | ⏳ Personalizar |

## Seguridad (10.4)

- `lib/firebase_options.dart`, `android/app/google-services.json` e `ios/Runner/GoogleService-Info.plist` están en `.gitignore` y **no** forman parte del repositorio.
- Las capturas de Firebase no muestran claves, contraseñas ni datos personales reales. Los usuarios de prueba son `usuario.a@prueba.com` y `usuario.b@prueba.com`.
