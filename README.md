# Lima Devbox

A Claude Code skill for setting up Lima VMs as isolated development environments on macOS.

## What is Lima?

**Lima** stands for **Linux on Mac**. It's a lightweight tool that creates Linux virtual machines on macOS with automatic file sharing and port forwarding.

We use Lima for this project because:
- **Isolation**: AI coding assistants can execute code in a sandboxed environment without access to your entire filesystem
- **Security**: Only directories you explicitly share are visible to the VM
- **Native performance**: Uses Apple's Virtualization.framework (vz) on modern Macs for near-native speed
- **Simplicity**: No Docker Desktop or heavy virtualization software required
- **Compatibility**: Run Linux tools and binaries that don't work natively on macOS

Lima is particularly well-suited for AI-assisted development where you want the assistant to have full autonomy within a controlled environment.

## What is this?

This is a Claude Code plugin that provides a guided wizard for creating and configuring Lima virtual machines. It helps you:

- Create a sandboxed Ubuntu VM for development
- Configure shared directories between host and VM (only specified directories are accessible)
- Install development tools (mise, Node.js, Go, Rust, Python, etc.)
- Set up GitHub CLI and Claude Code CLI

## Prerequisites

- macOS
- [Homebrew](https://brew.sh)
- [Lima](https://lima-vm.io): `brew install lima`
- [Claude Code](https://claude.ai/claude-code)

## Installation

Add this plugin to your Claude Code configuration:

```bash
# Clone the repo
git clone https://github.com/yourusername/lima-devbox.git ~/github/lima-devbox

# Add to Claude Code (in your project or globally)
claude mcp add-plugin ~/github/lima-devbox
```

Or add manually to your Claude settings.

## Usage

In a Claude Code session, invoke the skill:

```
/lima-devbox
```

The skill will walk you through:

1. **VM Configuration**: Name, CPU, RAM, disk size
2. **Mount Setup**: Which directories the VM can access (only these directories are visible to the VM)
3. **Git Configuration**: Your name and email for commits
4. **Language Selection**: Node.js, Go, Rust, Python via mise
5. **Tool Installation**: GitHub CLI, Claude Code CLI, Docker (note: nerdctl is already included)

After the wizard, it executes the setup automatically.

## Manual Script Usage

The setup scripts can also be run manually inside a Lima VM:

```bash
# Base system setup
bash scripts/setup-vm.sh "Your Name" "your@email.com"

# Install mise with languages
bash scripts/install-mise.sh nodejs go python

# Install GitHub CLI
bash scripts/install-gh.sh

# Install Claude Code CLI (adds --dangerously-skip-permissions alias)
bash scripts/install-claude.sh
```

## Project Structure

```
lima-devbox/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── skills/
│   └── lima-devbox/
│       ├── SKILL.md         # Main skill definition
│       ├── scripts/         # Setup scripts
│       │   ├── setup-vm.sh
│       │   ├── install-mise.sh
│       │   ├── install-gh.sh
│       │   └── install-claude.sh
│       └── references/
│           └── lima-commands.md
└── README.md
```

## Common Commands

After setup, use these commands:

```bash
# Access your VM
limactl shell dev        # Interactive shell
ssh dev                  # SSH (if configured)

# VM lifecycle
limactl stop dev         # Stop VM
limactl start dev        # Start VM
limactl restart dev      # Restart VM
limactl delete dev -f    # Remove VM

# Run commands directly
limactl shell dev -- npm install
limactl shell dev -- go build .

# Container tools (nerdctl is pre-installed)
limactl shell dev -- nerdctl run -it ubuntu bash
```

## Isolation Model

The VM is configured for isolation:
- Only explicitly configured directories (e.g., `~/github`) are accessible from the VM
- The VM has no access to any other host files
- Files in shared directories sync bidirectionally

## Troubleshooting

**VM won't start:**
```bash
limactl logs dev
limactl stop --force dev && limactl start dev
```

**Mounts not working:**
- Check `~/.lima/dev/lima.yaml` for correct mount configuration
- Ensure only your shared directories are listed (no `location: "~"` entry)
- Restart VM after changing mounts

**SSH not working:**
- Ensure `~/.ssh/config` has `Include config.d/*`
- Check symlink exists: `ls -la ~/.ssh/config.d/dev`

## License

MIT
