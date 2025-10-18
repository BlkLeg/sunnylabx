# SunnyLabX Resource Limits Template

This template shows the correct way to add resource limits to Docker Compose services according to COPILOT_INSTRUCTIONS.md and INVENTORY.md guidelines.

## Template Structure

```yaml
services:
  service-name:
    image: example/image:latest
    container_name: service-name
    restart: unless-stopped
    
    # 🚨 REQUIRED: Resource limits based on node capacity
    deploy:
      resources:
        limits:
          cpus: '1.0'        # Max CPU cores (see node limits below)
          memory: 2G         # Max memory (see node limits below)
        reservations:
          cpus: '0.25'       # Minimum guaranteed CPU
          memory: 512M       # Minimum guaranteed memory
    
    # Service-specific configuration
    environment:
      - TZ=${TZ:-UTC}
    
    # Named volumes (REQUIRED per COPILOT_INSTRUCTIONS.md)
    volumes:
      - service_data:/data
      - service_config:/config
    
    # Logical networks (REQUIRED per COPILOT_INSTRUCTIONS.md)
    networks:
      - service_network

# Named volumes declaration
volumes:
  service_data:
    driver: local
  service_config:
    driver: local

# Network declaration
networks:
  service_network:
    driver: bridge
    name: service_network
```

## Node-Specific Resource Limits

### Node #1 (ThousandSunny) - 4 CPUs, 10GB Available RAM

#### High-Resource Services
```yaml
# Plex/Jellyfin Media Server
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 4G
    reservations:
      cpus: '1.0'
      memory: 2G
```

#### Database Services
```yaml
# PostgreSQL, MySQL, InfluxDB
deploy:
  resources:
    limits:
      cpus: '1.5'
      memory: 2G
    reservations:
      cpus: '0.5'
      memory: 1G
```

#### Home Automation
```yaml
# Home Assistant
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 1G
    reservations:
      cpus: '0.25'
      memory: 512M
```

#### ARR Suite Services
```yaml
# Sonarr, Radarr, Prowlarr, etc.
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
    reservations:
      cpus: '0.1'
      memory: 256M
```

### Node #2 (GoingMerry) - 4 CPUs, 14GB Available RAM

#### Monitoring Services
```yaml
# Grafana, Prometheus
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 1G
    reservations:
      cpus: '0.25'
      memory: 512M
```

#### Network Services
```yaml
# Nginx Proxy Manager
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 256M
    reservations:
      cpus: '0.1'
      memory: 128M
```

#### Light Services
```yaml
# Cloudflare Tunnel, Portainer Agent
deploy:
  resources:
    limits:
      cpus: '0.25'
      memory: 256M
    reservations:
      cpus: '0.05'
      memory: 128M
```

## Media Directory Structure (Node #1 Only)

```yaml
services:
  plex:
    image: plexinc/pms-docker:latest
    # ... other config ...
    volumes:
      # REQUIRED: Use exact paths from COPILOT_INSTRUCTIONS.md
      - /mnt/hdd-1/Movies:/data/movies1:ro
      - /mnt/hdd-2/movies-2:/data/movies2:ro
      - /mnt/hdd-3/moviess-3:/data/movies3:ro
      - /mnt/hdd-4/movies:/data/movies4:ro
      - /mnt/hdd-1/TV Shows:/data/tv1:ro
      - /mnt/hdd-2/tv-2:/data/tv2:ro
      - /mnt/hdd-3/tv-3:/data/tv3:ro
      - /mnt/hdd-4/tv:/data/tv4:ro
      # Named volume for config
      - plex_config:/config
```

## Network Structure Examples

### IoT Network (Node #1)
```yaml
networks:
  iot_network:
    driver: bridge
    name: iot_network
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Infrastructure Network (Node #1)
```yaml
networks:
  infra_network:
    driver: bridge
    name: infra_network
    ipam:
      config:
        - subnet: 172.21.0.0/16
```

### Management Network (Node #2)
```yaml
networks:
  mgmt_network:
    driver: bridge
    name: mgmt_network
    ipam:
      config:
        - subnet: 172.22.0.0/16
```

## Validation Commands

```bash
# Check resource usage after deployment
docker stats --no-stream

# Verify resource limits are applied
docker inspect <container_name> | grep -A 10 "Resources"

# Monitor system resources
htop
free -h

# Check for OOM errors
sudo dmesg | grep -i "killed process"
journalctl -u docker.service | grep -i "oom"
```

## ⚠️ Critical Reminders

1. **NEVER** exceed 80% of total node resources
2. **ALWAYS** include both limits AND reservations
3. **TEST** resource usage after deploying new services
4. **MONITOR** for OOM (Out of Memory) errors in logs
5. **USE** exact media paths from COPILOT_INSTRUCTIONS.md
6. **IMPLEMENT** logical network separation by service type
7. **AVOID** deploying heavy services on GoingMerry (Node #2)