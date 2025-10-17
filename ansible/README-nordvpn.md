# NordVPN Ansible Configuration for SunnyLabX

This directory contains Ansible playbooks and configuration for setting up NordVPN across the SunnyLabX infrastructure.

## Overview

The NordVPN setup provides:
- **Secure Internet Access**: All traffic routed through NordVPN servers
- **IP Protection**: Hide real IP addresses from external services
- **DNS Security**: Use secure DNS servers (Cloudflare + Google)
- **Kill Switch**: Prevent IP leaks if VPN disconnects
- **Auto-Connect**: Automatic VPN connection on boot
- **Per-Node Configuration**: Optimized settings for each node's role

## Files Structure

```
ansible/
├── nordvpn-playbook.yml          # Main NordVPN installation playbook
├── group_vars/all/
│   ├── nordvpn.yml               # NordVPN configuration variables
│   └── vault.yml.example         # Example vault file for secure credentials
├── hosts.ini                     # Inventory file (existing)
└── README-nordvpn.md            # This documentation
```

## Prerequisites

### 1. NordVPN Account & Token
- Active NordVPN subscription
- Access token from NordVPN dashboard

### 2. Ansible Setup
```bash
# Install Ansible (if not already installed)
sudo apt update
sudo apt install ansible

# Verify installation
ansible --version
```

### 3. SSH Access
- SSH keys configured for both nodes
- Sudo access on target nodes

## Setup Instructions

### Step 1: Configure Vault for Secure Credentials

```bash
# 1. Create vault file from example
cd ansible
cp group_vars/all/vault.yml.example group_vars/all/vault.yml

# 2. Edit vault.yml with your actual NordVPN token
nano group_vars/all/vault.yml
# Replace REPLACE_WITH_YOUR_ACTUAL_NORDVPN_TOKEN with your real token

# 3. Encrypt the vault file
ansible-vault encrypt group_vars/all/vault.yml

# 4. Remove the example file
rm group_vars/all/vault.yml.example
```

### Step 2: Customize Configuration (Optional)

Edit `group_vars/all/nordvpn.yml` to customize:
- Server preferences per node
- DNS servers
- Security settings
- Connection timeouts

### Step 3: Verify Inventory

Ensure `hosts.ini` has correct IP addresses and SSH settings:
```ini
[all]
node1 ansible_host=192.168.0.254 ansible_user=shawnji
node2 ansible_host=192.168.0.253 ansible_user=shawnji
```

### Step 4: Run the Playbook

```bash
# Test connectivity first
ansible -i hosts.ini all -m ping --ask-vault-pass

# Run NordVPN installation playbook
ansible-playbook -i hosts.ini nordvpn-playbook.yml --ask-vault-pass

# Run with verbose output for troubleshooting
ansible-playbook -i hosts.ini nordvpn-playbook.yml --ask-vault-pass -vvv
```

### Step 5: Verify Installation

```bash
# Check status on both nodes
ansible -i hosts.ini all -m shell -a "nordvpn status" --ask-vault-pass

# Run the status check script
ansible -i hosts.ini all -m shell -a "/usr/local/bin/nordvpn-status" --ask-vault-pass
```

## Configuration Details

### Node-Specific Settings

#### Node 1 (thousandsunny) - Media/Content Hub
- **Server**: Los Angeles (P2P-optimized)
- **Purpose**: Media downloading and streaming
- **Features**: P2P allowed, longer timeouts
- **Kill Switch**: Enabled (prevents IP leaks during downloads)

#### Node 2 (goingmerry) - Management Hub  
- **Server**: Los Angeles (Standard)
- **Purpose**: Management and monitoring
- **Features**: Stability-focused, standard timeouts
- **Kill Switch**: Enabled (protects management traffic)

### Security Features

1. **Kill Switch**: Blocks all internet if VPN disconnects
2. **DNS Protection**: Routes DNS through secure servers
3. **LAN Discovery**: Allows local network access
4. **Auto-Connect**: Connects automatically on boot
5. **IP Leak Protection**: Prevents accidental IP exposure

### DNS Configuration

Primary DNS servers:
- `1.1.1.1` (Cloudflare - fast, privacy-focused)
- `8.8.8.8` (Google - reliable)

## Management Commands

### Basic NordVPN Commands
```bash
# Check connection status
nordvpn status

# Connect to specific server
nordvpn connect Los_Angeles

# Disconnect
nordvpn disconnect

# List available countries/servers
nordvpn countries
nordvpn cities United_States

# Check account info
nordvpn account
```

### Configuration Commands
```bash
# View current settings
nordvpn settings

# Change server
nordvpn set autoconnect on Denver

# Toggle kill switch
nordvpn set killswitch enabled

# Change DNS
nordvpn set dns 1.1.1.1 8.8.8.8

# Reset to defaults
nordvpn set dns disabled
```

### Monitoring Commands
```bash
# Custom status script (created by playbook)
/usr/local/bin/nordvpn-status

# Check public IP
curl ifconfig.me

# Test DNS resolution
nslookup google.com

# Check for IP leaks
curl -s https://api.ipify.org && echo
```

## Troubleshooting

### Common Issues

#### 1. Authentication Failed
```bash
# Re-login with token
nordvpn logout
nordvpn login --token YOUR_TOKEN
```

#### 2. Connection Issues
```bash
# Check service status
sudo systemctl status nordvpnd

# Restart service
sudo systemctl restart nordvpnd

# Check logs
sudo journalctl -u nordvpnd -f
```

#### 3. DNS Not Working
```bash
# Reset DNS
nordvpn set dns disabled
nordvpn set dns 1.1.1.1 8.8.8.8

# Test DNS resolution
nslookup google.com
```

#### 4. Docker Issues
```bash
# If Docker containers can't reach internet
nordvpn set lan-discovery enabled

# For Docker networks, may need to disable threat protection
nordvpn set threatprotectionlite disabled
```

### Playbook Issues

#### Re-run Specific Tasks
```bash
# Run only the connection tasks
ansible-playbook -i hosts.ini nordvpn-playbook.yml --tags "connect" --ask-vault-pass

# Skip installation (if already installed)
ansible-playbook -i hosts.ini nordvpn-playbook.yml --skip-tags "install" --ask-vault-pass
```

#### Debug Mode
```bash
# Run with maximum verbosity
ansible-playbook -i hosts.ini nordvpn-playbook.yml --ask-vault-pass -vvv
```

## Integration with SunnyLabX

### Service Compatibility

1. **Docker Services**: NordVPN works with all containerized services
2. **Media Automation**: ARR suite works through VPN for privacy
3. **Remote Access**: Cloudflare Tunnel still functions normally
4. **Local Services**: LAN discovery allows internal service access

### Performance Considerations

1. **Latency**: ~10-50ms additional latency depending on server
2. **Bandwidth**: Minimal impact on gigabit connections
3. **CPU Usage**: NordLynx protocol is lightweight
4. **Memory**: ~50MB RAM usage per node

### Security Benefits

1. **ISP Privacy**: Hide traffic from internet service provider
2. **Geolocation**: Appear to be in different location
3. **Public WiFi**: Secure connections on untrusted networks
4. **Port Forwarding**: Hide real IP from external connections

## Maintenance

### Regular Tasks

```bash
# Check VPN status (weekly)
ansible -i hosts.ini all -m shell -a "nordvpn status"

# Update NordVPN client (monthly)
ansible -i hosts.ini all -m shell -a "nordvpn update" --become

# Test IP leak protection
ansible -i hosts.ini all -m shell -a "curl -s ifconfig.me"
```

### Server Optimization

```bash
# Test different servers for best performance
nordvpn connect Los_Angeles
speedtest-cli
nordvpn connect San_Francisco  
speedtest-cli
```

## Security Considerations

1. **Token Security**: Keep vault.yml encrypted and secure
2. **Access Logs**: NordVPN has no-logs policy
3. **Kill Switch**: Always keep enabled for security
4. **DNS Leaks**: Regularly test for DNS leaks
5. **WebRTC Leaks**: Consider browser extensions for WebRTC protection

---

*This configuration is part of the SunnyLabX infrastructure. For more information, see the main documentation in the repository root.*