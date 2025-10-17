# SunnyLabX Port Allocation Registry

This document provides a comprehensive registry of all port allocations across both nodes to prevent conflicts and ensure proper service accessibility.

## 🎯 Port Allocation Strategy

**Port Range Strategy:**
- **1000-2999**: Network services, protocols, and agents
- **3000-3999**: Web applications and primary services
- **4000-4999**: Reserved for future expansion
- **5000-5999**: Database services and storage
- **6000-6999**: Specialized services and tools
- **7000-7999**: Reserved for future expansion
- **8000-8999**: Web interfaces and admin panels
- **9000-9999**: Management and monitoring services
- **10000+**: Enterprise and specialized applications

---

## 🚢 Node #2 (goingmerry) - Management & Control Hub

### Current Port Allocations

| Port | Service | Container | Category | Purpose |
|------|---------|-----------|----------|---------|
| **8008** | Matrix Synapse | matrix-synapse | Communication | Matrix homeserver API |
| **8009** | Matrix Sliding Sync | matrix-sliding-sync | Communication | Enhanced Matrix sync |
| **8080** | Element Web | element-web | Communication | Matrix web client |
| **8090** | Matrix Admin | matrix-admin | Communication | Matrix administration |
| **8448** | Matrix Federation | matrix-synapse | Communication | Matrix federation port |

### Reserved Placeholder Ports (Need Implementation)

| Port | Service | Category | Status |
|------|---------|----------|--------|
| **80** | Nginx Proxy Manager | Networking | Placeholder |
| **443** | Nginx Proxy Manager SSL | Networking | Placeholder |
| **3000** | AdGuard Home | Networking | Placeholder |
| **9000** | Portainer Controller | Management | Placeholder |
| **9090** | Prometheus | Monitoring | Placeholder |
| **3000** | Grafana | Monitoring | Placeholder ⚠️ (Port conflict with AdGuard) |
| **3001** | Uptime Kuma | Monitoring | Placeholder |
| **5678** | n8n | Automation | Placeholder |

### 🔴 Identified Conflicts on Node #2
- **Port 3000**: AdGuard Home vs Grafana
- **Port 8080**: Element Web conflicts with multiple Node #1 services

### 🔧 Proposed Fixes for Node #2
- **AdGuard Home**: Move to port **3003**
- **Grafana**: Use port **3004**
- **Element Web**: Move to port **8087**

---

## ⛵ Node #1 (thousandsunny) - Applications & Content Hub

### Current Port Allocations (Active Services)

#### Infrastructure & Development (1000-3999)
| Port | Service | Container | Category | Purpose |
|------|---------|-----------|----------|---------|
| **2222** | Gitea SSH | gitea | Infrastructure | Git SSH operations |
| **3000** | Gitea Web | gitea | Infrastructure | Git web interface |
| **3001** | IoT Grafana | iot-grafana | IoT | IoT-specific dashboards |

#### Database Services (5000-5999)
| Port | Service | Container | Category | Purpose |
|------|---------|-----------|----------|---------|
| **5000** | Docker Registry | registry | DevOps | Private image registry |
| **5001** | Registry UI | registry-ui | DevOps | Registry web interface |
| **5050** | pgAdmin | pgadmin | Database | PostgreSQL admin |
| **5432** | PostgreSQL | postgres | Database | Database server |

#### Specialized Services (6000-6999)
| Port | Service | Container | Category | Purpose |
|------|---------|-----------|----------|---------|
| **6052** | ESPHome | esphome | IoT | ESP device management |
| **6379** | Redis | redis | Database | Cache server |

#### Web Interfaces (8000-8999)
| Port | Service | Container | Category | Purpose |
|------|---------|-----------|----------|---------|
| **8080** | Nextcloud AIO | nextcloud-aio | Infrastructure | Cloud admin interface |
| **8081** | Redis Commander | redis-commander | Database | Redis web interface |
| **8083** | Nexus Repository | nexus | DevOps | Artifact repository (fixed) |
| **8084** | Nexus Docker | nexus | DevOps | Docker registry port (fixed) |
| **8085** | Zigbee2MQTT | zigbee2mqtt | IoT | Zigbee management (fixed) |
| **8086** | InfluxDB | influxdb | IoT | Time-series database |
| **8200** | Duplicati | duplicati | Infrastructure | Backup management |

#### Management & Monitoring (9000-9999)
| Port | Service | Container | Category | Purpose |
|------|---------|-----------|----------|---------|
| **9000** | SonarQube | sonarqube | DevOps | Code quality analysis |
| **9001** | MQTT WebSocket | mosquitto | IoT | MQTT over WebSocket |

#### Enterprise Applications (10000+)
| Port | Service | Container | Category | Purpose |
|------|---------|-----------|----------|---------|
| **11000** | Nextcloud | nextcloud-aio | Infrastructure | Private cloud interface |

#### IoT & Communication (1000-1999)
| Port | Service | Container | Category | Purpose |
|------|---------|-----------|----------|---------|
| **1880** | Node-RED | nodered | IoT | Visual programming |
| **1883** | MQTT Broker | mosquitto | IoT | IoT message broker |

### Reserved Placeholder Ports (Need Implementation)

#### Media Services
| Port | Service | Category | Status |
|------|---------|----------|--------|
| **32400** | Plex | Media | Placeholder |
| **8096** | Jellyfin | Media | Placeholder |
| **3001** | Immich | Media | Placeholder ⚠️ (Conflicts with IoT Grafana) |
| **5055** | Kavita | Media | Placeholder |
| **9696** | Prowlarr | Media | Placeholder |
| **8989** | Sonarr | Media | Placeholder |
| **7878** | Radarr | Media | Placeholder |
| **6767** | Bazarr | Media | Placeholder |
| **5055** | Overseerr | Media | Placeholder |

#### Download Management
| Port | Service | Category | Status |
|------|---------|----------|--------|
| **8080** | qBittorrent | Torrent | Placeholder ⚠️ (Conflicts with Nextcloud) |
| **8112** | Deluge | Torrent | Placeholder |

#### AI & Machine Learning
| Port | Service | Category | Status |
|------|---------|----------|--------|
| **11434** | Ollama | AI | Placeholder |
| **3000** | Ollama WebUI | AI | Placeholder ⚠️ (Conflicts with Gitea) |

### 🔴 Identified Conflicts on Node #1
1. **Port 3001**: IoT Grafana vs Immich (placeholder)
2. **Port 3000**: Gitea vs Ollama WebUI (placeholder)
3. **Port 8080**: Nextcloud vs qBittorrent (placeholder)
4. **Port 5055**: Kavita vs Overseerr (placeholder)

---

## 🔧 Port Conflict Resolution Plan

### Phase 1: Immediate Fixes (Implemented)
- ✅ **Zigbee2MQTT**: 8080 → 8085
- ✅ **Nexus Repository**: 8081 → 8083, 8082 → 8084

### Phase 2: Node #2 Placeholder Resolution (Needed)
```yaml
# Proposed Node #2 port assignments
ports:
  adguard: "3003:3000"          # DNS & ad blocking
  grafana: "3004:3000"          # Monitoring dashboards  
  element-web: "8087:80"        # Matrix web client
  nginx-proxy: "81:81"          # Proxy manager admin
  portainer: "9000:9000"        # Container management
  prometheus: "9090:9090"       # Metrics collection
  uptime-kuma: "3005:3001"      # Service monitoring
  n8n: "5678:5678"             # Workflow automation
```

### Phase 3: Node #1 Placeholder Resolution (Needed)
```yaml
# Proposed Node #1 port assignments for placeholders
ports:
  # Media Services
  plex: "32400:32400"           # Media server
  jellyfin: "8096:8096"         # Alternative media server
  immich: "2283:3001"           # Photo management (avoid 3001 conflict)
  kavita: "5000:5000"           # Digital library (reassign current registry)
  prowlarr: "9696:9696"         # Indexer management
  sonarr: "8989:8989"           # TV automation
  radarr: "7878:7878"           # Movie automation
  bazarr: "6767:6767"           # Subtitle management
  overseerr: "5055:5055"        # Request management
  
  # Download Management
  qbittorrent: "8088:8080"      # Torrent client (avoid 8080 conflict)
  deluge: "8112:8112"           # Alternative torrent client
  
  # AI Services
  ollama: "11434:11434"         # LLM runtime
  ollama-webui: "3002:3000"     # AI web interface (avoid 3000 conflict)
  
  # Registry relocation (due to Kavita)
  docker-registry: "5002:5000"  # Move from 5000 to avoid Kavita conflict
```

---

## 📊 Port Usage Summary

### Node #2 (goingmerry)
- **Active Ports**: 5 (Communication stack only)
- **Reserved Ports**: 8 (Placeholders)
- **Conflicts**: 2 (AdGuard/Grafana, Element/Node#1)

### Node #1 (thousandsunny)  
- **Active Ports**: 19 (Infrastructure, Database, DevOps, IoT)
- **Reserved Ports**: 15 (Media, Torrent, AI placeholders)
- **Conflicts**: 4 (resolved 2, need to resolve 2 more)

### Total Infrastructure
- **Total Ports**: 47 ports across both nodes
- **Active Services**: 24 ports
- **Reserved Services**: 23 ports
- **Resolved Conflicts**: 2/6

---

## 🛡️ Port Security Considerations

### External Access Ports
These services should be accessible via Cloudflare Tunnel only:
- Nginx Proxy Manager (Node #2)
- Matrix/Element (Node #2) 
- Home Assistant (Node #1)
- Media servers (Node #1)

### Internal Only Ports
These services should remain internal network only:
- Database services (PostgreSQL, Redis, InfluxDB)
- MQTT Broker
- Monitoring backends (Prometheus)

### Admin Interface Ports
These require additional authentication:
- Portainer (Node #2)
- SonarQube (Node #1)
- Grafana (Both nodes)
- pgAdmin (Node #1)

---

## 🔄 Port Management Best Practices

1. **Documentation**: Always update this registry when adding services
2. **Testing**: Verify port availability before deployment
3. **Monitoring**: Use `netstat -tulpn` to check active ports
4. **Firewall**: Configure UFW rules for external-facing services
5. **SSL**: Use Nginx Proxy Manager for SSL termination
6. **Health Checks**: Implement port-based health checks

---

*Last Updated: October 2025*
*Version: 1.0*
*Total Services: 53 containers, 47 unique ports*