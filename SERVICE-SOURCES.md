# SunnyLabX Service Configuration Sources

This document provides official GitHub repositories and websites where you can find production-ready Docker Compose configurations for each service in the SunnyLabX home lab infrastructure.

## 📖 How to Use This Guide

Each service entry includes:
- **Official Repository**: Primary source for Docker images and documentation
- **Docker Compose Examples**: Direct links to compose file examples
- **Documentation**: Installation and configuration guides
- **Community Resources**: Popular community configurations when applicable

---

## 🌐 Node #2 (goingmerry) - Management & Control Hub

### Networking Services

#### Cloudflare Tunnel (cloudflared)
- **Official Repository**: https://github.com/cloudflare/cloudflared
- **Docker Compose**: https://github.com/cloudflare/cloudflared/blob/master/docker/docker-compose.yml
- **Documentation**: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/
- **Docker Hub**: https://hub.docker.com/r/cloudflare/cloudflared

#### Nginx Proxy Manager
- **Official Repository**: https://github.com/NginxProxyManager/nginx-proxy-manager
- **Docker Compose**: https://github.com/NginxProxyManager/nginx-proxy-manager/blob/develop/docker-compose.yml
- **Documentation**: https://nginxproxymanager.com/setup/#running-the-app
- **Docker Hub**: https://hub.docker.com/r/jc21/nginx-proxy-manager

#### AdGuard Home
- **Official Repository**: https://github.com/AdguardTeam/AdGuardHome
- **Docker Compose**: https://github.com/AdguardTeam/AdGuardHome/wiki/Docker
- **Documentation**: https://github.com/AdguardTeam/AdGuardHome/wiki
- **Docker Hub**: https://hub.docker.com/r/adguard/adguardhome

### Management Services

#### Portainer
- **Official Repository**: https://github.com/portainer/portainer
- **Docker Compose**: https://docs.portainer.io/start/install-ce/server/docker/linux
- **Documentation**: https://docs.portainer.io/
- **Docker Hub**: https://hub.docker.com/r/portainer/portainer-ce

### Security & Identity Services

#### Authentik
- **Official Repository**: https://github.com/goauthentik/authentik
- **Docker Compose**: https://github.com/goauthentik/authentik/blob/main/docker-compose.yml
- **Documentation**: https://docs.goauthentik.io/docs/installation/docker-compose
- **Docker Hub**: https://hub.docker.com/r/ghcr.io/goauthentik/server

#### Wazuh
- **Official Repository**: https://github.com/wazuh/wazuh
- **Docker Compose**: https://github.com/wazuh/wazuh-docker
- **Documentation**: https://documentation.wazuh.com/current/deployment-options/docker/index.html
- **Docker Hub**: https://hub.docker.com/u/wazuh

#### CrowdSec
- **Official Repository**: https://github.com/crowdsecurity/crowdsec
- **Docker Compose**: https://github.com/crowdsecurity/example-docker-compose
- **Documentation**: https://docs.crowdsec.net/docs/getting_started/install_crowdsec_docker
- **Docker Hub**: https://hub.docker.com/r/crowdsecurity/crowdsec

#### Suricata
- **Official Repository**: https://github.com/OISF/suricata
- **Docker Compose**: https://github.com/jasonish/docker-suricata
- **Documentation**: https://suricata.readthedocs.io/en/suricata-6.0.0/quickstart.html
- **Docker Hub**: https://hub.docker.com/r/jasonish/suricata

#### Vaultwarden
- **Official Repository**: https://github.com/dani-garcia/vaultwarden
- **Docker Compose**: https://github.com/dani-garcia/vaultwarden/wiki/Using-Docker-Compose
- **Documentation**: https://github.com/dani-garcia/vaultwarden/wiki
- **Docker Hub**: https://hub.docker.com/r/vaultwarden/server

### Monitoring & Observability Services

#### Prometheus
- **Official Repository**: https://github.com/prometheus/prometheus
- **Docker Compose**: https://github.com/prometheus/prometheus/blob/main/documentation/examples/docker-compose.yml
- **Documentation**: https://prometheus.io/docs/prometheus/latest/installation/
- **Docker Hub**: https://hub.docker.com/r/prom/prometheus

#### Grafana
- **Official Repository**: https://github.com/grafana/grafana
- **Docker Compose**: https://github.com/grafana/grafana/tree/main/devenv/docker/compose_folder
- **Documentation**: https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/
- **Docker Hub**: https://hub.docker.com/r/grafana/grafana

#### Loki
- **Official Repository**: https://github.com/grafana/loki
- **Docker Compose**: https://github.com/grafana/loki/tree/main/production/docker-compose
- **Documentation**: https://grafana.com/docs/loki/latest/installation/docker/
- **Docker Hub**: https://hub.docker.com/r/grafana/loki

#### Promtail
- **Official Repository**: https://github.com/grafana/loki (part of Loki)
- **Docker Compose**: https://github.com/grafana/loki/blob/main/clients/cmd/promtail/Dockerfile
- **Documentation**: https://grafana.com/docs/loki/latest/clients/promtail/installation/
- **Docker Hub**: https://hub.docker.com/r/grafana/promtail

#### Uptime Kuma
- **Official Repository**: https://github.com/louislam/uptime-kuma
- **Docker Compose**: https://github.com/louislam/uptime-kuma/blob/master/docker/docker-compose.yml
- **Documentation**: https://github.com/louislam/uptime-kuma/wiki
- **Docker Hub**: https://hub.docker.com/r/louislam/uptime-kuma

#### Watchtower
- **Official Repository**: https://github.com/containrrr/watchtower
- **Docker Compose**: https://github.com/containrrr/watchtower#docker-compose
- **Documentation**: https://containrrr.dev/watchtower/
- **Docker Hub**: https://hub.docker.com/r/containrrr/watchtower

### Automation Services

#### n8n
- **Official Repository**: https://github.com/n8n-io/n8n
- **Docker Compose**: https://github.com/n8n-io/n8n/tree/master/docker/compose
- **Documentation**: https://docs.n8n.io/hosting/installation/docker/
- **Docker Hub**: https://hub.docker.com/r/n8nio/n8n

---

## ⛵ Node #1 (thousandsunny) - Application & Content Hub

### Infrastructure & Development Services

#### Gitea
- **Official Repository**: https://github.com/go-gitea/gitea
- **Docker Compose**: https://github.com/go-gitea/gitea/tree/main/contrib/docker
- **Documentation**: https://docs.gitea.io/en-us/install-with-docker/
- **Docker Hub**: https://hub.docker.com/r/gitea/gitea

#### Duplicati
- **Official Repository**: https://github.com/duplicati/duplicati
- **Docker Compose**: https://github.com/duplicati/duplicati/wiki/Docker
- **Documentation**: https://duplicati.readthedocs.io/en/latest/
- **Docker Hub**: https://hub.docker.com/r/linuxserver/duplicati

#### Nextcloud AIO
- **Official Repository**: https://github.com/nextcloud/all-in-one
- **Docker Compose**: https://github.com/nextcloud/all-in-one#how-to-use-this
- **Documentation**: https://github.com/nextcloud/all-in-one/blob/main/readme.md
- **Docker Hub**: https://hub.docker.com/r/nextcloud/all-in-one

### Media & Entertainment Services

#### Plex
- **Official Repository**: https://github.com/plexinc/pms-docker
- **Docker Compose**: https://github.com/plexinc/pms-docker#docker-compose
- **Documentation**: https://support.plex.tv/articles/201543147-what-network-ports-do-i-need-to-allow-through-my-firewall/
- **Docker Hub**: https://hub.docker.com/r/plexinc/pms-docker

#### Jellyfin
- **Official Repository**: https://github.com/jellyfin/jellyfin
- **Docker Compose**: https://jellyfin.org/docs/general/administration/installing.html#docker-compose
- **Documentation**: https://jellyfin.org/docs/
- **Docker Hub**: https://hub.docker.com/r/jellyfin/jellyfin

#### Immich
- **Official Repository**: https://github.com/immich-app/immich
- **Docker Compose**: https://github.com/immich-app/immich/blob/main/docker/docker-compose.yml
- **Documentation**: https://immich.app/docs/install/docker-compose
- **Docker Hub**: https://hub.docker.com/r/ghcr.io/immich-app/immich-server

#### Kavita
- **Official Repository**: https://github.com/Kareadita/Kavita
- **Docker Compose**: https://wiki.kavitareader.com/installation/docker-install
- **Documentation**: https://wiki.kavitareader.com/
- **Docker Hub**: https://hub.docker.com/r/kizaing/kavita

#### Prowlarr
- **Official Repository**: https://github.com/Prowlarr/Prowlarr
- **Docker Compose**: https://github.com/Prowlarr/Prowlarr/wiki/Docker-Guide
- **Documentation**: https://wiki.servarr.com/prowlarr
- **Docker Hub**: https://hub.docker.com/r/linuxserver/prowlarr

#### Sonarr
- **Official Repository**: https://github.com/Sonarr/Sonarr
- **Docker Compose**: https://github.com/Sonarr/Sonarr/wiki/Docker-Guide
- **Documentation**: https://wiki.servarr.com/sonarr
- **Docker Hub**: https://hub.docker.com/r/linuxserver/sonarr

#### Radarr
- **Official Repository**: https://github.com/Radarr/Radarr
- **Docker Compose**: https://github.com/Radarr/Radarr/wiki/Docker-Guide
- **Documentation**: https://wiki.servarr.com/radarr
- **Docker Hub**: https://hub.docker.com/r/linuxserver/radarr

#### Bazarr
- **Official Repository**: https://github.com/morpheus65535/bazarr
- **Docker Compose**: https://github.com/morpheus65535/bazarr/wiki/Docker
- **Documentation**: https://wiki.bazarr.media/
- **Docker Hub**: https://hub.docker.com/r/linuxserver/bazarr

#### Overseerr
- **Official Repository**: https://github.com/sct/overseerr
- **Docker Compose**: https://docs.overseerr.dev/getting-started/installation#docker-compose
- **Documentation**: https://docs.overseerr.dev/
- **Docker Hub**: https://hub.docker.com/r/sctx/overseerr

### Download Management Services

#### qBittorrent
- **Official Repository**: https://github.com/qbittorrent/qBittorrent
- **Docker Compose**: https://github.com/linuxserver/docker-qbittorrent
- **Documentation**: https://github.com/qbittorrent/qBittorrent/wiki
- **Docker Hub**: https://hub.docker.com/r/linuxserver/qbittorrent

#### Deluge
- **Official Repository**: https://github.com/deluge-torrent/deluge
- **Docker Compose**: https://github.com/linuxserver/docker-deluge
- **Documentation**: https://deluge.readthedocs.io/en/latest/
- **Docker Hub**: https://hub.docker.com/r/linuxserver/deluge

### AI & Machine Learning Services

#### Ollama
- **Official Repository**: https://github.com/jmorganca/ollama
- **Docker Compose**: https://github.com/jmorganca/ollama/blob/main/docs/docker.md
- **Documentation**: https://github.com/jmorganca/ollama/blob/main/README.md
- **Docker Hub**: https://hub.docker.com/r/ollama/ollama

#### Ollama WebUI (Open WebUI)
- **Official Repository**: https://github.com/open-webui/open-webui
- **Docker Compose**: https://github.com/open-webui/open-webui#docker-compose
- **Documentation**: https://docs.openwebui.com/
- **Docker Hub**: https://hub.docker.com/r/ghcr.io/open-webui/open-webui

### Agent Services

#### Portainer Agent
- **Official Repository**: https://github.com/portainer/agent
- **Docker Compose**: https://docs.portainer.io/admin/environments/add/docker
- **Documentation**: https://docs.portainer.io/admin/environments/add/docker/agent
- **Docker Hub**: https://hub.docker.com/r/portainer/agent

#### Wazuh Agent
- **Official Repository**: https://github.com/wazuh/wazuh
- **Docker Compose**: https://github.com/wazuh/wazuh-docker/tree/master/single-node
- **Documentation**: https://documentation.wazuh.com/current/deployment-options/docker/wazuh-container.html
- **Docker Hub**: https://hub.docker.com/r/wazuh/wazuh-agent

---

## 🛠️ Community Resources & Configuration Collections

### Comprehensive Docker Compose Collections
- **Awesome-Compose**: https://github.com/docker/awesome-compose
- **Self-Hosted Services**: https://github.com/awesome-selfhosted/awesome-selfhosted
- **LinuxServer.io**: https://github.com/linuxserver (Excellent maintained images)
- **Homelab Services**: https://github.com/khuedoan/homelab

### Popular Homelab Configurations
- **DockSTARTer**: https://github.com/GhostWriters/DockSTARTer
- **Ansible NAS**: https://github.com/davestephens/ansible-nas
- **HomelabOS**: https://gitlab.com/NickBusey/HomelabOS

### Security-focused Compositions
- **Authelia**: https://github.com/authelia/authelia (Alternative to Authentik)
- **Traefik**: https://github.com/traefik/traefik (Alternative to Nginx Proxy Manager)
- **Fail2Ban**: https://github.com/crazy-max/docker-fail2ban

---

## ⚠️ Important Notes

### Before Deploying
1. **Review Security**: Always review compose files for security best practices
2. **Environment Variables**: Most services require environment configuration
3. **Data Persistence**: Ensure proper volume mounts for data persistence
4. **Network Configuration**: Configure networks for service communication
5. **Resource Limits**: Set appropriate memory and CPU limits

### Best Practices
- Use `.env` files for sensitive configuration
- Implement proper backup strategies for persistent data
- Keep images updated for security patches
---

## 💬 Node #2 (goingmerry) - Communication Services

### Matrix Synapse
- **Official Repository**: https://github.com/matrix-org/synapse
- **Docker Compose**: https://github.com/matrix-org/synapse/tree/develop/docker
- **Documentation**: https://matrix-org.github.io/synapse/latest/setup/installation.html
- **Docker Hub**: https://hub.docker.com/r/matrixdotorg/synapse

### Element Web
- **Official Repository**: https://github.com/vector-im/element-web
- **Docker Compose**: https://github.com/vector-im/element-web/blob/develop/docs/docker.md
- **Documentation**: https://element.io/help
- **Docker Hub**: https://hub.docker.com/r/vectorim/element-web

### Matrix Admin
- **Official Repository**: https://github.com/Awesome-Technologies/synapse-admin
- **Docker Compose**: https://github.com/Awesome-Technologies/synapse-admin/blob/master/docker-compose.yml
- **Documentation**: https://github.com/Awesome-Technologies/synapse-admin#readme
- **Docker Hub**: https://hub.docker.com/r/awesometechnologies/synapse-admin

---

## 🗄️ Node #1 (thousandsunny) - Database Services

### PostgreSQL
- **Official Repository**: https://github.com/postgres/postgres
- **Docker Compose**: https://github.com/docker-library/docs/tree/master/postgres
- **Documentation**: https://www.postgresql.org/docs/
- **Docker Hub**: https://hub.docker.com/_/postgres

### Redis
- **Official Repository**: https://github.com/redis/redis
- **Docker Compose**: https://github.com/docker-library/docs/tree/master/redis
- **Documentation**: https://redis.io/docs/
- **Docker Hub**: https://hub.docker.com/_/redis

### pgAdmin
- **Official Repository**: https://github.com/pgadmin-org/pgadmin4
- **Docker Compose**: https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html
- **Documentation**: https://www.pgadmin.org/docs/
- **Docker Hub**: https://hub.docker.com/r/dpage/pgadmin4

### Redis Commander
- **Official Repository**: https://github.com/joeferner/redis-commander
- **Docker Compose**: https://github.com/joeferner/redis-commander/blob/master/docs/docker.md
- **Documentation**: https://github.com/joeferner/redis-commander#readme
- **Docker Hub**: https://hub.docker.com/r/rediscommander/redis-commander

---

## 🛠️ Node #1 (thousandsunny) - DevOps Services

### Docker Registry
- **Official Repository**: https://github.com/distribution/distribution
- **Docker Compose**: https://docs.docker.com/registry/deploying/
- **Documentation**: https://docs.docker.com/registry/
- **Docker Hub**: https://hub.docker.com/_/registry

### Docker Registry UI
- **Official Repository**: https://github.com/Joxit/docker-registry-ui
- **Docker Compose**: https://github.com/Joxit/docker-registry-ui/blob/main/examples/ui-as-standalone/docker-compose.yml
- **Documentation**: https://github.com/Joxit/docker-registry-ui#readme
- **Docker Hub**: https://hub.docker.com/r/joxit/docker-registry-ui

### SonarQube
- **Official Repository**: https://github.com/SonarSource/sonarqube
- **Docker Compose**: https://github.com/SonarSource/docker-sonarqube/blob/master/example-compose-files/sq-with-postgres/docker-compose.yml
- **Documentation**: https://docs.sonarqube.org/latest/setup/install-server/
- **Docker Hub**: https://hub.docker.com/_/sonarqube

### SonarQube Scanner
- **Official Repository**: https://github.com/SonarSource/sonar-scanner-cli
- **Docker Compose**: https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/
- **Documentation**: https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/
- **Docker Hub**: https://hub.docker.com/r/sonarsource/sonar-scanner-cli

### Nexus Repository Manager
- **Official Repository**: https://github.com/sonatype/nexus-public
- **Docker Compose**: https://github.com/sonatype/docker-nexus3/blob/master/docker-compose.yml
- **Documentation**: https://help.sonatype.com/repomanager3
- **Docker Hub**: https://hub.docker.com/r/sonatype/nexus3

---

## 🏠 Node #1 (thousandsunny) - IoT & Home Automation

### Home Assistant
- **Official Repository**: https://github.com/home-assistant/core
- **Docker Compose**: https://github.com/home-assistant/docker
- **Documentation**: https://www.home-assistant.io/installation/
- **Docker Hub**: https://hub.docker.com/r/homeassistant/home-assistant

### Eclipse Mosquitto (MQTT)
- **Official Repository**: https://github.com/eclipse/mosquitto
- **Docker Compose**: https://github.com/eclipse/mosquitto/tree/master/docker
- **Documentation**: https://mosquitto.org/documentation/
- **Docker Hub**: https://hub.docker.com/_/eclipse-mosquitto

### InfluxDB
- **Official Repository**: https://github.com/influxdata/influxdb
- **Docker Compose**: https://github.com/influxdata/influxdata-docker/tree/master/influxdb
- **Documentation**: https://docs.influxdata.com/influxdb/
- **Docker Hub**: https://hub.docker.com/_/influxdb

### Zigbee2MQTT
- **Official Repository**: https://github.com/Koenkk/zigbee2mqtt
- **Docker Compose**: https://www.zigbee2mqtt.io/guide/installation/02_docker.html
- **Documentation**: https://www.zigbee2mqtt.io/
- **Docker Hub**: https://hub.docker.com/r/koenkk/zigbee2mqtt

### Node-RED
- **Official Repository**: https://github.com/node-red/node-red
- **Docker Compose**: https://nodered.org/docs/getting-started/docker
- **Documentation**: https://nodered.org/docs/
- **Docker Hub**: https://hub.docker.com/r/nodered/node-red

### ESPHome
- **Official Repository**: https://github.com/esphome/esphome
- **Docker Compose**: https://esphome.io/guides/getting_started_command_line.html#installation
- **Documentation**: https://esphome.io/
- **Docker Hub**: https://hub.docker.com/r/esphome/esphome

---

## 🔧 Enhanced CI/CD Services

### Gitea Actions
- **Official Repository**: https://github.com/go-gitea/gitea (Actions feature)
- **Actions Runner**: https://gitea.com/gitea/act_runner
- **Documentation**: https://docs.gitea.io/en-us/usage/actions/overview/
- **Docker Hub**: https://hub.docker.com/r/gitea/act_runner

---

## 🔧 Configuration Best Practices

### Security Considerations
- Always change default passwords in environment variables
- Use strong, unique passwords for each service
- Enable SSL/TLS certificates through Nginx Proxy Manager
- Configure proper firewall rules and network segmentation
- Regularly update container images and monitor for vulnerabilities

### Performance Optimization
- Allocate appropriate CPU and memory resources in compose files
- Use persistent volumes for data that should survive container restarts
- Configure proper logging levels to avoid excessive disk usage
- Monitor resource usage and performance
- Test configurations in development before production

### Community Support
- **Reddit**: r/selfhosted, r/homelab
- **Discord**: LinuxServer.io, Self-Hosted communities
- **Forums**: Many projects have dedicated forums for support

---

*This document is maintained as part of the SunnyLabX infrastructure. For the latest updates to service configurations, always refer to the official repositories listed above.*