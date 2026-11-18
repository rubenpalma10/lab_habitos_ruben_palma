# 04 — Registro de incidencias

**Escalas usadas**
- **Severidad:** Crítica (la app no arranca o pierde datos de todos), Alta (un flujo crítico no se puede completar o hay pérdida de datos), Media (funciona pero con defecto relevante), Baja (cosmético u organizativo).
- **Prioridad:** P1 (corregir ya), P2 (en esta iteración), P3 (cuando haya tiempo).
- **Origen:** Diseño, Código, Integración, Configuración, Repositorio.

## Resumen

| ID | Título | Severidad | Prioridad | Origen | Caso | Estado | Commit |
|---|---|---|---|---|---|---|---|
| INC-001 | El progreso del día se pierde al cerrar y reabrir la app | Alta | P1 | Diseño | CP-19 | Corregida — falta evidencia de re-prueba en dispositivo | `caf1430` |
| INC-002 | La lógica de progreso no se puede probar con pruebas unitarias | Media | P2 | Código | Fase 4 | Corregida y re-probada (`flutter test`) | `caf1430` |
| INC-003 | Archivos sin control en el repositorio y dependencias no reproducibles | Baja | P3 | Repositorio | — | Corregida | `caf1430` |
| INC-004 | `flutter analyze` con 2 errores: falta `lib/firebase_options.dart` | Alta | P1 | Configuración | CP-01 | Corregida y re-probada (`flutter analyze` limpio) | Local, no versionable (ver detalle) |
| INC-005 | `flutter run` falla en Android: NDK 28.2 corrupto (`CXX1101`) | Crítica | P1 | Entorno / Configuración | CP-01 | Corregida y re-probada (la app abre en SM-A346M) | `caf1430` (`android/app/build.gradle.kts`) |

> **Nota de trazabilidad:** las correcciones de INC-001, INC-002, INC-003 e INC-005 quedaron en un solo commit (`caf1430`), cuyo mensaje no menciona los IDs. Cada sección de abajo indica qué archivos de ese commit corresponden a cada incidencia. Las próximas correcciones se registrarán con commits individuales `fix: INC-00X …`.
---

## INC-001 — El progreso del día se pierde al cerrar y reabrir la app

| Campo | Detalle |
|---|---|
| Severidad / Prioridad | **Alta / P1**: rompe el flujo crítico F2 y hay pérdida de datos del usuario |
| Origen | Diseño |
| Caso que lo detecta | CP-19 (Persistencia — reabrir app) |
| Entorno | Rama `main`, emulador _(completar)_ |

**Método de 5 pasos (12.2)**

1. **Reproducir.** En la versión de `main`: marcar 3 hábitos, escribir y guardar una nota, cerrar la app desde el gestor de tareas y volver a abrirla. **Obtenido:** "Hábitos — Cumplidos: 0 / 5", "Sin nota" y el historial vacío. **Esperado:** 3 / 5 y la nota.
2. **Leer.** No hay excepción en consola: el fallo no es un error de ejecución sino de comportamiento. En `lib/main.dart` (versión `main`) todo el estado (`_cumplidos`, `_meta`, `_nota`, `_historial`) vive en campos de `_PanelHabitosState` y se inicializa en `initState()`.
3. **Hipótesis.** El estado solo existe en memoria. Al terminar el proceso el `State` se destruye y en el siguiente arranque `initState()` vuelve a crear `List<bool>.filled(5, false)`.
4. **Comprobar.** Se confirma porque ningún código escribe a disco ni a un servicio: no hay `shared_preferences`, archivos ni Firebase en `pubspec.yaml`. Rotar la pantalla no pierde datos (el `State` sobrevive), pero matar el proceso sí.
5. **Corregir y proteger.**
   - Se agregó `HabitosRepository` con implementación en Cloud Firestore (`lib/data/firestore_habitos_repository.dart`): el Panel carga el día al abrir (`cargarDia`) y lo guarda en cada cambio (`guardarDia`). "Reiniciar día" archiva en `historial` con `cerrarDia`.
   - Los datos quedan por usuario (`usuarios/{uid}/…`), protegidos por `firestore.rules`.
   - El slider guarda solo al soltarlo (`onChangeEnd`) para no hacer una escritura por cada píxel arrastrado.
   - **Prueba de regresión:** `test/widget/panel_habitos_test.dart` → *"INC-001 (regresión): el progreso sobrevive a cerrar y reabrir la pantalla"* y el paso CP-19 de `flujo_app_test.dart`.

**Re-prueba manual (CP-19):** _(completar: fecha, resultado obtenido y video `cp19-reabrir.mp4`)_ → Estado final: _Aprobado / Fallido_

**Archivos de la corrección en `caf1430`:** `lib/data/habitos_repository.dart`, `lib/data/firestore_habitos_repository.dart`, `lib/screens/panel_habitos_screen.dart`, `firestore.rules`, `test/widget/panel_habitos_test.dart`.

---

## INC-002 — La lógica de progreso no se puede probar con pruebas unitarias

| Campo | Detalle |
|---|---|
| Severidad / Prioridad | **Media / P2**: no rompe la app, pero impide cumplir la Fase 4 y deja sin proteger los cálculos |
| Origen | Código (acoplamiento) |
| Caso que lo detecta | Fase 4 — "Una prueba unitaria de una función o clase con lógica" |

**Descripción.** Los cálculos de porcentaje, mensaje motivacional y meta alcanzada eran getters privados (`_porcentaje`, `_mensaje`, `_metaAlcanzada`) dentro de `_PanelHabitosState`. Solo se podían verificar levantando el widget completo.

**Causa.** La lógica de negocio y la UI estaban en la misma clase.

**Corrección.** Se extrajo la clase inmutable `ProgresoDia` (`lib/models/progreso_dia.dart`), sin dependencias de Flutter ni Firebase, con `totalCumplidos`, `porcentaje`, `mensaje`, `metaAlcanzada`, `alternar()`, `copyWith()`, `toMap()` y `fromMap()`. El widget ahora solo la muestra.

**Archivos de la corrección en `caf1430`:** `lib/models/progreso_dia.dart`, `test/unit/progreso_dia_test.dart`.

**Protección.** `test/unit/progreso_dia_test.dart` (tramos 0 / 20 / 40 / 60 / 100 %, meta exacta, inmutabilidad, ida y vuelta a Firestore y datos corruptos).

---

## INC-003 — Archivos sin control en el repositorio y dependencias no reproducibles

| Campo | Detalle |
|---|---|
| Severidad / Prioridad | **Baja / P3** |
| Origen | Repositorio / Configuración |
| Detectado en | Fase 1 — `git status` al crear la rama |

**Descripción.** `git status` mostraba `lib.zip` (copia vieja de `lib/main.dart`) y `.metadata` sin rastrear. Además, `.gitignore` excluía `pubspec.lock`, de modo que el docente podía instalar versiones distintas de los paquetes. El historial también tenía dos commits iguales ("docs: capturas de P-1, P-2, P-6 y P-10").

**Causa.** El `.gitignore` se copió de una plantilla para paquetes, no para apps, y se trabajó con respaldos manuales en lugar de ramas.

**Corrección.** Se eliminó `lib.zip`, se versionó `.metadata` y `pubspec.lock`, y se agregaron a `.gitignore` los archivos con claves de Firebase (`lib/firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`) y los `*.zip`. El commit duplicado se deja como está para no reescribir el historial ya publicado.

**Archivos de la corrección en `caf1430`:** `.gitignore`, `.metadata`, `pubspec.lock`.

---

## INC-004 — `flutter analyze` con 2 errores: falta `lib/firebase_options.dart`

| Campo | Detalle |
|---|---|
| Severidad / Prioridad | **Alta / P1**: la app no compila |
| Origen | Configuración (herramienta `flutterfire_cli`) |
| Caso que lo detecta | CP-01 (Arranque) y Fase 1 (`flutter analyze`) |
| Evidencia | `evidencias/pruebas-y-analisis/flutter-analyze.txt`, `evidencias/pruebas-y-analisis/inc-004-flutterfire.txt` |

1. **Reproducir.** Al ejecutar `flutterfire configure --project=habitos-ruben` y luego `flutter analyze`, salen 2 errores: `uri_does_not_exist` (`firebase_options.dart`) y `undefined_identifier` (`DefaultFirebaseOptions`) en `lib/main.dart`.
2. **Leer.** La salida de `flutterfire configure` termina con `cannot load such file -- xcodeproj (LoadError)` justo después de registrar las apps.
3. **Hipótesis.** El comando abortó antes de escribir `lib/firebase_options.dart`. La causa es que se marcó la plataforma **macOS**, que requiere la gema de Ruby `xcodeproj`, no instalada en la Mac.
4. **Comprobar.** Sí existían `android/app/google-services.json` e `ios/Runner/GoogleService-Info.plist`, y Gradle sí se había modificado; solo faltaba el archivo Dart. Esto confirma que el proceso se cortó al final.
5. **Corregir y proteger.** Se generó `lib/firebase_options.dart` (Android e iOS) con los valores de esos dos archivos. Al repetir, `flutter analyze` → **No issues found!**. El archivo contiene claves del proyecto, así que está en `.gitignore` y **no se sube**. Por eso esta corrección no tiene commit propio, y el README indica que cada persona debe generarlo. **Prevención:** ejecutar `flutterfire configure --platforms=android,ios,web` para no incluir macOS, o instalar antes la gema con `sudo gem install xcodeproj`.

---

## INC-005 — `flutter run` falla en Android: NDK 28.2 corrupto (`CXX1101`)

| Campo | Detalle |
|---|---|
| Severidad / Prioridad | **Crítica / P1**: no se puede instalar la app en el dispositivo |
| Origen | Entorno de desarrollo / Configuración de Gradle |
| Caso que lo detecta | CP-01 (Arranque) |
| Evidencia | `evidencias/pruebas-y-analisis/inc-005-ndk.txt` |

1. **Reproducir.** `flutter run` en el Samsung SM-A346M → `BUILD FAILED`, `[CXX1101] NDK at …/ndk/28.2.13676358 did not have a source.properties file`.
2. **Leer.** Flutter sugiere que la descarga del NDK está dañada. En el log de la primera ejecución, la instalación de "NDK (Side by side) 28.2" se había interrumpido con `Ctrl+C`.
3. **Hipótesis.** La carpeta del NDK 28.2 quedó a medio descargar. Al reintentar, Gradle encuentra la carpeta, no encuentra `source.properties` y falla.
4. **Comprobar.** Al reintentar `flutter run`, el error se repitió. En cambio, el NDK `27.1.12297006` aparecía completo en `-Pflutter.installedNdkVersions`.
5. **Corregir y proteger.** Se fijó `ndkVersion = "27.1.12297006"` en `android/app/build.gradle.kts` (incluido en `caf1430`), se borró la carpeta 28.2 y se ejecutó `flutter clean`. Re-prueba: la app compila y abre el Login en el SM-A346M. **Prevención:** no interrumpir la primera compilación de Android, que descarga el NDK y los SDK nativos de Firebase.

---

## Nuevas incidencias

> Agrega aquí las que surjan en el resto de las pruebas manuales. Cada una necesita causa y corrección, o quedar **Abierta** con justificación. Haz el commit de la corrección como `fix: INC-006 …`.

| ID | Título | Severidad | Prioridad | Origen | Caso | Causa | Corrección | Commit | Estado |
|---|---|---|---|---|---|---|---|---|---|
| INC-006 | | | | | | | | | |
