# Brain de la fábrica

Memoria persistente del proyecto. **Todo agente de la fábrica lee esta carpeta antes de actuar.**
Si una tarea contradice algo de aquí, el agente se detiene y lo reporta; no improvisa.

| Archivo | Qué guarda | Quién escribe |
|---|---|---|
| `architecture.md` | Stack, módulos, cómo se conectan | Humano + spec-writer (al tomar decisiones nuevas) |
| `conventions.md` | Estilo de código, tests, nombres, comentarios | Humano |
| `decisions.md` | Registro de decisiones (ADR corto, solo se añade) | spec-writer y builder |
| `product.md` | Para quién es el producto, flujos clave (lo usa el revisor de UX) | Humano |
| `risk-policy.md` | Qué cambios exigen revisión humana | Humano (nunca un agente) |
