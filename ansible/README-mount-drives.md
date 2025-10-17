# SunnyLabX Drive Mounting Playbook

## Overview

The `mount-drives-playbook.yml` configures persistent storage drive mounting on **Node 1 (thousandsunny)** only. This playbook is designed for fresh Linux installations, drive additions, or mount point recovery scenarios.

## ⚠️ Important Warnings

- **NODE-SPECIFIC**: This playbook is **ONLY** for Node 1 (thousandsunny)
- **DO NOT** run on Node 2 (goingmerry) - different storage configuration
- **BACKUP**: Always creates fstab backup before modifications
- **VALIDATION**: Verifies drives exist before attempting to mount

## Drive Configuration

### Node 1 (thousandsunny) Storage Layout

| Drive | UUID | Mount Point | Description |
|-------|------|-------------|-------------|
| HDD-1 | `d5d82cbc-ab7b-419d-8012-2db4888a9985` | `/mnt/hdd-1` | Primary storage drive |
| HDD-2 | `8930a544-9b46-433a-987d-c25add4ed00c` | `/mnt/hdd-2` | Secondary storage drive |
| HDD-3 | `b6f37155-e60d-4daf-9efd-286823fd08e6` | `/mnt/hdd-3` | Tertiary storage drive |
| HDD-4 | `7041c8f0-b09e-4fdd-b04a-42f6c2dc6a6d` | `/mnt/hdd-4` | Quaternary storage drive |

All drives configured with:
- **Filesystem**: ext4
- **Mount Options**: defaults
- **Dump**: 0 (no backup)
- **Pass**: 2 (fsck after root)

## Usage Instructions

### Prerequisites

1. **Physical Setup**: All storage drives connected and detected
2. **SSH Access**: Ansible can connect to thousandsunny
3. **Privileges**: User has sudo access on target node
4. **Inventory**: Node 1 properly defined in `hosts.ini`

### Basic Deployment

```bash
# Deploy to Node 1
cd /workspaces/sunnylabx/ansible
ansible-playbook -i hosts.ini mount-drives-playbook.yml

# Explicitly limit to node1 (safety measure)
ansible-playbook -i hosts.ini mount-drives-playbook.yml --limit node1
```

### Verification Commands

```bash
# Check all mounts are active
ansible node1 -i hosts.ini -m command -a "mount | grep '/mnt/hdd'"

# Verify disk usage
ansible node1 -i hosts.ini -m command -a "df -h /mnt/hdd-*"

# Run built-in verification script
ansible node1 -i hosts.ini -m command -a "/usr/local/bin/verify-mounts.sh"
```

## Safety Features

### Automatic Backups

- **fstab Backup**: Created in `/root/ansible-backups/` before any changes
- **Timestamped**: Each backup includes epoch timestamp
- **Auto-Restore**: Failed operations restore original fstab

### Validation Checks

1. **Node Verification**: Confirms playbook runs only on Node 1
2. **Drive Detection**: Verifies all UUIDs exist in system via `blkid`
3. **Mount Point Creation**: Ensures directories exist before mounting
4. **Mount Verification**: Confirms successful mounting after configuration
5. **fstab Syntax**: Validates fstab syntax with `mount -fav`

### Error Handling

- **Pre-flight Checks**: Validates environment before making changes
- **Rollback Capability**: Restores fstab backup on failure
- **Detailed Logging**: Comprehensive error messages and recovery steps
- **Graceful Failure**: Safe exit with cleanup on errors

## Playbook Structure

### Pre-Tasks
- Node verification (thousandsunny only)
- Drive configuration summary display

### Main Tasks
1. **Backup Management**: Create fstab backup
2. **Drive Validation**: Verify UUIDs exist in system
3. **Mount Point Setup**: Create `/mnt/hdd-*` directories
4. **fstab Configuration**: Add persistent mount entries
5. **System Integration**: Reload systemd and mount drives
6. **Verification**: Confirm all mounts successful

### Post-Tasks
- fstab syntax validation
- Verification script creation
- Disk usage summary

### Handlers
- Systemd daemon reload on configuration changes

### Rescue Block
- Automatic fstab restoration on failure
- Recovery instruction display

## Common Use Cases

### Fresh Linux Installation

After installing Linux on thousandsunny:

```bash
# Configure all storage drives
ansible-playbook -i hosts.ini mount-drives-playbook.yml
```

### Drive Addition/Replacement

When adding new drives or replacing failed ones:

1. Update UUIDs in playbook variables
2. Run playbook to reconfigure mounts
3. Verify new configuration

### Mount Point Recovery

After system issues or manual fstab changes:

```bash
# Restore proper mount configuration
ansible-playbook -i hosts.ini mount-drives-playbook.yml
```

## Troubleshooting

### Drive Not Found

```bash
# Check if drives are detected
ansible node1 -i hosts.ini -m command -a "lsblk"
ansible node1 -i hosts.ini -m command -a "blkid"

# Verify UUIDs in playbook match system
```

### Mount Failures

```bash
# Check mount status
ansible node1 -i hosts.ini -m command -a "mountpoint /mnt/hdd-1"

# Review system logs
ansible node1 -i hosts.ini -m command -a "journalctl -u systemd-mount | tail -20"
```

### fstab Issues

```bash
# Validate fstab syntax
ansible node1 -i hosts.ini -m command -a "mount -fav"

# Check for duplicates
ansible node1 -i hosts.ini -m command -a "grep '/mnt/hdd' /etc/fstab"
```

## Recovery Procedures

### Manual fstab Restore

If playbook fails and auto-restore doesn't work:

```bash
# Find backup files
ls -la /root/ansible-backups/fstab.backup.*

# Restore manually
cp /root/ansible-backups/fstab.backup.TIMESTAMP /etc/fstab
mount -a
```

### Emergency Unmount

If drives need to be unmounted:

```bash
# Unmount specific drive
umount /mnt/hdd-1

# Unmount all HDD drives
umount /mnt/hdd-*

# Remove from fstab (manual edit required)
nano /etc/fstab
```

## Configuration Variables

### Modifying Drive Configuration

To add/remove/modify drives, edit the `storage_drives` variable in the playbook:

```yaml
storage_drives:
  - uuid: "your-drive-uuid-here"
    mount_point: "/mnt/new-drive"
    filesystem: "ext4"
    mount_options: "defaults"
    dump: "0"
    pass: "2"
    description: "New storage drive"
```

### Backup Configuration

Customize backup behavior:

```yaml
fstab_backup_dir: "/custom/backup/path"  # Default: /root/ansible-backups
```

## Integration with SunnyLabX

This playbook integrates with the broader SunnyLabX infrastructure:

- **Docker Services**: Mounted drives provide storage for containers
- **Media Services**: HDD mounts used for Plex, downloads, etc.
- **Backup Services**: Storage drives provide backup destinations
- **Monitoring**: Mount status monitored by infrastructure services

## Security Considerations

- **Root Access**: Playbook requires root privileges for mount operations
- **Backup Protection**: fstab backups stored in root-only directory
- **Validation**: Multiple checks prevent system corruption
- **Isolation**: Node-specific operation prevents cross-contamination

## Maintenance

### Regular Checks

```bash
# Weekly mount verification
ansible-playbook -i hosts.ini mount-drives-playbook.yml --check

# Monthly full run (idempotent)
ansible-playbook -i hosts.ini mount-drives-playbook.yml
```

### Drive Health Monitoring

```bash
# Check filesystem health
ansible node1 -i hosts.ini -m command -a "fsck -n /dev/disk/by-uuid/UUID"

# Monitor disk usage
ansible node1 -i hosts.ini -m command -a "/usr/local/bin/verify-mounts.sh"
```

This playbook provides enterprise-grade storage management for Node 1, ensuring reliable and safe drive mounting operations in your SunnyLabX infrastructure.