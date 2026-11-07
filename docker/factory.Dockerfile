# Contenedor de la Software Factory: Claude Code + Python + Node + git, usuario no-root (uid 1000 = tu usuario)
FROM node:22-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends \
      git python3 python3-venv python3-pip python3-dev build-essential \
      postgresql-client curl ca-certificates jq less \
    && rm -rf /var/lib/apt/lists/*
RUN npm install -g @anthropic-ai/claude-code && npm cache clean --force
RUN git config --system safe.directory '*' \
 && git config --system user.name "software-factory" \
 && git config --system user.email "factory@local"
USER node
# Crear la carpeta como node: así el volumen claude-home hereda dueño node y no root
RUN mkdir -p /home/node/.claude
ENV CLAUDE_CONFIG_DIR=/home/node/.claude \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    FACTORY_PERMISSION_MODE=bypassPermissions
WORKDIR /workspace
CMD ["sleep", "infinity"]
