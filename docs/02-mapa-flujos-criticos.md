# 02 — Mapa de flujos críticos

| ID | Flujo crítico ("el usuario puede…") | Pantallas | Servicios | Casos que lo cubren |
|---|---|---|---|---|
| **F1** | …registrarse e iniciar sesión con su correo | Login → Panel | Auth | CP-02, CP-03, CP-04 |
| **F2** | …marcar sus hábitos del día y ver su progreso, y encontrarlo igual al volver a abrir la app | Panel | Firestore | CP-07, CP-08, CP-19 |
| **F3** | …escribir y guardar la nota del día | Panel | Firestore | CP-09 |
| **F4** | …cerrar el día y consultarlo después en el historial | Panel → Historial | Firestore | CP-05, CP-06, CP-10, CP-12 |
| **F5** | …cerrar sesión sin que sus datos queden visibles, y sin poder ver datos de otros | Panel → Login | Auth + reglas | CP-11, CP-18 |

## Recorrido de extremo a extremo (CP-20)

```
Abrir app ─► Login ─► (credenciales válidas) ─► Panel
                │                                  │ marcar hábitos / meta / nota (se guarda en Firestore)
                └─ (inválidas) mensaje de error     │
                                                   ├─► Historial ─► atrás ─► Panel
                                                   ├─► Reiniciar día (archiva en historial)
                                                   └─► Cerrar sesión ─► Login
```

## Orden de integración (Fase 3)

1. Arranque e inicialización de Firebase — `lib/main.dart` (CP-01)
2. Autenticación — `LoginScreen` + `AuthGate` (CP-02, CP-03, CP-04)
3. Navegación — Panel ⇄ Historial, salir (CP-05, CP-06, CP-18)
4. Lectura de datos — carga del día y del historial (CP-08, CP-12)
5. Escritura/actualización — marcar, meta, nota, cerrar día (CP-07, CP-09, CP-10)
6. Notificaciones push — **no aplica** (ver 01-declaracion-alcance.md)
7. Flujo completo — CP-20
