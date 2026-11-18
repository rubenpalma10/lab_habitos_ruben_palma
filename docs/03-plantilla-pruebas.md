# 03 — Plantilla de pruebas

> **Cómo llenarla:** ejecuta cada caso en el emulador o dispositivo, escribe en *Resultado obtenido* lo que realmente pasó (no solo "ok"), guarda la captura con el nombre indicado y cambia el *Estado* a **Aprobado**, **Fallido** o **No ejecutado (motivo)**. Un caso es Aprobado solo si coincide con lo esperado, no hay excepciones en consola, tiene evidencia y se repite igual tras reiniciar la app.

**Entorno:** _(dispositivo/emulador, versión de Android/iOS)_ · **Flutter:** _(salida de `flutter --version`)_ · **Fecha:** _(dd/mm/aaaa)_

**Datos de prueba:** usuario A `usuario.a@prueba.com` / usuario B `usuario.b@prueba.com` (contraseñas de prueba, no reales; no las incluyas en capturas).

## Casos ejecutados

| ID | Flujo | Módulo | Descripción | Datos de entrada | Resultado esperado | Prueba automatizada | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|---|---|---|
| CP-01 | — | Arranque | La app inicia sin errores | — | Se muestra Login (o el Panel si ya había sesión) sin excepción en consola | — | | Pendiente | `capturas-aplicacion/cp01-arranque.png` |
| CP-02 | F1 | Auth | Inicio de sesión válido | Usuario A + contraseña correcta | Entra al Panel; AppBar "Hábitos — Cumplidos: X / 5" | `login_screen_test` CP-02, `flujo_app_test` | | Pendiente | `cp02-login-ok.png` |
| CP-03 | F1 | Auth | Inicio de sesión inválido **(negativo)** | Usuario A + contraseña incorrecta | Mensaje "Correo o contraseña incorrectos."; sigue en Login | `login_screen_test` CP-03 | | Pendiente | `cp03-login-error.png` |
| CP-04 | F1 | Validación | Formulario vacío / mal escrito **(negativo)** | Campos vacíos; luego `ruben@correo` y `123` | Mensajes bajo cada campo; no se llama a Firebase | `login_screen_test` CP-04, CP-04b | | Pendiente | `cp04-validacion.png` |
| CP-05 | F4 | Navegación | Acceder a cada pantalla | Botón 🕘 Historial | Se abre "Historial" | `panel_habitos_test` CP-05 | | Pendiente | `cp05-historial.png` |
| CP-06 | F4 | Navegación | Botón/gesto "atrás" | Atrás desde Historial | Regresa al Panel con el mismo progreso, sin cierre | `panel_habitos_test` CP-06 | | Pendiente | `cp06-atras.mp4` |
| CP-07 | F2 | Datos | Crear entidad (progreso del día) | Usuario nuevo marca 2 hábitos | Se ve 2 / 5 y aparece `usuarios/{uid}/estado/dia_actual` en Firestore | `panel_habitos_test` P-10 / CP-07 | | Pendiente | `firebase/cp07-dia-actual.png` |
| CP-08 | F2 | Datos | Leer lista | Usuario con historial | Panel muestra el progreso guardado; Historial lista los días del más reciente al más antiguo | `panel_habitos_test` CP-08, `historial_screen_test` CP-08 | | Pendiente | `cp08-lectura.png` |
| CP-09 | F3 | Datos | Actualizar entidad | Escribir "Día productivo" → Guardar nota | Tarjeta muestra la nota y el campo `nota` cambia en Firestore | `panel_habitos_test` P-8 / CP-09 | | Pendiente | `firebase/cp09-nota.png` |
| CP-10 | F4 | Datos | Cerrar día (archivar y reiniciar) | Pulsar "Reiniciar día" con 3 cumplidos | Panel vuelve a 0 / 5; nuevo documento en `historial` con `cumplidos: 3` | `panel_habitos_test` P-10 | | Pendiente | `firebase/cp10-historial.png` |
| CP-11 | F5 | Seguridad | Acceso a datos ajenos **(negativo)** | Rules Playground: leer `usuarios/{uidA}/estado/dia_actual` autenticado como uid B | Rechazado por reglas ("Denied") | — (manual en consola) | | Pendiente | `firebase/cp11-reglas-denied.png` |
| CP-12 | F4 | Estados | Lista vacía / error de red **(negativo)** | Historial sin días; luego modo avión al abrir el Panel | Mensaje de vacío; sin red: mensaje y botón "Reintentar", sin cierre | `historial_screen_test`, `panel_habitos_test` CP-12, `login_screen_test` CP-12 | | Pendiente | `cp12-vacio.png`, `cp12-sin-red.png` |
| CP-13 | — | Storage | Subir y mostrar archivo | — | — | — | No aplica | No ejecutado — Storage fuera de alcance | — |
| CP-14 | — | FCM | Token generado y guardado | — | — | — | No aplica | No ejecutado — FCM fuera de alcance | — |
| CP-15 | — | FCM | Notificación en primer plano | — | — | — | No aplica | No ejecutado — FCM fuera de alcance | — |
| CP-16 | — | FCM | Notificación en segundo plano | — | — | — | No aplica | No ejecutado — FCM fuera de alcance | — |
| CP-17 | — | FCM | Notificación con app cerrada | — | — | — | No aplica | No ejecutado — FCM fuera de alcance | — |
| CP-18 | F5 | Sesión | Cerrar sesión | Pulsar ⎋ "Cerrar sesión" | Vuelve a Login; el progreso del usuario ya no se ve | `flujo_app_test` CP-18 | | Pendiente | `cp18-logout.png` |
| CP-19 | F2 | Persistencia | Reabrir app | Marcar 2 hábitos + nota, cerrar la app por completo y abrirla | Sigue la sesión y se ven 2 / 5 y la nota (**regresión de INC-001**) | `panel_habitos_test` INC-001, `flujo_app_test` CP-19 | | Pendiente | `cp19-reabrir.mp4` |
| CP-20 | F1–F5 | Flujo completo | Recorrido de extremo a extremo | Flujo de 02-mapa-flujos-criticos.md | Todos los pasos aprobados | `flujo_app_test` CP-20, `integration_test/` | | Pendiente | `video-flujo-principal.mp4` (≤ 2 min) |

**Cobertura:** 15 casos aplicables (≥ 10 exigidos), al menos uno por flujo crítico (F1–F5) y 4 negativos (CP-03, CP-04, CP-11, CP-12).

## Resumen de resultados

| Métrica | Valor |
|---|---|
| Casos aplicables ejecutados | _/ 15 |
| Aprobados | _ |
| Fallidos | _ |
| % aprobados en flujos críticos (tras correcciones) | _ % (meta ≥ 80 %) |
| Incidencias registradas | 3 + las que surjan (ver 04) |

## Pruebas automatizadas

| Archivo | Tipo | Qué prueba |
|---|---|---|
| `test/unit/progreso_dia_test.dart` | Unitaria | Porcentaje, mensajes por tramo, meta, inmutabilidad, `toMap`/`fromMap` |
| `test/unit/validadores_test.dart` | Unitaria | Validación de correo y contraseña; mensajes de error de Auth |
| `test/widget/login_screen_test.dart` | Widget (fake) | CP-02, CP-03, CP-04, error de red |
| `test/widget/panel_habitos_test.dart` | Widget (fake) | P-1, P-6/7, P-8, P-10, regresión INC-001, CP-05/06/08/12 |
| `test/widget/historial_screen_test.dart` | Widget (fake) | Estado vacío, con datos y error |
| `test/widget/flujo_app_test.dart` | Widget (fake) | Flujo completo CP-20 |
| `integration_test/flujo_principal_test.dart` | Integración (opcional) | Flujo principal en emulador |

### Salida de `flutter analyze`

- **Inicial** (rama `main`, antes de los cambios): _pegar aquí_ → captura `pruebas-y-analisis/analyze-inicial.png`
- **Final** (rama `semana16-integracion`): _pegar aquí_ → captura `pruebas-y-analisis/analyze-final.png`

### Salida de `flutter test`

```
(pegar aquí la salida completa de: flutter test)
```

Captura: `pruebas-y-analisis/flutter-test.png`
