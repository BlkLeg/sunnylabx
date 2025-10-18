# SunnyLabX Home Lab Infrastructure

A comprehensive self-hosted home lab infrastructure built on a dual-node architecture with 53 containerized services providing enterprise-grade networking, security, monitoring, media management, development tools, IoT automation, and communication platforms.

## 🏗️ Architecture Overview

**Total Services**: 53 containers across 12 categories
- **Node #2 (goingmerry)**: 28 containers - Management & Control Hub
- **Node #1 (thousandsunny)**: 25 containers - Applications & Content Hub

## 🚢 Node #2 (goingmerry) - Management & Control Hub

### **Network & External Access**
- **Nginx Proxy Manager** - Primary reverse proxy with SSL certificate management
- **Cloudflare Tunnel** - Secure external access without port forwarding or public IP exposure
- **Portainer Controller Proxy** - Networking assistance for container management

### **Centralized Management**
- **Portainer Controller** - Central web UI for the entire Docker cluster management
- **Portainer Helper** - Supporting services for container orchestration

### **Security & Identity**
- **Authentik** - Enterprise SSO and identity provider for all services
- **Wazuh** - Security Information and Event Management (SIEM) system
- **CrowdSec** - Collaborative Intrusion Prevention System (IPS)
- **Suricata** - Network Intrusion Detection System (IDS)
- **Vaultwarden** - Self-hosted password manager (Bitwarden compatible)

### **Monitoring & Observability**
- **Grafana** - Primary dashboard for visualizing all homelab metrics and logs
- **Prometheus** - Time-series metrics collection from all nodes and services
- **Loki & Promtail** - Log aggregation system for centralized logging
- **Uptime Kuma** - Service uptime and status monitoring
- **Watchtower** - Automated Docker container updates

### **Workflow Automation**
- **n8n** - Visual workflow automation engine for service integration

### **Communication & Collaboration**
- **Matrix Synapse** - Federated messaging server with end-to-end encryption
- **Element Web** - Modern Matrix web client for secure communication
- **Matrix Admin** - Administration interface for user and room management
- **Sliding Sync** - Enhanced Matrix synchronization for better performance

---

## ⛵ Node #1 (thousandsunny) - Applications & Content Hub

### **Core Infrastructure & Development**
- **Gitea** - Self-hosted Git server with Actions CI/CD pipeline
- **Gitea Actions Runner** - Continuous integration and deployment automation
- **Duplicati** - Automated backup solution for critical data
- **Nextcloud AIO** - Private cloud storage and collaboration platform

### **Database Infrastructure**
- **PostgreSQL** - Primary relational database for applications
- **Redis** - High-performance caching and session storage
- **pgAdmin** - Web-based PostgreSQL administration interface
- **Redis Commander** - Web-based Redis management interface

### **DevOps & Code Quality**
- **Docker Registry** - Private container image repository
- **Registry UI** - Web interface for Docker registry management
- **SonarQube** - Code quality analysis and security scanning
- **SonarQube Scanner** - CLI tool for automated code analysis
- **Nexus Repository** - Advanced artifact and dependency management

### **Media Services**
- **Plex** - Premium media server with advanced features and transcoding
- **Jellyfin** - Open-source media server alternative with no licensing restrictions
- **Immich** - Self-hosted photo and video management (Google Photos alternative)
- **Kavita** - Digital library and reader for e-books and comics

### **Media Automation (*arr Suite)**
- **Prowlarr** - Manages indexers for Sonarr and Radarr integration
- **Sonarr** - Automates TV show acquisition, organization, and monitoring
- **Radarr** - Automates movie acquisition, organization, and monitoring
- **Bazarr** - Manages and downloads subtitles for Sonarr and Radarr content
- **Overseerr** - User-friendly request management system for Plex/Jellyfin

### **Download Management**
- **qBittorrent** - Feature-rich BitTorrent client with web interface
- **Deluge** - Lightweight BitTorrent client for specialized downloading
- **Download Helper** - Additional download management utilities

### **AI & Machine Learning**
- **Ollama** - Local Large Language Model (LLM) runtime for AI experimentation
- **Ollama WebUI** - Web interface for interacting with local AI models

### **IoT & Home Automation**
- **Home Assistant** - Comprehensive smart home automation hub
- **MQTT Broker (Mosquitto)** - IoT message broker for device communication
- **InfluxDB** - Time-series database for IoT metrics and sensor data
- **Zigbee2MQTT** - Zigbee device integration and management
- **Node-RED** - Visual flow programming for IoT automation
- **ESPHome** - ESP device firmware management and configuration
- **IoT Grafana** - Specialized dashboards for IoT and smart home data

### **Remote Management Agents**
- **Portainer Agent** - Remote management agent for Node #1 connectivity
- **Wazuh Agent** - Security monitoring agent for SIEM integration

---

## Docker Compose File Mapping

The Docker Compose files are organized by node and category to enable modular deployment and service management. Each compose file sits within a parent folder reflecting its category for clarity.

### Node #2 (goingmerry)

| Category | File Path | Services |
|----------|-----------|----------|
| **Networking** | `goingmerry/networking/docker-compose-nginx.yml` | Nginx Proxy Manager, Cloudflare Tunnel |
| **Management** | `goingmerry/management/docker-compose-portainer.yml` | Portainer Controller |
| **Security** | `goingmerry/security/docker-compose-security.yml` | Authentik, Wazuh, CrowdSec, Suricata, Vaultwarden |
| **Monitoring** | `goingmerry/monitoring/docker-compose-monitoring.yml` | Prometheus, Grafana, Loki, Promtail, Uptime Kuma, Watchtower |
| **Automation** | `goingmerry/automation/docker-compose-automation.yml` | n8n |
| **Communication** | `goingmerry/communication/docker-compose-matrix.yml` | Matrix Synapse, Element Web, Matrix Admin |

### Node #1 (thousandsunny)

| Category | File Path | Services |
|----------|-----------|----------|
| **Infrastructure** | `thousandsunny/infra/docker-compose-gitea.yml` | Gitea, Gitea Actions, Duplicati, Nextcloud AIO |
| **Database** | `thousandsunny/infra/docker-compose-database.yml` | PostgreSQL, Redis, pgAdmin, Redis Commander |
| **DevOps** | `thousandsunny/infra/docker-compose-devops.yml` | Docker Registry, Registry UI, SonarQube, Nexus |
| **Media** | `thousandsunny/media/docker-compose-media.yml` | Plex, Jellyfin, Immich, Kavita, ARR Suite, Overseerr |
| **Torrent** | `thousandsunny/torrent/docker-compose-torrent.yml` | qBittorrent, Deluge |
| **AI** | `thousandsunny/ai/docker-compose-ai.yml` | Ollama, Ollama WebUI |
| **IoT** | `thousandsunny/iot/docker-compose-homeautomation.yml` | Home Assistant, MQTT, InfluxDB, Zigbee2MQTT, Node-RED |
| **Agents** | `thousandsunny/agents/docker-compose-portainer-agent.yml` | Portainer Agent, Wazuh Agent |

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
