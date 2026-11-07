#!/usr/bin/env bash
# Paso 1 (entrada): crea una tarea con su id, carpeta de auditoría, rama y worktree.
# Uso: intake.sh "texto de la tarea"   |   intake.sh --file error.txt   |   echo ... | intake.sh -
source "$(dirname "$0")/lib.sh"
case "${1:-}" in
  --file) INPUT="$(cat "$2")"; SRC="file:$2" ;;
  -)      INPUT="$(cat)"; SRC="stdin" ;;
  "")     echo "Uso: intake.sh \"tarea\" | --file f | -" >&2; exit 1 ;;
  *)      INPUT="$*"; SRC="cli" ;;
esac
git -C "$ROOT" rev-parse --verify -q main >/dev/null || { echo "El repo necesita al menos un commit en main" >&2; exit 1; }
ID="$(date +%Y%m%d-%H%M%S)-$(head -c3 /dev/urandom | od -An -tx1 | tr -d ' \n')"
mkdir -p "$RUNS/$ID/reviews"
printf '# Entrada (%s)\n\n%s\n' "$SRC" "$INPUT" > "$RUNS/$ID/input.md"
git -C "$ROOT" worktree add -q -b "factory/$ID" "$WT/$ID" main
log "$ID" intake "$SRC"
echo "$ID"
