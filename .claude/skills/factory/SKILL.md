---
name: factory
description: Software Factory. Lleva una tarea (error de producción, issue o pedido) por el pipeline completo — spec, build con TDD, 4 revisores en paralelo, aprobador, compuerta de riesgo y merge. Úsalo con /factory "tarea" o /factory <run-id>.
argument-hint: "\"descripción de la tarea\" | <run-id>"
---

# Software Factory — orquestador

Argumento: `$ARGUMENTS`

Eres el orquestador. **No escribes código ni revisas tú mismo**: delegas cada paso en su agente y verificas que dejó su archivo en la carpeta de la tarea. Cada paso deja rastro en `factory/runs/<id>/` (auditable).

## 0. Entrada
- Si `$ARGUMENTS` coincide con una carpeta existente en `factory/runs/`, ese es el `ID`.
- Si no, crea la tarea: `factory/bin/intake.sh "<texto>"` → imprime el `ID`.
- Define `RUN_DIR=<raíz>/factory/runs/<ID>` y `WORKTREE=<raíz>/.worktrees/<ID>` (rutas absolutas).
- Registra cada paso con: `source factory/bin/lib.sh && log <ID> <evento> "<detalle>"`.

## 1. Spec — `factory-spec-writer`
Pásale RUN_DIR y WORKTREE. Al volver, comprueba que existe `RUN_DIR/spec.md`.
Si contiene **BLOQUEADO**: registra `blocked`, muestra las preguntas al usuario y **detente**.

## 2. Build — `factory-builder`
Pásale RUN_DIR y WORKTREE. Comprueba `RUN_DIR/build.md` y que hay commits nuevos:
`git -C WORKTREE log --oneline main..HEAD`. Si no hay commits, registra `build_failed` y detente.

## 3. Revisión — 4 agentes EN PARALELO (un solo mensaje con 4 llamadas)
`factory-reviewer-security`, `factory-reviewer-ux`, `factory-reviewer-ui`, `factory-reviewer-code`.
A cada uno pásale solo RUN_DIR y WORKTREE (contexto limpio: no les cuentes nada del build).
Comprueba que existen los 4 `RUN_DIR/reviews/*.json`.

## 4. Aprobación — `factory-approver`
Pásale RUN_DIR y el número de iteración N (empieza en 1).
- `approval.json` con `approved:false` → vuelve al paso 2 con el builder, indicándole que lea `RUN_DIR/feedback.md`. Luego repite 3 y 4.
- **Máximo 3 iteraciones.** Si a la 3ª sigue rechazado: registra `gave_up`, resume los bloqueos al usuario y detente (la rama queda para revisión manual).

## 5. Compuerta de riesgo — `factory-gate`
Pásale RUN_DIR y WORKTREE. Comprueba `RUN_DIR/gate.json`.

## 6. Salida (código determinista)
Ejecuta `factory/bin/merge.sh <ID>` y muestra su salida tal cual.
**Nunca** ejecutes `approve.sh` ni hagas merge/push por tu cuenta: la aprobación humana es del usuario.

## Resumen final al usuario
ID, objetivo de la spec, iteraciones, veredicto de cada revisor, ruta (auto/humana) y motivo, y el siguiente paso si le toca a él.
