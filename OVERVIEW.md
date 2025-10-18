# SunnyLabX - Home Lab Infrastructure Overview

## 🏗️ Architecture Summary

SunnyLabX is a comprehensive self-hosted home lab infrastructure built on a dual-node architecture. The lab provides enterprise-grade services for networking, security, monitoring, media management, development, and AI experimentation through containerized services managed with Docker Compose.

## 🌐 Network Architecture

```
                     ┌─────────────────┐
                     │   Internet      │
                     └─────────┬───────┘
                               │
                     ┌─────────▼───────┐
                     │ Cloudflare Edge │
                     │    Network      │
                     └─────────┬───────┘
                               │
                     ┌─────────▼───────┐
                     │ Cloudflare      │
                     │   Tunnel        │
                     │ (Secure Access) │
                     └─────────┬───────┘
                               │
                     ┌─────────▼───────┐
                     │  Nginx Proxy    │
                     │   Manager       │
                     │ (Internal Route)│
                     └─────────┬───────┘
                               │
                ┌──────────────┼──────────────┐
                │              │              │
        ┌───────▼──────┐      │      ┌───────▼──────┐
        │   Node #2    │      │      │   Node #1    │
        │ (goingmerry) │      │      │(thousandsunny)│
        │              │      │      │              │
        │ ┌──────────┐ │      │      │ ┌──────────┐ │
        │ │Management│ │      │      │ │ Media    │ │
        │ │Security  │ │      │      │ │ Storage  │ │
        │ │Monitor   │ │      │      │ │ AI/ML    │ │
        │ │Network   │ │      │      │ │ Dev      │ │
        │ │Automation│ │      │      │ │ Agents   │ │
        │ └──────────┘ │      │      │ └──────────┘ │
        └──────────────┘      │      └──────────────┘
                               │
                     ┌─────────▼───────┐
                     │ Portainer Mgmt  │
                     │  (Centralized)  │
                     └─────────────────┘
```

## 🏢 Node Distribution

### Node #2: goingmerry (Management & Control)
**Role**: Central management, security, monitoring, network services, and communication
**Services**: 28 containers across 6 categories

### Node #1: thousandsunny (Applications & Content)
**Role**: Media services, storage, development, AI workloads, and IoT automation
**Services**: 25 containers across 7 categories

## 📁 Repository Structure

```
sunnylabx/
├── 📄 README.md                    # Service descriptions & usage
├── 📄 GIT-FLOW.md                  # Development workflow guide
├── 📄 OVERVIEW.md                  # This architecture overview
├── 📄 COPILOT_INSTRUCTIONS.md      # AI assistant guidelines
│
├── 🏗️ ansible/                     # Infrastructure automation
│   ├── hosts.ini                   # Inventory configuration
│   └── playbook.yml                # Deployment automation
│
├── 🚢 goingmerry/                  # Node #2 (Management)
│   ├── networking/                 # 🌐 Network Services
│   │   └── docker-compose-nginx.yml
│   ├── management/                 # 🎛️ Cluster Management
│   │   └── docker-compose-portainer.yml
│   ├── security/                   # 🔒 Security Stack
│   │   └── docker-compose-security.yml
│   ├── monitoring/                 # 📊 Observability
│   │   └── docker-compose-monitoring.yml
│   ├── automation/                 # 🤖 Workflow Automation
│   │   └── docker-compose-automation.yml
│   └── communication/              # 💬 Communication & Collaboration
│       └── docker-compose-matrix.yml
│
└── ⛵ thousandsunny/               # Node #1 (Applications)
    ├── infra/                      # 🏗️ Core Infrastructure
    │   ├── docker-compose-gitea.yml
    │   ├── docker-compose-database.yml
    │   └── docker-compose-devops.yml
    ├── media/                      # 🎬 Media Services
    │   └── docker-compose-media.yml
    ├── torrent/                    # 📥 Download Clients
    │   └── docker-compose-torrent.yml
    ├── ai/                         # 🧠 AI & Machine Learning
    │   └── docker-compose-ai.yml
    ├── iot/                        # 🏠 IoT & Home Automation
    │   └── docker-compose-homeautomation.yml
    └── agents/                     # 🤖 Remote Agents
        ├── docker-compose-portainer-agent.yml
        └── docker-compose-wazuh-agent.yml
```

## 🏢 Detailed Service Breakdown

### Node #2 (goingmerry) - Central Management Hub

#### 🌐 Networking Stack
- **Cloudflare Tunnel**: Secure external access without port forwarding or public IP exposure
- **Nginx Proxy Manager**: Internal reverse proxy and SSL certificate management
- **Portainer Controller Proxy**: Networking assistance for container management

#### 🎛️ Management Stack
- **Portainer Controller**: Centralized Docker container management interface
- **Portainer Helper**: Supporting services for container orchestration

#### 🔒 Security & Identity Stack
- **Authentik**: Enterprise SSO and identity provider
- **Wazuh**: Security Information and Event Management (SIEM)
- **CrowdSec**: Collaborative intrusion prevention system
- **Suricata**: Network intrusion detection system
- **Vaultwarden**: Self-hosted password manager (Bitwarden compatible)

#### 📊 Monitoring & Observability Stack
- **Prometheus**: Time-series metrics collection and storage
- **Grafana**: Advanced dashboards and data visualization
- **Loki**: Log aggregation and analysis
- **Promtail**: Log shipping agent
- **Uptime Kuma**: Service availability monitoring
- **Watchtower**: Automated container updates

#### 🤖 Automation Stack
- **n8n**: Visual workflow automation and integration platform

#### 💬 Communication & Collaboration Stack
- **Matrix Synapse**: Federated messaging server with end-to-end encryption
- **Element Web**: Modern Matrix web client for secure communication
- **Matrix Admin**: Administration interface for user and room management
- **Sliding Sync**: Enhanced Matrix synchronization for better performance

### Node #1 (thousandsunny) - Application & Content Hub

#### 🏗️ Infrastructure & Development Stack
- **Gitea**: Self-hosted Git repository management with Actions CI/CD
- **Gitea Actions Runner**: Continuous integration and deployment pipeline
- **Duplicati**: Automated backup solution for critical data
- **Nextcloud AIO**: Private cloud storage and collaboration platform
- **PostgreSQL**: Primary relational database for applications
- **Redis**: High-performance caching and session storage
- **pgAdmin**: Web-based PostgreSQL administration interface
- **Redis Commander**: Web-based Redis management interface

#### 🛠️ DevOps & Code Quality Stack
- **Docker Registry**: Private container image repository
- **Registry UI**: Web interface for Docker registry management
- **SonarQube**: Code quality analysis and security scanning
- **SonarQube Scanner**: CLI tool for automated code analysis
- **Nexus Repository**: Advanced artifact and dependency management

#### 🎬 Media & Entertainment Stack
- **Plex**: Premium media server with advanced features
- **Jellyfin**: Open-source media server alternative
- **Immich**: Self-hosted photo and video management (Google Photos alternative)
- **Kavita**: Digital library for e-books and comics
- **Prowlarr**: Indexer management for media automation
- **Sonarr**: TV show acquisition and organization
- **Radarr**: Movie acquisition and organization
- **Bazarr**: Subtitle management for media content
- **Overseerr**: User-friendly media request management

#### 📥 Download Management Stack
- **qBittorrent**: Feature-rich BitTorrent client with web interface
- **Deluge**: Lightweight BitTorrent client
- **Download Helper**: Additional download management utilities

#### 🧠 AI & Machine Learning Stack
- **Ollama**: Local large language model runtime
- **Ollama WebUI**: Web interface for interacting with AI models

#### 🏠 IoT & Home Automation Stack
- **Home Assistant**: Comprehensive smart home automation hub
- **MQTT Broker (Mosquitto)**: IoT message broker for device communication
- **InfluxDB**: Time-series database for IoT metrics and sensor data
- **Zigbee2MQTT**: Zigbee device integration and management
- **Node-RED**: Visual flow programming for IoT automation
- **ESPHome**: ESP device firmware management and configuration
- **IoT Grafana**: Specialized dashboards for IoT and smart home data

#### 🤖 Agent Stack
- **Portainer Agent**: Remote management agent for Node #1
- **Wazuh Agent**: Security monitoring agent

## 🔄 Service Interconnections

```
┌─────────────────── Networking Flow ───────────────────┐
│                                                        │
│  Internet → Cloudflare Edge → Cloudflare Tunnel →     │
│  Nginx Proxy → Internal Services                      │
│                                                        │
└────────────────────────────────────────────────────────┘

┌─────────────────── Management Flow ───────────────────┐
│                                                        │
│  Portainer Controller ← → Portainer Agent             │
│  (Node #2)                (Node #1)                   │
│                                                        │
└────────────────────────────────────────────────────────┘

┌─────────────────── Security Flow ──────────────────────┐
│                                                        │
│  Authentik (SSO) → All Services                       │
│  Wazuh Manager ← → Wazuh Agent                        │
│  CrowdSec ← → Suricata → Network Traffic              │
│                                                        │
└────────────────────────────────────────────────────────┘

┌─────────────────── Monitoring Flow ────────────────────┐
│                                                        │
│  Promtail → Loki → Grafana                           │
│  All Services → Prometheus → Grafana                  │
│  Uptime Kuma → Service Health Checks                  │
│                                                        │
└────────────────────────────────────────────────────────┘

┌─────────────────── Media Automation Flow ─────────────┐
│                                                        │
│  Overseerr → Sonarr/Radarr → Prowlarr → qBittorrent  │
│  Bazarr → Sonarr/Radarr → Plex/Jellyfin              │
│                                                        │
└────────────────────────────────────────────────────────┘
```

## 🚀 Deployment Architecture

### Container Distribution
- **Total Services**: 38 containerized applications
- **Node #2 (goingmerry)**: 23 containers
- **Node #1 (thousandsunny)**: 15 containers

### Category-Based Deployment
Each category can be deployed independently using:
```bash
# Deploy networking stack on Node #2
cd goingmerry/networking && docker-compose up -d

# Deploy media stack on Node #1  
cd thousandsunny/media && docker-compose up -d
```

### Infrastructure as Code
- **Docker Compose**: Service definitions and container orchestration
- **Ansible**: Node provisioning and configuration management
- **Git**: Version control and deployment pipeline

### Deployment Architecture
- **Ansible Automation**: Two-stage deployment (base system + Docker)
- **SSH Security**: OpenSSH protection during firewall configuration
- **Modular Structure**: Category-based service deployment
- **Tag-based Control**: Selective deployment and maintenance

### Container Distribution
- **Total Services**: 53 containerized applications
- **Node #2 (goingmerry)**: 28 containers
- **Node #1 (thousandsunny)**: 25 containers

### Category-Based Deployment
Each category can be deployed independently using:
```bash
# Deploy communication stack on Node #2
cd goingmerry/communication && docker-compose up -d

# Deploy IoT stack on Node #1  
cd thousandsunny/iot && docker-compose up -d

# Deploy database infrastructure on Node #1
cd thousandsunny/infra && docker-compose -f docker-compose-database.yml up -d
```

### Infrastructure as Code
- **Docker Compose**: Service definitions and container orchestration
- **Ansible**: Node provisioning and configuration management
- **Git**: Version control and deployment pipeline

### Deployment Architecture
- **Ansible Automation**: Two-stage deployment (base system + Docker)
- **SSH Security**: OpenSSH protection during firewall configuration
- **Modular Structure**: Category-based service deployment
- **Tag-based Control**: Selective deployment and maintenance

## 🔧 Management & Operations

### Infrastructure as Code
- **Ansible**: Automated node provisioning, package installation, and configuration management
- **Docker Compose**: Service definitions and container orchestration  
- **Git**: Version control and deployment pipeline

### Centralized Management
- **Portainer**: Visual container management across both nodes
- **Grafana**: Unified monitoring dashboards
- **Authentik**: Single sign-on for all services
- **Nginx Proxy Manager**: Centralized reverse proxy and SSL

### Automated Operations
- **Watchtower**: Automatic container updates
- **n8n**: Custom workflow automation
- **Duplicati**: Scheduled data backups
- **Uptime Kuma**: Service health monitoring

### Security Posture
- **Defense in Depth**: Multiple security layers (Nginx → Authentik → CrowdSec)
- **SIEM Integration**: Wazuh for security event correlation
- **Network Monitoring**: Suricata for intrusion detection
- **Credential Management**: Vaultwarden for secure password storage

## 📈 Scalability & Future Expansion

### Horizontal Scaling
- **Node Addition**: Easy to add new nodes with Portainer agents
- **Service Distribution**: Category-based deployment enables selective scaling
- **Load Balancing**: Nginx Proxy Manager supports multiple backends

### Vertical Scaling
- **Resource Allocation**: Docker Compose resource limits and reservations
- **Storage Expansion**: Volume mounting for data persistence
- **Performance Monitoring**: Prometheus metrics for capacity planning

## 🏷️ Service Categories Summary

| Category | Node | Services Count | Primary Function |
|----------|------|----------------|------------------|
| **Networking** | goingmerry | 4 | External access, routing, DNS, SSL |
| **Management** | goingmerry | 2 | Container orchestration |
| **Security** | goingmerry | 5 | Identity, SIEM, IDS/IPS |
| **Monitoring** | goingmerry | 6 | Metrics, logs, alerting |
| **Automation** | goingmerry | 1 | Workflow orchestration |
| **Communication** | goingmerry | 6 | Encrypted messaging, collaboration |
| **Infrastructure** | thousandsunny | 11 | Development, databases, CI/CD |
| **DevOps** | thousandsunny | 5 | Code quality, registries, artifacts |
| **Media** | thousandsunny | 9 | Streaming, automation |
| **Torrent** | thousandsunny | 3 | Download management |
| **AI** | thousandsunny | 2 | Machine learning |
| **IoT** | thousandsunny | 7 | Smart home, automation, sensors |
| **Agents** | thousandsunny | 2 | Remote management |

---

## 📋 Quick Reference

### Repository Branches
- **main**: Active development branch
- **base**: Stable fallback branch for fresh starts

### Key Configuration Files
- `README.md`: Service descriptions and usage examples
- `GIT-FLOW.md`: Development workflow and contribution guidelines  
- `ansible/`: Infrastructure automation and provisioning
- `*/docker-compose-*.yml`: Service definitions by category

### Management URLs (when deployed)
- Portainer: `https://portainer.lab.local`
- Grafana: `https://grafana.lab.local`  
- Nginx Proxy Manager: `https://npm.lab.local`
- Authentik: `https://auth.lab.local`
- Matrix Chat: `https://chat.lab.local`
- Home Assistant: `https://home.lab.local`
- Gitea: `https://git.lab.local`
- SonarQube: `https://sonar.lab.local`
- Docker Registry UI: `https://registry-ui.lab.local`

*This overview represents the current architecture as of the latest commit. For implementation details and deployment instructions, refer to the individual README files in each service category.*