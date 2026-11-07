#!/usr/bin/env bash
# Lanza una tarea en segundo plano (headless). Puedes lanzar varias a la vez: cada una tiene su worktree.
# Uso: run.sh "tarea" [--file f]
source "$(dirname "$0")/lib.sh"
ID="$("$(dirname "$0")/intake.sh" "$@")"
cd "$ROOT"
nohup claude -p "/factory $ID" --permission-mode "${FACTORY_PERMISSION_MODE:-acceptEdits}" \
  > "$RUNS/$ID/session.log" 2>&1 &
log "$ID" launched "pid $!"
echo "🏭 $ID lanzada (pid $!). Sigue el progreso con: factory/bin/status.sh"
