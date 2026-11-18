# 01 — Declaración de alcance

**Proyecto:** Panel de hábitos (`lab_habitos_ruben_palma`)
**Autor:** Rubén Palma
**Rama de trabajo:** `semana16-integracion`

La app parte del laboratorio E2_L1 (una sola pantalla con `StatefulWidget` y `setState`) y se extendió para esta práctica con autenticación, persistencia en Firestore y navegación entre tres pantallas: **Login → Panel de hábitos → Historial**.

## Estado mínimo del proyecto

| Requisito | Cumple | Evidencia |
|---|---|---|
| Compila y ejecuta (`flutter run`) | ☐ *(marcar tras ejecutar)* | `evidencias/capturas-aplicacion/` |
| Al menos 2 pantallas distintas | ✅ | Login, Panel de hábitos, Historial (`lib/screens/`) |
| Usa al menos 1 servicio de Firebase | ✅ | Firebase Auth + Cloud Firestore |
| Repositorio con control de versiones | ✅ | Git + GitHub, rama `semana16-integracion` |

## Módulos y servicios

| Módulo / servicio | ¿Aplica? | Observación |
|---|---|---|
| Autenticación | ✅ Sí | Firebase Auth con correo y contraseña: registro, inicio de sesión y cierre de sesión. `lib/data/firebase_auth_repository.dart` |
| Base de datos (Firestore / Realtime DB) | ✅ Sí | Cloud Firestore. Día en curso en `usuarios/{uid}/estado/dia_actual` e historial en `usuarios/{uid}/historial/{id}`. Reglas en `firestore.rules`. |
| Almacenamiento (Storage) | ☐ No | La app no maneja archivos ni imágenes del usuario. CP-13 no aplica. |
| Notificaciones push (FCM) | ☐ No | No forma parte del diseño de la app (no hay recordatorios remotos). CP-14 a CP-17 no aplican. |
| API REST externa | ☐ No | Toda la información vive en Firebase. |
| Otros (Analytics, Crashlytics, Remote Config…) | ☐ No | No se usan. |

## Fuera de alcance (justificación)

- **FCM:** agregar notificaciones solo para cubrir el caso no aporta al objetivo de la app; los recordatorios serían una extensión futura. Por eso CP-14 a CP-17 se registran como **No aplica** en la plantilla de pruebas.
- **Storage:** no hay subida de archivos. CP-13 queda como **No aplica**.
