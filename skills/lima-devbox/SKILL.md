---
name: lima-devbox
description: Guide users through setting up a Lima VM for isolated development on macOS. Use when users want to create a sandboxed development environment, set up a VM for AI coding tools, or isolate code execution from their host machine. Walks through VM configuration (name, RAM, shared directories, languages) via wizard, then executes setup systematically.
---

# Lima Devbox Setup Skill

This skill guides users through creating a Lima VM configured for development work on macOS.

## Prerequisites

- macOS with Homebrew installed
- Lima (`brew install lima`)

## Workflow

### Phase 1: Configuration Wizard

Use AskUserQuestion to gather configuration. Ask these in sequence:

**Question 1: VM Name**
- Header: "VM Name"
- Options: "devbox" (default), "sandbox", "test"
- Description: Name for your Lima VM (used in commands like `limactl shell <name>`)

**Question 2: Resources**
- Header: "Resources"
- Options:
  - "Standard (6 CPU, 8GB RAM, 100GB disk)" - Good for most development
  - "Light (4 CPU, 4GB RAM, 50GB disk)" - Lower resource usage
  - "Heavy (8 CPU, 16GB RAM, 200GB disk)" - For large projects or multiple services
- multiSelect: false

**Question 3: Shared Directories**
- Header: "Mounts"
- Options:
  - "Single directory (~/github)" - Recommended, simple setup
  - "Multiple directories" - I'll ask for a comma-separated list
- Description: Only these directories will be accessible from the VM (read/write). The VM has no access to any other host files.

**Question 3b (if multiple selected)**: Ask for comma-separated paths

**Question 4: Git Configuration**
Ask for git user.name and user.email (can use AskUserQuestion with text input)

**Question 5: Languages**
- Header: "Languages"
- Options: "Node.js", "Go", "Rust", "Python"
- multiSelect: true
- Description: Languages to install via mise (version manager)

**Question 6: Tools**
- Header: "Tools"
- Options: "GitHub CLI (gh)", "Docker (nerdctl already included)"
- multiSelect: true
- Description: Optional tools. Note: nerdctl (docker-compatible CLI) is already installed by default - try it before installing Docker.

**Question 6b: AI Coding Agents**
- Header: "AI Agents"
- Options: "Claude Code (Anthropic)", "Gemini CLI (Google)", "Codex CLI (OpenAI)", "OpenCode", "None"
- multiSelect: true
- Description: AI coding assistants to install. All support autonomous/YOLO modes for hands-off operation in this sandboxed environment.

**Question 7: SSH Password (Optional)**
- Header: "SSH Password"
- Options: "No password (key-only)" (default), "Set a password"
- Description: Lima uses SSH keys by default. You can optionally set a password for convenience.

**Question 7b (if password selected)**: Ask user to enter their desired password

**Question 8: Port Forwarding**
- Header: "Ports"
- Options: "8080", "3000", "5000", "5432 (PostgreSQL)", "6379 (Redis)", "None"
- multiSelect: true
- Description: Forward these ports from VM to host. Access VM services at localhost:<port> on your Mac.

**Question 9: SSH Agent Forwarding**
- Header: "SSH Agent"
- Options: "Yes - forward SSH agent (Recommended)", "No"
- multiSelect: false
- Description: Allows the VM to use your Mac's SSH keys for git operations, etc.

**Question 10: VM Type**
- Header: "VM Type"
- First, detect macOS version. If macOS 13+, recommend "vz":
- Options: "vz (Virtualization.framework) - Recommended, faster" (default on macOS 13+), "qemu - More compatible, slower"
- multiSelect: false
- Description: "vz" uses Apple's native virtualization (faster, requires macOS 13+). "qemu" works on older macOS.

**Question 11: Rosetta (Apple Silicon only)**
- Skip this question on Intel Macs
- Header: "Rosetta"
- Options: "Yes - enable Rosetta (Recommended)", "No"
- multiSelect: false
- Description: Run x86_64 Linux binaries in the VM. Useful for compatibility with older tools. Requires vz VM type.

### Phase 2: Setup Execution

After gathering configuration, create a todo list and execute each step:

#### Step 1: Install Lima (if needed)
```bash
limactl --version
```
If not installed, install it:
```bash
brew install lima
```

#### Step 2: Create VM
```bash
limactl start --name=<vm_name> --cpus=<cpus> --memory=<memory> --disk=<disk> -y
```

Wait for VM to be running:
```bash
limactl list --json | jq -r '.[] | select(.name=="<vm_name>") | .status'
```

#### Step 3: Configure VM Settings

Edit `~/.lima/<vm_name>/lima.yaml` to apply user's configuration choices:

**VM Type** (if user selected vz):
```yaml
vmType: "vz"
```

**Rosetta** (if enabled, requires vmType: vz):
```yaml
rosetta:
  enabled: true
```

**SSH Agent Forwarding** (if enabled):
```yaml
ssh:
  forwardAgent: true
```

**Port Forwarding** (for each selected port):
```yaml
portForwards:
- guestPort: 8080
  hostPort: 8080
- guestPort: 3000
  hostPort: 3000
```

**Mounts** - configure ONLY the shared directories (no home directory access):

Find the `mounts:` section and replace it with:
```yaml
mounts:
- location: "<writable_path>"
  writable: true
```

For multiple directories:
```yaml
mounts:
- location: "~/github"
  writable: true
- location: "~/projects"
  writable: true
```

IMPORTANT: Do NOT include a `location: "~"` mount. Only the specified directories should be accessible.

#### Step 4: Restart VM (required after mount changes)
```bash
limactl stop <vm_name>
limactl start <vm_name>
```

#### Step 5: Setup SSH Config Symlink
```bash
mkdir -p ~/.ssh/config.d
ln -sf ~/.lima/<vm_name>/ssh.config ~/.ssh/config.d/<vm_name>
```

Ensure `~/.ssh/config` includes:
```
Include config.d/*
```

After this, user can SSH with: `ssh <vm_name>`

**SSH Authentication Note**: Lima uses key-based authentication by default:
- Creates a private key at `~/.lima/_config/user`
- Sets up the VM user with your macOS username
- Configures all SSH settings in the symlinked config file
- Password authentication is optional (configured in Step 7 if requested)

#### Step 6: Run Base Setup Script
Copy and execute `scripts/setup-vm.sh` in the VM:
```bash
limactl shell <vm_name> -- bash -c "$(cat <skill_path>/scripts/setup-vm.sh)" -- "<git_name>" "<git_email>"
```

This installs system packages, configures git, and sets up .bash_profile for SSH sessions.

#### Step 7: Set SSH Password (if requested)
If user chose to set a password:
```bash
limactl shell <vm_name> -- bash -c "echo '<username>:<password>' | sudo chpasswd"
```

Where `<username>` is the user's macOS username (same as VM user).

#### Step 8: Install Languages (if selected)
```bash
limactl shell <vm_name> -- bash -c "$(cat <skill_path>/scripts/install-mise.sh)" -- <languages>
```

Where `<languages>` is a space-separated list like `nodejs go rust python`.

#### Step 9: Install Optional Tools

For GitHub CLI:
```bash
limactl shell <vm_name> -- bash -c "$(cat <skill_path>/scripts/install-gh.sh)"
```

For Docker (if user specifically wants Docker instead of nerdctl):
```bash
limactl shell <vm_name> -- bash -c "curl -fsSL https://get.docker.com | sh && sudo usermod -aG docker \$USER"
```

Note: nerdctl is already available (`nerdctl run`, `nerdctl build`, etc.) and is docker-compatible. Most users won't need Docker.

#### Step 10: Install AI Coding Agents (if selected)

For Claude Code:
```bash
limactl shell <vm_name> -- bash -c "$(cat <skill_path>/scripts/install-ai-agent.sh)" -- claude
```

For Gemini CLI:
```bash
limactl shell <vm_name> -- bash -c "$(cat <skill_path>/scripts/install-ai-agent.sh)" -- gemini
```

For Codex CLI:
```bash
limactl shell <vm_name> -- bash -c "$(cat <skill_path>/scripts/install-ai-agent.sh)" -- codex
```

For OpenCode:
```bash
limactl shell <vm_name> -- bash -c "$(cat <skill_path>/scripts/install-ai-agent.sh)" -- opencode
```

All agents are configured with aliases for autonomous/YOLO mode operation.

#### Step 11: Verify Setup
```bash
limactl shell <vm_name> -- bash -c "echo 'VM is ready!' && git --version && mise --version"
```

### Phase 3: Post-Setup Summary

After successful setup, provide the user with:

1. **Access commands**:
   - `limactl shell <vm_name>` - Interactive shell
   - `ssh <vm_name>` - SSH access (if config symlink created)

2. **Common Lima commands**:
   - `limactl stop <vm_name>` - Stop the VM
   - `limactl start <vm_name>` - Start the VM
   - `limactl restart <vm_name>` - Restart the VM
   - `limactl delete <vm_name> -f` - Delete the VM

3. **Working with files**:
   - Only files in configured directories (e.g., `~/github`) are accessible from the VM
   - Files are available at the same path in the VM
   - Changes sync bidirectionally between host and VM

4. **Container tools**:
   - `nerdctl` is pre-installed (docker-compatible commands)
   - Example: `nerdctl run -it ubuntu bash`

5. **Port forwarding** (if configured):
   - Forwarded ports are accessible at `localhost:<port>` on your Mac
   - Example: A server running on port 8080 in the VM is available at `localhost:8080`

6. **SSH agent** (if enabled):
   - Your Mac's SSH keys are available inside the VM
   - Git operations using SSH will work without additional configuration

7. **Reference**: Point to `references/lima-commands.md` for full command reference

## Script Locations

Scripts are located in `scripts/` relative to this skill:
- `setup-vm.sh` - Base system setup (packages, git config, bash_profile)
- `install-mise.sh` - Mise installation and language setup
- `install-gh.sh` - GitHub CLI installation
- `install-ai-agent.sh` - AI coding agent installation (Claude Code, Gemini CLI, Codex CLI, OpenCode)

## Error Handling

- If Lima not installed: Guide user to `brew install lima`
- If VM creation fails: Check Lima logs with `limactl logs <vm_name>`
- If script fails: Can re-run individual scripts after SSH into VM
- If mounts don't work: Verify lima.yaml syntax, restart VM

## Notes

- Default Lima template uses Ubuntu 24.04 LTS
- Only explicitly configured directories are mounted (VM has no access to other host files)
- nerdctl (containerd CLI) is included by default for container operations
