# SunnyLabX Deployment Guide

This comprehensive guide walks you through deploying the entire SunnyLabX infrastructure in the optimal order to ensure seamless integration and minimal configuration issues. Follow this sequence for the smoothest deployment experience.

## 🎯 Deployment Overview

**Total Deployment Time**: 4-6 hours (depending on experience level)
**Services**: 53 containers across 12 categories
**Prerequisites**: Docker, Docker Compose, Ansible (optional)

## 📋 Pre-Deployment Checklist

### Hardware Requirements
- **Node #1 (thousandsunny)**: 8GB RAM, 4 CPU cores, 500GB storage
- **Node #2 (goingmerry)**: 4GB RAM, 2 CPU cores, 200GB storage
- **Network**: Gigabit Ethernet, static IP addresses recommended

### Software Prerequisites
```bash
# Install Docker and Docker Compose on both nodes
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Environment Preparation
```bash
# Clone the repository on both nodes
git clone https://github.com/BlkLeg/sunnylabx.git
cd sunnylabx

# Create environment files (copy examples and customize)
find . -name "*.env.example" -exec cp {} {/.env} \;
```

---

## 🚀 Phase 1: Core Infrastructure (Node #2 - goingmerry)

### Step 1.1: Network Foundation
Deploy the networking stack first as all other services depend on it.

```bash
cd goingmerry/networking
```

**Pre-configuration**:
1. **Cloudflare Setup**:
   - Register domain with Cloudflare
   - Create Cloudflare Tunnel in Zero Trust dashboard
   - Generate tunnel token and add to environment

2. **Environment Configuration**:
```bash
# Edit .env file
CLOUDFLARE_TUNNEL_TOKEN=your_tunnel_token_here
ADGUARD_USERNAME=admin
ADGUARD_PASSWORD=your_secure_password
```

**Deploy**:
```bash
docker-compose up -d
```

**Verification**:
- AdGuard Home: `http://node2-ip:3000` (initial setup)
- Nginx Proxy Manager: `http://node2-ip:81` (admin@example.com / changeme)
- Cloudflare Tunnel: Check tunnel status in Cloudflare dashboard

**Configuration Steps**:
1. **AdGuard Home Setup**:
   - Complete initial wizard
   - Configure upstream DNS (1.1.1.1, 8.8.8.8)
   - Enable DNS-over-HTTPS

2. **Nginx Proxy Manager Setup**:
   - Change default admin credentials
   - Configure first proxy host pointing to AdGuard (port 3000)
   - Request SSL certificate

### Step 1.2: Management Layer
Deploy Portainer for centralized container management.

```bash
cd ../management
docker-compose up -d
```

**Verification**:
- Portainer: `http://node2-ip:9000`
- Create admin account and password

**Configuration**:
1. Complete initial setup wizard
2. Add local environment
3. Configure edge compute settings for Node #1 connection

### Step 1.3: Security Foundation
Deploy the security stack before other services for protection.

```bash
cd ../security
```

**Pre-configuration**:
```bash
# Generate secure passwords for all services
AUTHENTIK_SECRET_KEY=$(openssl rand -base64 50)
WAZUH_API_PASSWORD=$(openssl rand -base64 32)
VAULTWARDEN_ADMIN_TOKEN=$(openssl rand -base64 48)
```

**Deploy**:
```bash
docker-compose up -d
```

**Verification & Configuration**:
1. **Authentik** (`http://node2-ip:9000/if/flow/initial-setup/`):
   - Complete initial setup
   - Create admin user
   - Configure default tenant

2. **Wazuh** (`http://node2-ip:443`):
   - Login with admin/admin
   - Change default password
   - Generate agent registration key

3. **Vaultwarden** (`http://node2-ip:8080`):
   - Create first account
   - Configure admin panel with token

---

## 🚀 Phase 2: Database Infrastructure (Node #1 - thousandsunny)

### Step 2.1: Database Stack
Deploy databases early as many services depend on them.

```bash
# On Node #1
cd thousandsunny/infra
```

**Pre-configuration**:
```bash
# Set strong database passwords
POSTGRES_PASSWORD=$(openssl rand -base64 32)
REDIS_PASSWORD=$(openssl rand -base64 32)
PGADMIN_PASSWORD=$(openssl rand -base64 24)
```

**Deploy**:
```bash
docker-compose -f docker-compose-database.yml up -d
```

**Verification**:
- PostgreSQL: `psql -h node1-ip -U postgres -d sunnylabx`
- pgAdmin: `http://node1-ip:5050`
- Redis Commander: `http://node1-ip:8081`

**Configuration**:
1. **pgAdmin Setup**:
   - Login with configured credentials
   - Add PostgreSQL server connection
   - Create databases for services (gitea, matrix, sonarqube)

---

## 🚀 Phase 3: Core Services (Node #1)

### Step 3.1: Development Infrastructure
Deploy Git hosting and development tools.

```bash
docker-compose -f docker-compose-gitea.yml up -d
```

**Verification & Configuration**:
1. **Gitea** (`http://node1-ip:3000`):
   - Complete installation wizard
   - Use existing PostgreSQL database
   - Configure admin account
   - Enable Actions in admin panel

2. **Gitea Actions Setup**:
   - Register runner with generated token
   - Configure runner labels and capabilities

3. **Nextcloud AIO** (`http://node1-ip:8080`):
   - Follow setup wizard
   - Configure master container
   - Deploy additional containers

### Step 3.2: DevOps Tools
Deploy code quality and registry services.

```bash
docker-compose -f docker-compose-devops.yml up -d
```

**Configuration**:
1. **SonarQube** (`http://node1-ip:9000`):
   - Login with admin/admin
   - Change default password
   - Install language plugins
   - Configure quality gates

2. **Docker Registry** (`http://node1-ip:5000`):
   - Configure authentication
   - Test image push/pull
   - Set up Registry UI access

---

## 🚀 Phase 4: Monitoring & Observability (Node #2)

### Step 4.1: Monitoring Stack
Deploy monitoring before adding more services to track everything.

```bash
# On Node #2
cd goingmerry/monitoring
docker-compose up -d
```

**Configuration**:
1. **Prometheus** (`http://node2-ip:9090`):
   - Verify targets are being scraped
   - Configure additional scrape configs

2. **Grafana** (`http://node2-ip:3000`):
   - Login with admin/admin
   - Change default password
   - Import dashboard templates
   - Configure Prometheus data source
   - Configure Loki data source

3. **Uptime Kuma** (`http://node2-ip:3001`):
   - Create admin account
   - Add monitoring for deployed services

---

## 🚀 Phase 5: Communication Platform (Node #2)

### Step 5.1: Matrix Communication
Deploy secure messaging infrastructure.

```bash
cd ../communication
```

**Pre-configuration**:
```bash
# Generate Matrix secrets
MATRIX_DB_PASSWORD=$(openssl rand -base64 32)
SLIDING_SYNC_SECRET=$(openssl rand -base64 48)
```

**Deploy**:
```bash
docker-compose up -d
```

**Configuration**:
1. **Matrix Synapse**:
   - Generate configuration file
   - Create first user account
   - Configure federation (if desired)

2. **Element Web**:
   - Configure homeserver URL
   - Test user login and room creation

---

## 🚀 Phase 6: IoT & Automation (Node #1)

### Step 6.1: IoT Platform
Deploy smart home automation stack.

```bash
# On Node #1
cd thousandsunny/iot
```

**Hardware Setup**:
- Connect Zigbee coordinator USB device
- Verify device permissions and udev rules

**Deploy**:
```bash
docker-compose up -d
```

**Configuration**:
1. **Home Assistant** (`http://node1-ip:8123`):
   - Complete onboarding wizard
   - Configure integrations (MQTT, InfluxDB)
   - Add Zigbee2MQTT integration

2. **MQTT Broker**:
   - Configure authentication
   - Test message publishing

3. **InfluxDB** (`http://node1-ip:8086`):
   - Complete setup wizard
   - Create Home Assistant bucket
   - Generate access tokens

4. **Zigbee2MQTT** (`http://node1-ip:8080`):
   - Configure Zigbee coordinator
   - Permit device joining
   - Map devices to Home Assistant

---

## 🚀 Phase 7: Media Services (Node #1)

### Step 7.1: Media Infrastructure
Deploy media servers and automation.

```bash
cd ../media
docker-compose up -d
```

**Configuration**:
1. **Plex** (`http://node1-ip:32400/web`):
   - Create account and claim server
   - Configure media libraries
   - Set up hardware transcoding (if available)

2. **Jellyfin** (`http://node1-ip:8096`):
   - Complete setup wizard
   - Configure media libraries
   - Create user accounts

3. **ARR Suite Configuration**:
   - **Prowlarr**: Configure indexers and sync to other ARR apps
   - **Sonarr**: Configure download clients, root folders, quality profiles
   - **Radarr**: Configure download clients, root folders, quality profiles
   - **Bazarr**: Configure subtitle providers and languages

4. **Overseerr** (`http://node1-ip:5055`):
   - Connect to Plex/Jellyfin
   - Configure request workflows

### Step 7.2: Download Clients

```bash
cd ../torrent
docker-compose up -d
```

**Configuration**:
1. **qBittorrent** (`http://node1-ip:8080`):
   - Change default password
   - Configure download paths
   - Set up categories and tags

---

## 🚀 Phase 8: AI & Advanced Services (Node #1)

### Step 8.1: AI/ML Platform

```bash
cd ../ai
docker-compose up -d
```

**Configuration**:
1. **Ollama** setup:
   - Pull desired models: `docker exec ollama ollama pull llama2`
   - Configure model parameters

2. **Ollama WebUI**:
   - Connect to Ollama backend
   - Test model interactions

---

## 🚀 Phase 9: Final Integration & Automation

### Step 9.1: Workflow Automation (Node #2)

```bash
# On Node #2
cd goingmerry/automation
docker-compose up -d
```

**Configuration**:
1. **n8n** (`http://node2-ip:5678`):
   - Create admin account
   - Configure credentials for other services
   - Import workflow templates

### Step 9.2: Agent Connections (Node #1)

```bash
# On Node #1
cd thousandsunny/agents
docker-compose up -d
```

**Configuration**:
1. **Portainer Agent**:
   - Connect to Portainer controller on Node #2
   - Verify environment appears in Portainer UI

2. **Wazuh Agent**:
   - Register with Wazuh manager using registration key
   - Verify agent appears in Wazuh dashboard

---

## 🔧 Post-Deployment Configuration

### Security Hardening
1. **SSL Certificate Configuration**:
   - Configure Let's Encrypt certificates in Nginx Proxy Manager
   - Update all service URLs to use HTTPS

2. **Single Sign-On Setup**:
   - Configure Authentik providers for each service
   - Update service configurations to use Authentik for authentication

3. **Network Security**:
   - Configure firewall rules (UFW)
   - Set up network segmentation
   - Enable fail2ban for SSH protection

### Backup Configuration
1. **Duplicati Setup**:
   - Configure backup destinations (cloud storage)
   - Set up scheduled backups for critical data
   - Test restore procedures

### Monitoring Enhancement
1. **Dashboard Import**:
   - Import pre-built Grafana dashboards
   - Configure alerting rules in Prometheus
   - Set up notification channels

### Documentation
1. **Service Inventory**:
   - Document all service URLs and credentials
   - Create network diagram
   - Document backup and recovery procedures

---

## 🛠️ Troubleshooting Common Issues

### Container Startup Issues
```bash
# Check container logs
docker-compose logs service-name

# Restart specific service
docker-compose restart service-name

# Check resource usage
docker stats
```

### Network Connectivity
```bash
# Test inter-container communication
docker exec -it container-name ping other-container

# Check port bindings
docker port container-name

# Verify network configuration
docker network ls
docker network inspect network-name
```

### Database Connection Issues
```bash
# Test PostgreSQL connection
docker exec -it postgres psql -U username -d database

# Check Redis connectivity
docker exec -it redis redis-cli ping

# Monitor database logs
docker logs postgres
```

### Service-Specific Issues

#### Gitea Actions Not Working
- Verify runner registration token
- Check runner container logs
- Ensure Docker socket is mounted

#### Home Assistant Device Discovery
- Check MQTT broker connectivity
- Verify Zigbee coordinator permissions
- Enable network discovery in configuration

#### Media Services Not Scanning
- Verify volume mounts and permissions
- Check storage paths in service configs
- Monitor download client connectivity

---

## 📊 Deployment Verification Checklist

### Core Infrastructure ✅
- [ ] All containers running without errors
- [ ] Network connectivity between nodes
- [ ] DNS resolution working (AdGuard)
- [ ] External access via Cloudflare Tunnel

### Security & Identity ✅
- [ ] Authentik SSO functional
- [ ] Wazuh agents reporting
- [ ] Security monitoring active
- [ ] Vaultwarden accessible

### Development & DevOps ✅
- [ ] Gitea repositories accessible
- [ ] CI/CD pipelines functional
- [ ] Code quality scans working
- [ ] Docker registry operational

### Media & Content ✅
- [ ] Media servers streaming content
- [ ] Download automation working
- [ ] Request system functional
- [ ] Transcoding operational

### IoT & Automation ✅
- [ ] Home Assistant dashboard accessible
- [ ] MQTT broker receiving messages
- [ ] Device automation working
- [ ] Data logging to InfluxDB

### Monitoring & Alerts ✅
- [ ] Metrics collection active
- [ ] Dashboards populated with data
- [ ] Log aggregation working
- [ ] Alerting rules configured

---

## 🎯 Performance Optimization

### Resource Allocation
- Monitor container resource usage
- Adjust CPU/memory limits as needed
- Optimize storage for high-traffic services

### Network Optimization
- Configure proper DNS caching
- Optimize reverse proxy settings
- Enable HTTP/2 and compression

### Database Tuning
- Configure PostgreSQL for workload
- Optimize Redis memory settings
- Set up proper indexing

---

## 📚 Additional Resources

### Documentation Links
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Traefik Configuration](https://doc.traefik.io/traefik/)
- [Home Assistant Setup](https://www.home-assistant.io/installation/)
- [Matrix Synapse Admin Guide](https://matrix-org.github.io/synapse/latest/)

### Community Support
- **Reddit**: r/selfhosted, r/homelab
- **Discord**: LinuxServer.io Community
- **Forums**: Service-specific support forums

### Backup Repository
Keep this deployment guide and all configuration files in version control for easy recovery and redeployment.

---

*Last Updated: October 2025*
*Version: 2.0*
*SunnyLabX Infrastructure - 53 Services Deployment Guide*