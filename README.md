# sunnylabx
# Service Layout:

**Network & Management - Node #2**

- Nginx Proxy Manager - Primary reverse proxy. Manages all incoming traffic and SSL certificates.
- AdGuard Home - Network-wide ad blocking and local DNS resolution.
- Portainer (Controller) - Central Web UI for the entire docker cluster.

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
| **Networking** | `goingmerry/networking/docker-compose-nginx.yml` | Nginx Proxy Manager, AdGuard Home |
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
