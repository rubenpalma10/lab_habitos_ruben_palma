# 05 — Reflexión final

> **Borrador:** reescríbelo con tus propias palabras y con lo que realmente te pasó al ejecutar las pruebas. La rúbrica pide 5 a 8 líneas con aprendizajes concretos.

**¿Qué prueba habría evitado mi error más costoso?**

Mi error más costoso fue INC-001: la app de hábitos guardaba todo en memoria y, al cerrarla, el usuario perdía su día completo. Las pruebas del laboratorio anterior solo revisaban que la pantalla reaccionara a cada toque, y por eso nunca lo detectaron. El caso CP-19 ("cerrar y reabrir la app") lo habría revelado en el primer minuto. Pasarlo a una prueba de widget que desmonta y vuelve a montar la pantalla con el mismo repositorio me obligó a separar la UI de la persistencia (`HabitosRepository`). Esa misma separación permitió usar fakes y probar sin Firebase. Aprendí que una interfaz que "se ve bien" no prueba que los datos estén a salvo, y que los casos de ciclo de vida (reabrir, cerrar sesión, sin red) deben estar en la lista desde el inicio, no al final.
