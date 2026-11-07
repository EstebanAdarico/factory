#!/usr/bin/env bash
# Paso humano: solo lo ejecutas tú en tu terminal (el hook impide que un agente lo haga).
source "$(dirname "$0")/lib.sh"
ID="$1"; R="$RUNS/$ID"; BR="factory/$ID"
[[ -f "$R/PENDING_HUMAN" ]] || { echo "$ID no está pendiente de aprobación humana"; exit 1; }
if [[ "${2:-}" == "--reject" ]]; then
  log "$ID" human_rejected "$USER"; rm "$R/PENDING_HUMAN"
  echo "✗ Rechazado. La rama $BR queda para revisión."; exit 0
fi
git -C "$ROOT" merge -q --no-ff "$BR" -m "factory($ID): aprobado por $USER"
git -C "$ROOT" worktree remove "$WT/$ID" && git -C "$ROOT" branch -q -d "$BR"
rm "$R/PENDING_HUMAN"; log "$ID" merged "human:$USER"; echo "✓ $ID mergeado en main"
