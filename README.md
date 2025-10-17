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

n8n - Workflow automation engine to connect services and create automated tasks.

---

**Core Infrastructure - Node #1**

- Portainer - Connects this node to the main Portainer controller for remote management.

**Storage & Development - Node #1**

- Gitea - Self-hosted Git server for all homelab configuration files and personal code.
- Duplicati - Manages scheduled backups of all critical homelab data to various storage backends.

**Cloud & Productivity - Node #1**

Nextcloud AIO - Private cloud for file storage, calendar, contacts, and photos.

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
