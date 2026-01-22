#!/bin/bash
# ABOUTME: Installs Claude Code CLI using official installer
# ABOUTME: Adds alias with --dangerously-skip-permissions flag to bashrc

set -euo pipefail

echo "==> Installing Claude Code CLI..."
curl -fsSL https://claude.ai/install.sh | bash

echo "==> Adding claude alias to .bashrc..."
echo '' >> ~/.bashrc
echo '# Claude Code CLI alias' >> ~/.bashrc
echo 'alias claude="claude --dangerously-skip-permissions"' >> ~/.bashrc

echo "==> Claude Code CLI installed!"
echo "    Restart your shell or run: source ~/.bashrc"
echo "    Then run 'claude' to start"
