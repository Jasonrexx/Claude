#!/bin/bash
# Installs Agent Reach (https://github.com/Panniantong/agent-reach) in Claude Code cloud sessions.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

export PATH="$HOME/.local/bin:$PATH"
echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "${CLAUDE_ENV_FILE:-/dev/null}"

# pipx
python3 -m pipx --version >/dev/null 2>&1 || python3 -m pip install --quiet --user pipx

# Agent Reach: the GitHub zip download is blocked by the session proxy, so install from a git clone
if ! command -v agent-reach >/dev/null 2>&1; then
  src="$(mktemp -d)/agent-reach"
  git clone --quiet --depth 1 https://github.com/Panniantong/agent-reach.git "$src"
  python3 -m pipx install --backend pip "$src"
fi

# yt-dlp (YouTube channel)
command -v yt-dlp >/dev/null 2>&1 || python3 -m pipx install --backend pip "yt-dlp[default]"

# Core setup: mcporter, Exa search config, Claude Code skill
agent-reach install --env=auto --system >/dev/null 2>&1 || echo "agent-reach install reported problems; run 'agent-reach doctor'" >&2
