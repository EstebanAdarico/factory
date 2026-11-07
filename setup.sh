#!/usr/bin/env bash
# Instala la Software Factory en otro proyecto (repo git).
# Uso:  ./setup.sh /ruta/a/mi-proyecto
# Copia agentes, skill, scripts y plantillas. NUNCA sobrescribe el brain/ ni archivos que ya existan.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DST="${1:?Uso: ./setup.sh /ruta/a/mi-proyecto}"
DST="$(cd "$DST" && pwd)"
git -C "$DST" rev-parse --show-toplevel >/dev/null 2>&1 || { echo "✗ $DST no es un repo git (haz git init y un primer commit)"; exit 1; }

copy() { # copy <ruta relativa>: copia sin pisar lo que ya existe
  local rel="$1"
  if [[ -e "$DST/$rel" ]]; then echo "  · ya existe, no se toca: $rel"; return; fi
  mkdir -p "$DST/$(dirname "$rel")"
  cp -r "$SRC/$rel" "$DST/$rel"
  echo "  + $rel"
}

echo "🏭 Instalando la fábrica en $DST"
for f in "$SRC"/.claude/agents/factory-*.md; do copy ".claude/agents/$(basename "$f")"; done
copy .claude/skills/factory
copy factory/bin
copy factory/install
copy factory/runs
copy factory/tasks
copy brain
copy docker/factory.Dockerfile
copy compose.example.yml

GI="$DST/.gitignore"
for line in ".worktrees/" "factory/runs/*" "!factory/runs/.gitkeep"; do
  grep -qxF "$line" "$GI" 2>/dev/null || echo "$line" >> "$GI"
done

cat <<EOF

✓ Listo. Ahora te toca a ti (paso humano, a propósito):
  1. cd $DST && factory/install/install.sh      # activa el guardián y los permisos
  2. Rellena brain/ (sobre todo architecture.md, product.md y risk-policy.md)
  3. git add -A && git commit -m "Añadir Software Factory"
  4. claude   →   /factory "tu primera tarea"
EOF
