#!/usr/bin/env bash
# Muestra el estado de todas las tareas (último evento de cada una).
source "$(dirname "$0")/lib.sh"
for d in "$RUNS"/*/; do
  [[ -f "$d/log.jsonl" ]] || continue
  tail -1 "$d/log.jsonl" | python3 -c '
import json, sys
e = json.load(sys.stdin)
print(e["run"], " ", e["event"].ljust(16), e["ts"])'
done
