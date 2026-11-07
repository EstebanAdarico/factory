# 🏭 Factory: una Software Factory para Claude Code

> **Le das una tarea y te devuelve código revisado y mergeado**, o una rama esperando tu firma.
> No es un solo agente. Es un **ecosistema**: un lugar donde vamos poniendo las piezas (agentes, skills, scripts, memoria y reglas) que hacen el trabajo por nosotros, cada una con su rol y con controles entre ellas.

---

## 🧭 El ecosistema de un vistazo

```mermaid
flowchart LR
    subgraph IN["📥 Entradas"]
        A1["💬 Un pedido<br/>'añade filtro por fecha'"]
        A2["🐞 Un error de producción<br/>(log, stacktrace)"]
        A3["📋 Una issue o<br/>tarea en archivo"]
    end

    subgraph FAB["🏭 La fábrica"]
        direction TB
        BR[("🧠 brain/<br/>memoria del proyecto")]
        AG["🤖 Agentes<br/>.claude/agents/factory-*"]
        SK["🎛️ Orquestador<br/>skill /factory"]
        BIN["⚙️ Código determinista<br/>factory/bin/*.sh"]
        GU["🛡️ Guardián<br/>hook factory-guard"]
        SK --> AG
        AG <--> BR
        SK --> BIN
        GU -. vigila .-> AG
    end

    subgraph OUT["📤 Salidas"]
        O1["✅ Merge automático<br/>(cambios de bajo riesgo)"]
        O2["⏸️ Rama esperando<br/>tu aprobación"]
        O3["📂 Rastro auditable<br/>factory/runs/&lt;id&gt;/"]
    end

    IN --> FAB --> OUT
```

| Capa | Qué es | Quién la controla |
|---|---|---|
| 🧠 **Brain** | Memoria del proyecto: arquitectura, convenciones, producto, decisiones y política de riesgo. Todos los agentes la leen antes de actuar. | Tú (y los agentes añaden decisiones) |
| 🤖 **Agentes** | Especialistas con un solo trabajo cada uno y el modelo justo para ese trabajo | El orquestador |
| 🎛️ **Orquestador** | El skill `/factory`: no escribe código, solo delega y comprueba que cada paso dejó su archivo | — |
| ⚙️ **Código determinista** | Scripts bash que hacen lo que no debe depender de un LLM: crear la tarea, mergear y aprobar | Reglas fijas en código |
| 🛡️ **Guardián** | Hook que impide a los agentes hacer merge, push, autoaprobarse o tocar la política de riesgo | Solo tú |
| 🙋 **Humano** | La última palabra en lo que es riesgoso | Tú |

---

## 🔄 Cómo fluye una tarea

```mermaid
flowchart TD
    START(["/factory 'tarea'"]) --> INTAKE["⚙️ intake.sh<br/>crea id · carpeta · rama · worktree"]
    INTAKE --> SPEC["📝 spec-writer · Opus<br/>convierte la tarea en una spec ejecutable"]
    SPEC -->|"¿falta info?"| BLOCK["🚧 BLOQUEADO<br/>te hace preguntas y se detiene"]
    SPEC --> BUILD["🔨 builder · Opus<br/>implementa con TDD en su worktree"]

    BUILD --> REV{{"👀 4 revisores EN PARALELO<br/>contexto limpio, no saben nada del build"}}
    REV --> R1["🔒 seguridad<br/>Sonnet"]
    REV --> R2["🧑‍🦯 UX<br/>Sonnet"]
    REV --> R3["🎨 UI<br/>Sonnet"]
    REV --> R4["🧹 código<br/>Haiku"]

    R1 & R2 & R3 & R4 --> APP["⚖️ approver · Opus<br/>consolida los 4 veredictos"]
    APP -->|"❌ rechazado<br/>feedback.md"| LOOP{"¿vuelta < 3?"}
    LOOP -->|sí| BUILD
    LOOP -->|no| GIVEUP["🏳️ gave_up<br/>la rama queda para revisión manual"]

    APP -->|"✅ aprobado"| GATE["🚦 gate · Opus<br/>lee brain/risk-policy.md"]
    GATE --> MERGE["⚙️ merge.sh<br/>red de seguridad en código"]
    MERGE -->|"bajo riesgo"| AUTO["✅ merge automático a main"]
    MERGE -->|"riesgoso"| HUMAN["⏸️ PENDING_HUMAN<br/>approve.sh &lt;id&gt; lo decides tú"]

    BRAIN[("🧠 brain/")] -.-> SPEC & BUILD & REV & GATE

    classDef human fill:#fde68a,stroke:#b45309,color:#000
    classDef ok fill:#bbf7d0,stroke:#15803d,color:#000
    classDef bad fill:#fecaca,stroke:#b91c1c,color:#000
    class HUMAN,BLOCK human
    class AUTO ok
    class GIVEUP bad
```

### La misma tarea, contada en el tiempo

```mermaid
sequenceDiagram
    autonumber
    actor Tú
    participant O as 🎛️ /factory
    participant S as 📝 spec-writer
    participant B as 🔨 builder
    participant R as 👀 4 revisores
    participant A as ⚖️ approver
    participant G as 🚦 gate
    participant M as ⚙️ merge.sh

    Tú->>O: /factory "el login falla en móvil"
    O->>O: intake.sh → id + worktree
    O->>S: escribe la spec
    S-->>O: spec.md
    loop máximo 3 vueltas
        O->>B: implementa (TDD)
        B-->>O: commits + build.md
        par en paralelo
            O->>R: seguridad · UX · UI · código
        end
        R-->>O: reviews/*.json
        O->>A: ¿aprobado?
        A-->>O: approval.json (+ feedback.md si no)
    end
    O->>G: ¿qué riesgo tiene?
    G-->>O: gate.json (auto | human)
    O->>M: aplica el veredicto
    alt bajo riesgo
        M-->>Tú: ✅ mergeado en main
    else riesgoso
        M-->>Tú: ⏸️ revisa y ejecuta approve.sh
    end
```

---

## 🚦 ¿Quién decide si se mergea solo?

Dos filtros independientes. Para ir por la vía rápida, el cambio tiene que pasar **los dos**: no basta con que el agente diga "auto".

```mermaid
flowchart LR
    G["🚦 gate (agente)<br/>lee risk-policy.md"] -->|human| H["⏸️ revisión humana"]
    G -->|auto| C{"⚙️ merge.sh (código)<br/>¿toca archivos sensibles?<br/>¿más de 300 líneas?"}
    C -->|sí| H
    C -->|no| OK["✅ merge automático"]
    classDef h fill:#fde68a,stroke:#b45309,color:#000
    classDef ok fill:#bbf7d0,stroke:#15803d,color:#000
    class H h
    class OK ok
```

| ✅ Vía rápida | ⏸️ Siempre humano |
|---|---|
| Textos, estilos, colores, copys | Esquema de BD, migraciones, borrados masivos |
| Tests nuevos sin cambio de lógica | Auth, pagos, secretos |
| Documentación | Lógica core de negocio |
| | Dependencias nuevas, Docker, CI/CD |
| | Más de ~300 líneas o 10 archivos |

*Ante la duda: revisión humana.* Esta política la editas tú en `brain/risk-policy.md`, y los agentes tienen prohibido tocarla.

---

## 🛡️ Por qué es seguro dejarla trabajar sola

```mermaid
flowchart TB
    subgraph L1["Capa 1 · Docker"]
        subgraph L2["Capa 2 · Hook factory-guard"]
            subgraph L3["Capa 3 · Permisos de settings.json"]
                subgraph L4["Capa 4 · merge.sh con reglas en código"]
                    AG["🤖 Agentes"]
                end
            end
        end
    end
    YOU["🙋 Tú: approve.sh"] --- L1
```

- **Docker**: la fábrica corre en un contenedor con `bypassPermissions`. Si algo sale mal, se queda dentro del contenedor.
- **Guardián**: bloquea `git merge/push/rebase/reset --hard`, el cambio a `main`, la ejecución de `approve.sh` y la edición de `risk-policy.md`, de los hooks o de los settings.
- **Permisos**: `git push` y `approve.sh` están en `deny`.
- **Worktrees**: cada tarea trabaja en su propia copia (`.worktrees/<id>`), así que `main` no se toca hasta el merge.

---

## 🤖 El equipo

| Agente | Modelo | Rol |
|---|---|---|
| `factory-spec-writer` | Opus | Convierte la entrada en una spec ejecutable consultando el brain. Si falta información, se bloquea y pregunta. |
| `factory-builder` | Opus | Implementa la spec con TDD dentro del worktree de la tarea |
| `factory-reviewer-security` | Sonnet | Busca vulnerabilidades, secretos e inyecciones |
| `factory-reviewer-ux` | Sonnet | Compara el cambio con los flujos de `brain/product.md` |
| `factory-reviewer-ui` | Sonnet | Revisa consistencia visual y accesibilidad |
| `factory-reviewer-code` | Haiku | Revisa calidad y consistencia del código (barato y rápido) |
| `factory-approver` | Opus | Consolida los 4 veredictos. Si rechaza, escribe `feedback.md` para el builder. |
| `factory-gate` | Opus | Decide vía rápida o humana según la política de riesgo |

---

## 🚀 Instalar en tu proyecto

```bash
git clone git@github.com:EstebanAdarico/factory.git
cd factory
./setup.sh /ruta/a/mi-proyecto       # copia las piezas sin pisar nada que ya exista
```

Luego, dentro de tu proyecto (estos pasos los haces **tú**, a propósito):

```bash
factory/install/install.sh           # activa el guardián y los permisos
# rellena brain/: architecture.md, product.md y risk-policy.md
git add -A && git commit -m "Añadir Software Factory"
```

**Con Docker (recomendado para el modo autónomo):**

```bash
cp compose.example.yml compose.yml   # ajústalo a tu stack
docker compose up -d --build
docker compose exec factory claude   # la primera vez: login
```

## 🕹️ Uso

| Quiero… | Comando |
|---|---|
| Lanzar una tarea (interactivo) | `/factory "el botón de login no responde en móvil"` dentro de `claude` |
| Retomar una tarea | `/factory <run-id>` |
| Lanzar varias en paralelo (headless) | `factory/bin/run.sh "tarea 1"` · `factory/bin/run.sh "tarea 2"` |
| Lanzar desde un log o una issue | `factory/bin/run.sh --file error.txt` |
| Ver el estado de todo | `factory/bin/status.sh` |
| Aprobar o rechazar | `factory/bin/approve.sh <id>` · `factory/bin/approve.sh <id> --reject` |

## 📂 Qué queda guardado de cada tarea

```
factory/runs/<id>/
├── input.md          📥 lo que pediste
├── spec.md           📝 qué se va a hacer y cómo se valida
├── build.md          🔨 qué hizo el builder
├── reviews/          👀 security.json · ux.json · ui.json · code.json
├── feedback.md       🔁 por qué se rechazó (si hubo vueltas)
├── approval.json     ⚖️ veredicto del aprobador
├── gate.json         🚦 vía rápida o humana, y por qué
├── log.jsonl         🕓 cada evento con hora
└── session.log       🖥️ salida completa (modo headless)
```

## 🗂️ Estructura del repo

```
.
├── .claude/
│   ├── agents/factory-*.md      🤖 los 8 agentes
│   └── skills/factory/SKILL.md  🎛️ el orquestador /factory
├── brain/                       🧠 plantillas de memoria (rellénalas por proyecto)
├── factory/
│   ├── bin/                     ⚙️ intake · run · status · merge · approve
│   ├── install/                 🛡️ guardián + settings (los activa install.sh)
│   ├── tasks/                   📋 tareas escritas para lanzar con --file
│   └── runs/                    📂 rastro de cada corrida (fuera de git)
├── docker/factory.Dockerfile    🐳 Claude Code + Python + Node + git, sin root
├── compose.example.yml
└── setup.sh                     🚀 instala la fábrica en otro proyecto
```

---

## 🌱 Hacer crecer el ecosistema

La idea es que la fábrica vaya ganando piezas. Para añadir una:

```mermaid
flowchart LR
    Q{"¿Qué quieres<br/>que haga por ti?"}
    Q -->|"un rol con criterio propio"| A["🤖 Agente nuevo<br/>.claude/agents/factory-xxx.md<br/>y lo llamas desde SKILL.md"]
    Q -->|"un flujo de varios pasos"| S["🎛️ Skill nuevo<br/>.claude/skills/xxx/SKILL.md"]
    Q -->|"algo que debe ser exacto<br/>siempre igual"| B["⚙️ Script<br/>factory/bin/xxx.sh"]
    Q -->|"una regla que nadie<br/>puede saltarse"| H["🛡️ Regla en el guardián<br/>factory-guard.py"]
    Q -->|"algo que los agentes<br/>deben saber"| M["🧠 Una nota en brain/"]
```

**Regla de oro:** si un paso debe ser exacto y repetible, va en **código**. Si necesita criterio, va en un **agente**. Si es riesgoso, la decisión es **tuya**.

---

<sub>Inspirado en *"Programar con agentes ya no basta: monta tu Software Factory"* (Eric Risco).</sub>
