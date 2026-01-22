# Lima Command Reference

Quick reference for common Lima VM operations.

## VM Lifecycle

```bash
# List all VMs
limactl list

# Create and start a new VM (uses default Ubuntu template)
limactl start --name=<name> -y

# Start an existing VM
limactl start <name>

# Stop a VM
limactl stop <name>

# Restart a VM
limactl restart <name>

# Delete a VM (force flag removes without confirmation)
limactl delete <name> -f
```

## Accessing the VM

```bash
# Interactive shell (recommended)
limactl shell <name>

# Run a single command
limactl shell <name> -- <command>

# SSH access (if config symlink created)
ssh <name>

# Copy files using SCP
scp localfile <name>:/path/in/vm
scp <name>:/path/in/vm localfile
```

## VM Configuration

```bash
# Edit VM configuration (stop VM first)
vim ~/.lima/<name>/lima.yaml

# View VM logs
limactl logs <name>

# Show VM info
limactl info <name>
```

## Common lima.yaml Settings

### CPU, Memory, Disk
```yaml
cpus: 6
memory: "8GiB"
disk: "100GiB"
```

### Mount Configuration (Isolated Setup)

Only mount specific directories - do NOT mount home directory:

```yaml
mounts:
- location: "~/github"
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

### Port Forwarding
```yaml
portForwards:
- guestPort: 3000
  hostPort: 3000
- guestPort: 8080
  hostPort: 8080
```

### VM Type and Rosetta (Apple Silicon)
```yaml
# Use Apple's Virtualization.framework (faster, macOS 13+)
vmType: "vz"

# Enable Rosetta for x86_64 binary support (requires vmType: vz)
rosetta:
  enabled: true
```

### SSH Agent Forwarding
```yaml
ssh:
  forwardAgent: true
```

## Container Tools

Lima includes containerd with nerdctl by default (docker-compatible CLI):

```bash
# Run a container
nerdctl run -it ubuntu bash

# Build an image
nerdctl build -t myimage .

# List containers
nerdctl ps -a

# Pull an image
nerdctl pull nginx
```

## Troubleshooting

```bash
# Check VM status
limactl list --json | jq '.[] | {name, status}'

# View detailed logs
limactl logs <name> --tail 100

# If VM is stuck starting
limactl stop --force <name>
limactl start <name>

# Factory reset (keeps config, resets disk)
limactl factory-reset <name>
```

## SSH Configuration

Lima uses **key-based authentication** (no passwords):
- Private key: `~/.lima/_config/user`
- VM username: Same as your macOS username
- All settings are pre-configured in Lima's ssh.config file

To enable `ssh <name>`:

1. Create config directory:
   ```bash
   mkdir -p ~/.ssh/config.d
   ```

2. Ensure `~/.ssh/config` includes:
   ```
   Include config.d/*
   ```

3. Symlink Lima's SSH config:
   ```bash
   ln -sf ~/.lima/<name>/ssh.config ~/.ssh/config.d/<name>
   ```

## File Sharing Notes

- Only explicitly configured directories are accessible from the VM
- Files sync bidirectionally between host and VM
- File permissions: Lima maps host user to VM user
- Large file operations may be slower than native disk
