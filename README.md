# SunnyLabX Home Lab Infrastructure

A comprehensive dual Proxmox cluster home lab infrastructure with 48-50 optimized containerized services providing enterprise-grade networking, security, monitoring, media management, development tools, IoT automation, and communication platforms.

## 🏗️ Dual Proxmox Architecture Overview

**Total Services**: 48-50 containers across dual Proxmox cluster (optimized from 53)
- **Node #1 (ThousandSunny)**: Proxmox VE + Ubuntu LXC (36 containers) - Applications & Storage Hub
- **Node #2 (GoingMerry)**: Proxmox VE + Ubuntu LXC (13 containers) - Management & Security Hub
- **Wazuh Manager VM**: Dedicated SIEM/IDS platform (4GB RAM)

### **Service Optimization Benefits**
- **Native Management**: Proxmox web UI replaces Portainer completely
- **Integrated Backups**: Proxmox backup solutions replace Duplicati
- **Built-in Monitoring**: Proxmox + Wazuh monitoring replaces Uptime Kuma & Watchtower
- **Resource Efficiency**: 2.75-3.75GB RAM freed through service elimination
- **Professional Operations**: Enterprise virtualization with VM/LXC isolation

## 🚢 Node #2 (GoingMerry) - Proxmox Management & Security Hub

**Infrastructure**: Intel Mini PC, 16GB DDR4, 500GB NVMe, Proxmox VE 8.x
**Services**: 13 containers in Ubuntu LXC + Wazuh Manager VM

### **Network & External Access** (3 services)
- **Nginx Proxy Manager** - Primary reverse proxy with SSL certificate management
- **Cloudflare Tunnel** - Secure external access without port forwarding
- **Traefik** - Load balancer and reverse proxy

### **Native Proxmox Management** *(Eliminated Services)*
- ~~**Portainer**~~ → **Proxmox Web UI** - Native cluster container management
- ~~**Duplicati**~~ → **Proxmox Backup Server** - Native VM/LXC backups
- ~~**Watchtower**~~ → **Proxmox Updates** - Native package management
- ~~**Uptime Kuma**~~ → **Proxmox Monitoring + Wazuh** - Integrated monitoring

### **Security & Identity** (5 services)
- **Authentik** - Enterprise SSO and identity provider for all services
- **CrowdSec** - Collaborative Intrusion Prevention System (IPS)
- **Suricata** - Network Intrusion Detection System (IDS)
- **Vaultwarden** - Self-hosted password manager (Bitwarden compatible)
- **Wazuh Agent** - Security monitoring client

### **Monitoring & Observability** (4 services) *(Optimized)*
- **Grafana** - Primary dashboard for visualizing all homelab metrics and logs
- **Prometheus** - Time-series metrics collection from both Proxmox nodes
- **Loki & Promtail** - Log aggregation system for centralized logging
- **AlertManager** - Alert routing and management

### **Workflow Automation** (1 service)
- **n8n** - Visual workflow automation engine for service integration

### **Dedicated Wazuh Manager VM**
- **Wazuh Manager** - SIEM/IDS platform (4GB RAM dedicated VM)
- **Wazuh Indexer** - Log storage and analysis (Elasticsearch replacement)
- **Wazuh Dashboard** - Security monitoring web interface

---

## ⛵ Node #1 (ThousandSunny) - Proxmox Applications & Storage Hub

**Infrastructure**: Dell XPS 8500, i7-3770, 12GB DDR3, 1TB SSD + 9TB HDD, Proxmox VE 8.x
**Services**: 36 containers in Ubuntu LXC (optimized resource allocation)

### **Core Infrastructure & Development** (15 services)
- **Gitea** - Self-hosted Git server with Actions CI/CD pipeline
- **Gitea Actions Runner** - Continuous integration and deployment automation
- ~~**Duplicati**~~ → **Proxmox Backup Server** - Native VM/LXC backup solution
- **Nextcloud AIO** - Private cloud storage and collaboration platform

### **Database Infrastructure** (4 services)
- **PostgreSQL** - Primary relational database for applications
- **Redis** - High-performance caching and session storage
- **pgAdmin** - Web-based PostgreSQL administration interface
- **Redis Commander** - Web-based Redis management interface

### **DevOps & Code Quality** (5 services)
- **Docker Registry** - Private container image repository
- **Registry UI** - Web interface for Docker registry management
- **SonarQube** - Code quality analysis and security scanning
- **SonarQube Scanner** - CLI tool for automated code analysis
- **Nexus Repository** - Advanced artifact and dependency management

### **Media Services** (9 services) *(Mutual Exclusivity)*
- **Plex** - Primary media server with hardware transcoding *(Active)*
- **Jellyfin** - Backup media server *(Standby - only runs when Plex fails)*
- **Immich** - Self-hosted photo and video management (Google Photos alternative)
- **Kavita** - Digital library and reader for e-books and comics

### **Media Automation (*arr Suite)** (5 services)
- **Prowlarr** - Manages indexers for Sonarr and Radarr integration
- **Sonarr** - Automates TV show acquisition, organization, and monitoring
- **Radarr** - Automates movie acquisition, organization, and monitoring
- **Bazarr** - Manages and downloads subtitles for Sonarr and Radarr content
- **Overseerr** - User-friendly request management system for Plex/Jellyfin

### **Download Management** (3 services)
- **qBittorrent** - Feature-rich BitTorrent client with web interface
- **Deluge** - Lightweight BitTorrent client for specialized downloading
- **Download Helper** - Additional download management utilities

### **AI & Machine Learning** (2 services) *(Resource-permitting)*
- **Ollama** - Local Large Language Model (LLM) runtime for AI experimentation
- **Ollama WebUI** - Web interface for interacting with local AI models

### **IoT & Home Automation** (7 services)
- **Home Assistant** - Comprehensive smart home automation hub
- **MQTT Broker (Mosquitto)** - IoT message broker for device communication
- **InfluxDB** - Time-series database for IoT metrics and sensor data
- **Zigbee2MQTT** - Zigbee device integration and management
- **Node-RED** - Visual flow programming for IoT automation
- **ESPHome** - ESP device firmware management and configuration
- **IoT Grafana** - Specialized dashboards for IoT and smart home data

### **Security & Remote Monitoring** (1 service) *(Optimized)*
- ~~**Portainer Agent**~~ → **Proxmox Native Management** - LXC managed via Proxmox web UI
- **Wazuh Agent** - Security monitoring agent for SIEM integration

---

## Dual Proxmox Docker Compose File Mapping

The Docker Compose files are organized by Proxmox node and category for modular LXC deployment. Services eliminated for Proxmox optimization are noted.

### Node #2 (GoingMerry) - Proxmox LXC Services

| Category | File Path | Services | Count |
|----------|-----------|----------|-------|
| **Networking** | `goingmerry/networking/docker-compose-nginx.yml` | Nginx Proxy, Cloudflare, Traefik | 3 |
| ~~**Management**~~ | ~~`goingmerry/management/`~~ | ~~Portainer~~ → **Proxmox Web UI** | ~~2~~ → **0** |
| **Security** | `goingmerry/security/docker-compose-security.yml` | Authentik, CrowdSec, Suricata, Vaultwarden, Wazuh Agent | 5 |
| **Monitoring** | `goingmerry/monitoring/docker-compose-monitoring.yml` | Prometheus, Grafana, Loki, Promtail *(Uptime Kuma, Watchtower eliminated)* | 4 |
| **Automation** | `goingmerry/automation/docker-compose-automation.yml` | n8n | 1 |
| **Communication** | `goingmerry/communication/docker-compose-matrix.yml` | Matrix Synapse, Element Web, Matrix Admin | 4* |

**Total Node #2**: 13 services *(optimized from 17)*

### Node #1 (ThousandSunny) - Proxmox LXC Services

| Category | File Path | Services | Count |
|----------|-----------|----------|-------|
| **Infrastructure** | `thousandsunny/infra/docker-compose-gitea.yml` | Gitea, Gitea Actions, Nextcloud AIO *(Duplicati eliminated)* | 3 |
| **Database** | `thousandsunny/infra/docker-compose-database.yml` | PostgreSQL, Redis, pgAdmin, Redis Commander | 4 |
| **DevOps** | `thousandsunny/infra/docker-compose-devops.yml` | Docker Registry, Registry UI, SonarQube, Nexus | 4 |
| **Media** | `thousandsunny/media/docker-compose-media.yml` | Plex OR Jellyfin, Immich, Kavita, ARR Suite, Overseerr | 9 |
| **Torrent** | `thousandsunny/torrent/docker-compose-torrent.yml` | qBittorrent, Deluge | 2 |
| **AI** | `thousandsunny/ai/docker-compose-ai.yml` | Ollama, Ollama WebUI | 2 |
| **IoT** | `thousandsunny/iot/docker-compose-homeautomation.yml` | Home Assistant, MQTT, InfluxDB, Zigbee2MQTT, Node-RED, ESPHome, IoT Grafana | 7 |
| **Agents** | `thousandsunny/agents/docker-compose-wazuh-agent.yml` | Wazuh Agent *(Portainer Agent eliminated)* | 1 |

**Total Node #1**: 36 services *(optimized from 38)*

### **Dedicated Infrastructure Services**
- **Wazuh Manager VM** (Node #1): Dedicated 4GB RAM VM for SIEM/IDS
- **Proxmox Native Services**: Backup, monitoring, container management

### Usage

To deploy a specific category of services:
```bash
# Example: Deploy communication stack on Node #2
cd goingmerry/communication
docker-compose up -d

# Example: Deploy IoT automation on Node #1
cd thousandsunny/iot
docker-compose up -d

# Example: Deploy database infrastructure on Node #1
cd thousandsunny/infra
docker-compose -f docker-compose-database.yml up -d

# Example: Deploy DevOps tools on Node #1
cd thousandsunny/infra
docker-compose -f docker-compose-devops.yml up -d
```

Each compose file contains production-ready configurations that can be customized with proper environment variables, volumes, and network settings.

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
