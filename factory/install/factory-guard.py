#!/usr/bin/env python3
"""PreToolUse hook: los agentes no pueden saltarse la compuerta de la fábrica.
Bloquea (exit 2) merge/push/rebase/reset, cambiar a main, autoaprobarse y editar la política de riesgo.
El merge real solo lo hacen factory/bin/merge.sh (con la vía rápida) o tú con approve.sh."""
import json, re, sys

data = json.load(sys.stdin)
tool, inp = data.get("tool_name", ""), data.get("tool_input", {}) or {}

def block(msg):
    print(f"factory-guard: {msg}", file=sys.stderr)
    sys.exit(2)

if tool == "Bash":
    cmd = inp.get("command", "")
    if re.search(r"factory/bin/approve\.sh", cmd):
        block("approve.sh es solo para el humano. Pídele al usuario que lo ejecute.")
    # merge.sh está permitido: aplica el veredicto con sus propias reglas en código
    rest = re.sub(r"\S*factory/bin/merge\.sh\s+\S+", "", cmd)
    if re.search(r"\bgit\b[^|;&]*\b(merge|push|rebase|reset\s+--hard|update-ref|branch\s+-[dDfM])\b", rest):
        block("merge/push/rebase/reset prohibidos para agentes. El merge lo hace factory/bin/merge.sh.")
    if re.search(r"\bgit\b[^|;&]*\b(checkout|switch)\s+(-\S+\s+)*main\b", rest):
        block("no se trabaja en main: usa el worktree de la tarea.")
    if re.search(r"(risk-policy\.md|\.claude/(hooks|settings)|PENDING_HUMAN)", rest) and \
       re.search(r"(>|\bsed\s+-i|\btee\b|\bmv\b|\brm\b|\bcp\b|\btouch\b)", rest):
        block("la política de riesgo, los hooks y las aprobaciones solo los toca el humano.")
elif tool in ("Edit", "Write", "MultiEdit", "NotebookEdit"):
    path = inp.get("file_path", "") or inp.get("notebook_path", "")
    if re.search(r"(brain/risk-policy\.md|\.claude/settings[^/]*\.json|PENDING_HUMAN)$", path) or "/.claude/hooks/" in path:
        block(f"{path} solo lo modifica el humano.")
sys.exit(0)
