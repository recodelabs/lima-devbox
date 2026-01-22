#!/bin/bash
# ABOUTME: Installs mise (version manager) and configures requested languages
# ABOUTME: Usage: install-mise.sh [nodejs] [go] [rust] [python]

set -euo pipefail

LANGUAGES=("$@")

echo "==> Installing mise..."
curl https://mise.run | sh

# Add mise to shell profile
SHELL_RC="$HOME/.bashrc"
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

# Check if mise activation already exists
if ! grep -q 'mise activate' "$SHELL_RC" 2>/dev/null; then
    echo '' >> "$SHELL_RC"
    echo '# mise (version manager)' >> "$SHELL_RC"
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> "$SHELL_RC"
fi

# Source mise for current session
export PATH="$HOME/.local/bin:$PATH"
eval "$(~/.local/bin/mise activate bash)"

echo "==> Installing languages: ${LANGUAGES[*]:-none}"

for lang in "${LANGUAGES[@]}"; do
    case "$lang" in
        nodejs|node)
            echo "    Installing Node.js (latest LTS)..."
            ~/.local/bin/mise use --global node@lts
            ;;
        go|golang)
            echo "    Installing Go (latest)..."
            ~/.local/bin/mise use --global go@latest
            ;;
        rust)
            echo "    Installing Rust (latest)..."
            ~/.local/bin/mise use --global rust@latest
            ;;
        python)
            echo "    Installing Python (latest)..."
            ~/.local/bin/mise use --global python@latest
            ;;
        *)
            echo "    Unknown language: $lang (skipping)"
            ;;
    esac
done

echo "==> Mise setup complete!"
echo "    Restart your shell or run: eval \"\$(~/.local/bin/mise activate bash)\""
