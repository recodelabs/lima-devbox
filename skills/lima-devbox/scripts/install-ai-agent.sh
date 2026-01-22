#!/bin/bash
# ABOUTME: Installs AI coding agents (Claude Code, Gemini CLI, Codex CLI, OpenCode)
# ABOUTME: Usage: install-ai-agent.sh <agent> where agent is claude, gemini, codex, or opencode

set -euo pipefail

AGENT="${1:-}"

if [[ -z "$AGENT" ]]; then
    echo "Usage: install-ai-agent.sh <agent>"
    echo "Agents: claude, gemini, codex, opencode"
    exit 1
fi

# Ensure npm is available for agents that need it
ensure_npm() {
    if ! command -v npm &> /dev/null; then
        if [[ -f "$HOME/.local/bin/mise" ]]; then
            eval "$($HOME/.local/bin/mise activate bash)"
        fi
    fi

    if ! command -v npm &> /dev/null; then
        echo "ERROR: npm not found. Please install Node.js first."
        echo "       Run install-mise.sh with 'nodejs' argument"
        exit 1
    fi
}

case "$AGENT" in
    claude)
        echo "==> Installing Claude Code..."
        curl -fsSL https://claude.ai/install.sh | bash

        echo "==> Adding claude alias to .bashrc..."
        echo '' >> ~/.bashrc
        echo '# Claude Code CLI alias (YOLO mode)' >> ~/.bashrc
        echo 'alias claude="claude --dangerously-skip-permissions"' >> ~/.bashrc

        echo "==> Claude Code installed!"
        echo "    Run 'claude' to start (uses --dangerously-skip-permissions by default)"
        ;;

    gemini)
        echo "==> Installing Gemini CLI..."
        ensure_npm
        npm install -g @google/gemini-cli

        echo "==> Adding gemini alias to .bashrc..."
        echo '' >> ~/.bashrc
        echo '# Gemini CLI alias (YOLO mode)' >> ~/.bashrc
        echo 'alias gemini="gemini -y"' >> ~/.bashrc

        echo "==> Gemini CLI installed!"
        echo "    Run 'gemini' to start (auto-confirms with -y by default)"
        ;;

    codex)
        echo "==> Installing Codex CLI..."
        ensure_npm
        npm install -g @openai/codex

        echo "==> Adding codex alias to .bashrc..."
        echo '' >> ~/.bashrc
        echo '# Codex CLI alias (full auto mode)' >> ~/.bashrc
        echo 'alias codex="codex --full-auto"' >> ~/.bashrc

        echo "==> Codex CLI installed!"
        echo "    Run 'codex' to start (uses --full-auto by default)"
        ;;

    opencode)
        echo "==> Installing OpenCode..."
        curl -fsSL https://opencode.ai/install | bash

        echo "==> OpenCode installed!"
        echo "    Run 'opencode' to start"
        ;;

    *)
        echo "ERROR: Unknown agent '$AGENT'"
        echo "Agents: claude, gemini, codex, opencode"
        exit 1
        ;;
esac

echo ""
echo "Restart your shell or run: source ~/.bashrc"
