#!/usr/bin/env bash
# Ejecútalo TÚ (no un agente): activa el hook guardián y los permisos de la fábrica en este proyecto.
set -euo pipefail
cd "$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
mkdir -p .claude/hooks
install -m 755 factory/install/factory-guard.py .claude/hooks/factory-guard.py
if [[ -f .claude/settings.json ]]; then echo "Ya existe .claude/settings.json; fusiónalo a mano con factory/install/settings.json"; exit 1; fi
cp factory/install/settings.json .claude/settings.json
echo "✓ Hook factory-guard y permisos instalados en .claude/"
