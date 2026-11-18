# 04 — Registro de incidencias

**Escalas usadas**
- **Severidad:** Crítica (la app no arranca o pierde datos de todos), Alta (un flujo crítico no se puede completar o hay pérdida de datos), Media (funciona pero con defecto relevante), Baja (cosmético u organizativo).
- **Prioridad:** P1 (corregir ya), P2 (en esta iteración), P3 (cuando haya tiempo).
- **Origen:** Diseño, Código, Integración, Configuración, Repositorio.

## Resumen

| ID | Título | Severidad | Prioridad | Origen | Caso | Estado | Commit |
|---|---|---|---|---|---|---|---|
| INC-001 | El progreso del día se pierde al cerrar y reabrir la app | Alta | P1 | Diseño | CP-19 | Corregida — re-probar en dispositivo | `fix: INC-001 …` _(hash)_ |
| INC-002 | La lógica de progreso no se puede probar con pruebas unitarias | Media | P2 | Código | Fase 4 | Corregida | `fix: INC-002 …` _(hash)_ |
| INC-003 | Archivos sin control en el repositorio y dependencias no reproducibles | Baja | P3 | Repositorio | — | Corregida | `fix: INC-003 …` _(hash)_ |

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

**Re-prueba manual (CP-19):** _(completar: fecha, resultado obtenido, captura/video `cp19-reabrir.mp4`)_ → Estado final: _Aprobado / Fallido_

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

---

## Incidencias encontradas durante la ejecución manual

> Agrega aquí las que aparezcan al probar en el dispositivo (por ejemplo, configuración de Firebase, `minSdk`, reglas). Cada una necesita causa y corrección, o quedar **Abierta** con justificación.

| ID | Título | Severidad | Prioridad | Origen | Caso | Causa | Corrección | Commit | Estado |
|---|---|---|---|---|---|---|---|---|---|
| INC-004 | | | | | | | | | |
