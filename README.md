# Panel de hábitos — Integración y pruebas con Firebase

**Práctica Semana 16: integración y pruebas de una app Flutter**
Técnicas de Calidad de Software · Autor: Rubén Palma · Rama de trabajo: `semana16-integracion`

App Flutter para seguir el cumplimiento diario de cinco hábitos. Parte del laboratorio E2_L1 (una pantalla con `StatefulWidget` + `setState`) y se extendió con:

- **Firebase Authentication** (correo y contraseña): registro, inicio y cierre de sesión.
- **Cloud Firestore**: el progreso del día y el historial se guardan por usuario y sobreviven a cerrar la app.
- **Tres pantallas con navegación**: Login → Panel de hábitos → Historial.
- **Pruebas** unitarias, de widget (con repositorios *fake*) y de integración.

## Arquitectura

```
lib/
├── main.dart                         # Inicializa Firebase e inyecta los repositorios reales
├── app.dart                          # MaterialApp + AuthGate (Login o Panel según la sesión)
├── models/
│   ├── progreso_dia.dart             # Lógica pura del día (porcentaje, mensaje, meta) — INC-002
│   └── registro_dia.dart             # Día cerrado del historial
├── utils/validadores.dart            # Validación de correo y contraseña
├── data/
│   ├── auth_repository.dart          # Interfaz + mensajes de error de Auth
│   ├── firebase_auth_repository.dart # Implementación con Firebase Auth
│   ├── habitos_repository.dart       # Interfaz de persistencia
│   └── firestore_habitos_repository.dart  # Implementación con Firestore — INC-001
└── screens/
    ├── login_screen.dart
    ├── panel_habitos_screen.dart
    └── historial_screen.dart
```

La UI depende solo de las interfaces `AuthRepository` y `HabitosRepository`. En producción se usan Firebase y Firestore; en las pruebas, `test/fakes/fakes.dart` las reemplaza en memoria, sin red ni cuentas reales.

**Datos en Firestore**

```
usuarios/{uid}/estado/dia_actual   { cumplidos: [bool×5], meta, nota, actualizado }
usuarios/{uid}/historial/{autoId}  { fecha, cumplidos, total, meta, nota }
```

## Cómo ejecutarlo

### 1. Configurar Firebase (una sola vez)

Las claves de Firebase **no están en el repositorio**. Para ejecutar la app necesitas tu propio proyecto:

1. En [Firebase Console](https://console.firebase.google.com) crea un proyecto.
2. **Authentication → Método de acceso →** habilita *Correo electrónico/contraseña*.
3. **Firestore Database →** crea la base de datos. En **Reglas**, pega el contenido de [`firestore.rules`](firestore.rules) y publica.
4. En la carpeta del proyecto:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure        # genera lib/firebase_options.dart y google-services.json
   ```

### 2. Ejecutar

```bash
flutter pub get
flutter run
```

> Si Android falla con un error de `minSdk`, en `android/app/build.gradle.kts` cambia `minSdk = flutter.minSdkVersion` por `minSdk = 23`.

### 3. Verificar calidad

```bash
flutter analyze
flutter test                                   # unitarias + widget
flutter test integration_test -d <emulador>    # opcional, en emulador o dispositivo
```

## Documentación de la práctica

| Atestado | Archivo |
|---|---|
| **Índice de atestados (10.3)** | [docs/00-atestados.md](docs/00-atestados.md) |
| Declaración de alcance | [docs/01-declaracion-alcance.md](docs/01-declaracion-alcance.md) |
| Mapa de flujos críticos | [docs/02-mapa-flujos-criticos.md](docs/02-mapa-flujos-criticos.md) |
| Plantilla de pruebas | [docs/03-plantilla-pruebas.md](docs/03-plantilla-pruebas.md) |
| Registro de incidencias | [docs/04-registro-incidencias.md](docs/04-registro-incidencias.md) |
| Reflexión final | [docs/05-reflexion-final.md](docs/05-reflexion-final.md) |
| Evidencias | [docs/evidencias/](docs/evidencias/) |

## Incidencias y commits

| Incidencia | Commit |
|---|---|
| INC-001 — El progreso se perdía al cerrar la app | `caf1430` |
| INC-002 — Lógica no probable en pruebas unitarias | `caf1430` |
| INC-003 — Archivos sin control en el repositorio | `caf1430` |
| INC-004 — Faltaba `firebase_options.dart` (analyze con 2 errores) | Local, no versionable por contener claves |
| INC-005 — NDK 28.2 corrupto al compilar en Android | `caf1430` |

Detalle, causa y prueba de regresión de cada una en [docs/04-registro-incidencias.md](docs/04-registro-incidencias.md).
