# sunnylabx
# Service Layout:

**Network & Management - Node #2**

- Nginx Proxy Manager - Primary reverse proxy. Manages internal traffic routing and SSL certificates.
- AdGuard Home - Network-wide ad blocking and local DNS resolution.
- Portainer (Controller) - Central Web UI for the entire docker cluster.
- Cloudflare Tunnel - Secure external access without port forwarding or exposing public IPs.

**Security and Identity Node - #2**

- Authentik - Centralized identity provider for Single Sign-On (SSO) across all services.
- Wazuh - The core Security Information and Event Management (SIEM) system.
- CrowdSec - Collaborative Intrusion Prevention System (IPS).
- Suricata - Network Intrusion Detection System (IDS).
- Vaultwarden - Self-hosted password manager for securely storing credentials.

**Monitoring Node - #2**

- Grafana - The primary dashboard for visualizing all homelab metrics and logs.
- Prometheus - Collects time-series metrics from all nodes and services.
- Loki & Promtail - Log aggregation system for all non-security logs.
- Uptime Kuma - Service uptime and status monitoring.
- Watchtower - Automatically updates running Docker containers to their latest versions.

**Automation - Node #2**

- n8n - Workflow automation engine to connect services and create automated tasks.

---

**Core Infrastructure - Node #1**

- Portainer - Connects this node to the main Portainer controller for remote management.

**Storage & Development - Node #1**

- Gitea - Self-hosted Git server for all homelab configuration files and personal code.
- Duplicati - Manages scheduled backups of all critical homelab data to various storage backends.

**Cloud & Productivity - Node #1**

- Nextcloud AIO - Private cloud for file storage, calendar, contacts, and photos.

**Media Services - Node #1**

- Plex / Jellyfin - Primary media servers for streaming movies, TV shows, and music.
- Immich - Self-hosted photo and video backup solution (Google Photos alternative).
- Kavita - Digital library and reader for e-books and comics.

**Media Automation (*arr Suite)**

- Prowlarr ****- Manages indexers for Sonarr and Radarr.
- Sonarr ****- Automates the process of finding, downloading, and organizing TV shows.
- Radarr - Automates the process of finding, downloading, and organizing movies.
- Bazarr - Manages and downloads subtitles for Sonarr and Radarr.
- Overseerr - A user-friendly request management system for Plex/Jellyfin.
- qBittorrent / Deluge - The download clients that handle the actual torrenting.

**AI & Machine Learning**

- Ollama + WebUI - Runs local Large Language Models (LLMs) for experimentation and use with other services.

---

## Docker Compose File Mapping

The Docker Compose files are organized by node and category to enable modular deployment and service management. Each compose file sits within a parent folder reflecting its category for clarity.

### Node #2 (goingmerry)

| Category | File Path | Services |
|----------|-----------|----------|
| **Networking** | `goingmerry/networking/docker-compose-nginx.yml` | Nginx Proxy Manager, AdGuard Home, Cloudflare Tunnel |
| **Management** | `goingmerry/management/docker-compose-portainer.yml` | Portainer Controller |
| **Security** | `goingmerry/security/docker-compose-security.yml` | Authentik, Wazuh, CrowdSec, Suricata, Vaultwarden |
| **Monitoring** | `goingmerry/monitoring/docker-compose-monitoring.yml` | Prometheus, Grafana, Loki, Promtail, Uptime Kuma, Watchtower |
| **Automation** | `goingmerry/automation/docker-compose-automation.yml` | n8n |

### Node #1 (thousandsunny)

| Category | File Path | Services |
|----------|-----------|----------|
| **Infrastructure** | `thousandsunny/infra/docker-compose-gitea.yml` | Gitea, Duplicati, Nextcloud AIO |
| **Media** | `thousandsunny/media/docker-compose-media.yml` | Plex, Jellyfin, Immich, Kavita, ARR Suite, Overseerr |
| **Torrent** | `thousandsunny/torrent/docker-compose-torrent.yml` | qBittorrent, Deluge |
| **AI** | `thousandsunny/ai/docker-compose-ai.yml` | Ollama, Ollama WebUI |
| **Agents** | `thousandsunny/agents/docker-compose-portainer-agent.yml` | Portainer Agent |

### Usage

To deploy a specific category of services:
```bash
# Example: Deploy monitoring stack on Node #2
cd goingmerry/monitoring
docker-compose up -d

# Example: Deploy media services on Node #1
cd thousandsunny/media
docker-compose up -d
```

Each compose file contains placeholder configurations that can be customized with proper environment variables, volumes, and network settings.

---

## 🌐 External Access & Security

### Cloudflare Tunnel Integration
SunnyLabX uses **Cloudflare Tunnel** for secure external access, eliminating the need for:
- **Port forwarding** on your router
- **Exposing your public IP address**
- **Opening firewall ports** to the internet
- **Dynamic DNS** services
- **Self-signed certificates** or certificate management

**Benefits:**
- **Zero Trust Security**: All traffic passes through Cloudflare's secure edge network
- **DDoS Protection**: Built-in protection against distributed attacks
- **Automatic SSL**: Cloudflare handles SSL/TLS termination and certificates
- **Global Performance**: Cloudflare's edge network provides fast global access
- **Private Network**: Your home lab remains completely private from the internet
- **Authentication**: Integration with Cloudflare Access for additional security layers

**Setup Requirements:**
- Cloudflare account with a registered domain
- Cloudflare Tunnel configured to point to your Nginx Proxy Manager
- Domain DNS managed through Cloudflare

---

## Ansible Infrastructure Automation

SunnyLabX includes comprehensive Ansible automation for infrastructure deployment and configuration management. The Ansible setup provides automated installation and configuration of all required packages, security settings, and Docker infrastructure across both nodes.

### 📁 Ansible Structure

```
ansible/
├── hosts.ini              # Inventory with node definitions
├── playbook.yml           # Base system setup and configuration
└── docker-playbook.yml    # Docker installation and configuration
```

### 🏗️ Node Configuration

**Node Definitions:**
- **node1** (thousandsunny.lab.local) - Application & Content Hub
- **node2** (goingmerry.lab.local) - Management & Control Hub

**Host Groups:**
- `[thousandsunny]` - Node #1 application workloads
- `[goingmerry]` - Node #2 management services
- `[docker_nodes]` - All Docker-enabled nodes

### 🚀 Deployment Workflow

#### Step 1: Prepare Inventory
Edit `ansible/hosts.ini` to match your environment:
```ini
node1 ansible_host=your-node1-ip ansible_user=your-user
node2 ansible_host=your-node2-ip ansible_user=your-user
```

#### Step 2: Base System Setup
Deploy base packages, security configuration, and system setup:
```bash
ansible-playbook -i ansible/hosts.ini ansible/playbook.yml
```

**What this installs:**
- Essential packages: curl, wget, git, htop, build tools
- Security tools: aide, lynis, ufw firewall
- System utilities: openssh-server, samba, smartmontools
- Development tools: python3-pip, pipx
- Repository: Clones SunnyLabX to `/opt/sunnylabx`

#### Step 3: Docker Infrastructure
Install and configure Docker on all nodes:
```bash
ansible-playbook -i ansible/hosts.ini ansible/docker-playbook.yml
```

**What this configures:**
- Docker engine and Docker Compose
- User permissions for Docker management
- Python libraries for container automation
- Docker service startup and testing

#### Step 4: Service Deployment
Navigate to service categories and deploy:
```bash
# On Node #2 (Management)
ssh user@goingmerry.lab.local
cd /opt/sunnylabx/goingmerry/networking
docker-compose up -d

# On Node #1 (Applications)  
ssh user@thousandsunny.lab.local
cd /opt/sunnylabx/thousandsunny/media
docker-compose up -d
```

### 🔧 Advanced Usage

#### Selective Deployment
Use tags for specific components:
```bash
# Install only base packages
ansible-playbook -i ansible/hosts.ini ansible/playbook.yml --tags "packages,base"

# Configure only security/firewall
ansible-playbook -i ansible/hosts.ini ansible/playbook.yml --tags "security,firewall"

# Docker verification only
ansible-playbook -i ansible/hosts.ini ansible/docker-playbook.yml --tags "verify,test"
```

#### Target Specific Nodes
Deploy to individual nodes or groups:
```bash
# Management node only
ansible-playbook -i ansible/hosts.ini ansible/playbook.yml --limit goingmerry

# Application nodes only
ansible-playbook -i ansible/hosts.ini ansible/playbook.yml --limit thousandsunny
```

#### Check Mode (Dry Run)
Preview changes without applying:
```bash
ansible-playbook -i ansible/hosts.ini ansible/playbook.yml --check
```

### 🔒 Security Features

- **SSH Protection**: OpenSSH rules configured before firewall activation
- **UFW Firewall**: Automatic configuration with service-specific ports
- **User Management**: Proper Docker group permissions
- **Package Security**: Only essential packages installed
- **Connection Safety**: SSH connections remain uninterrupted during deployment

### 🏢 Node-Specific Configuration

**Node #2 (goingmerry) - Management Hub:**
- **Firewall Ports**: 9000 (Portainer), 3000 (Grafana), 9090 (Prometheus), 3100 (Loki), 8080 (NPM), 5000 (n8n)
- **Data Directories**: Management service data persistence
- **Role**: Central monitoring, security, and cluster management

**Node #1 (thousandsunny) - Application Hub:**
- **Firewall Ports**: 32400 (Plex), 8096 (Jellyfin), 3001 (Immich), ARR suite, download clients, AI services
- **Data Directories**: Media storage, download management, application data
- **Role**: Content services, storage, development, and AI workloads

### 🔄 Maintenance and Updates

```bash
# Update system packages
ansible-playbook -i ansible/hosts.ini ansible/playbook.yml --tags "packages"

# Restart Docker services
ansible-playbook -i ansible/hosts.ini ansible/docker-playbook.yml --tags "services"

# Full redeployment
ansible-playbook -i ansible/hosts.ini ansible/playbook.yml
ansible-playbook -i ansible/hosts.ini ansible/docker-playbook.yml
```

### 📋 Troubleshooting

**Common Issues:**
- **SSH Connection**: Ensure SSH keys are configured and accessible
- **Docker Group**: Log out/in after first run for Docker permissions
- **Firewall**: SSH rules applied before UFW activation prevents lockout
- **Permissions**: Repository cloned with correct user ownership

**Verification Commands:**
```bash
# Test connectivity
ansible all -i ansible/hosts.ini -m ping

# Check Docker status
ansible docker_nodes -i ansible/hosts.ini -m shell -a "docker --version"

# Verify services
ansible all -i ansible/hosts.ini -m shell -a "systemctl status docker"
```
