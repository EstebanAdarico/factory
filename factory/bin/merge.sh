#!/usr/bin/env bash
# Paso final (código determinista): aplica el veredicto. Nunca confía solo en el agente.
source "$(dirname "$0")/lib.sh"
ID="$1"; R="$RUNS/$ID"; BR="factory/$ID"
[[ "$(json_get "$R/approval.json" approved)" == "True" ]] || { log "$ID" merge_refused "no aprobado"; echo "✗ $ID no está aprobado"; exit 1; }
ROUTE="$(json_get "$R/gate.json" route)"
# Red de seguridad en código: estas rutas fuerzan revisión humana aunque el agente diga "auto"
RISKY='(migrations?/|alembic/|auth|security|payment|billing|\.env|requirements.*\.txt|pyproject\.toml|package(-lock)?\.json|Dockerfile|docker-compose|\.github/|brain/risk-policy\.md|\.claude/)'
HITS="$(git -C "$ROOT" diff --name-only "main...$BR" | grep -E "$RISKY" || true)"
LINES="$(git -C "$ROOT" diff --shortstat "main...$BR" | grep -oE '[0-9]+ (insertion|deletion)' | awk '{s+=$1} END{print s+0}')"
if [[ "$ROUTE" == "auto" && ( -n "$HITS" || "$LINES" -gt 300 ) ]]; then
  ROUTE=human; log "$ID" gate_override "archivos sensibles o >300 líneas: $HITS"
fi
if [[ "$ROUTE" == "auto" ]]; then
  git -C "$ROOT" merge -q --no-ff "$BR" -m "factory($ID): merge automático (vía rápida)"
  git -C "$ROOT" worktree remove "$WT/$ID" && git -C "$ROOT" branch -q -d "$BR"
  log "$ID" merged auto; echo "✓ $ID mergeado en main (vía rápida)"
else
  echo human > "$R/PENDING_HUMAN"
  log "$ID" awaiting_human "$(json_get "$R/gate.json" reason)"
  echo "⏸ $ID requiere TU aprobación. Revisa: git diff main...$BR"
  echo "   Aprobar:  factory/bin/approve.sh $ID      Rechazar: factory/bin/approve.sh $ID --reject"
fi
