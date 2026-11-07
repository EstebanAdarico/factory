#!/usr/bin/env bash
# Utilidades compartidas de la fábrica
set -euo pipefail
ROOT="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
RUNS="$ROOT/factory/runs"
WT="$ROOT/.worktrees"
log() { # log <run_id> <evento> [detalle]
  printf '{"ts":"%s","run":"%s","event":"%s","detail":%s}\n' \
    "$(date -Iseconds)" "$1" "$2" "$(printf '%s' "${3:-}" | python3 -c 'import json,sys;print(json.dumps(sys.stdin.read()))')" \
    >> "$RUNS/$1/log.jsonl"
}
json_get() { python3 -c 'import json,sys;print(json.load(open(sys.argv[1])).get(sys.argv[2],""))' "$1" "$2"; }
