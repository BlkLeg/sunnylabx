# Dual Proxmox Cluster Hardware Details:

**Command Center: TheBaratie (Laptop)**

Nitro V 15 ANV15-41

- GeForce RTX 4050
- AMD Ryzen 5 7535HS w/ Radeon Graphics
- 16GB DDR5 RAM
- 1TB SSD + 500GB SSD
- PopOS - 192.168.0.222

**Node #1 ThousandSunny (Proxmox Host)**

- Dell XPS 8500
- GeForce GT 620 (blacklisted nouveau driver)
- i7-3770 CPU (4c/8t)
- 8GB DDR3 + 4GB DDR3 = 12GB total
- 1TB SSD (OS) + 9TB HDDs (media storage)
- **Proxmox VE 8.x** - 192.168.0.254
- **Ubuntu LXC** (ID: 101) - 192.168.0.251 (36 services)
- **Wazuh Manager VM** (ID: 100) - 192.168.0.100 (4GB RAM)

**Node #2 GoingMerry (Proxmox Host)**

- Mini PC
- Intel Twin Lake-N150 (4 cores)
- 16GB DDR4
- 500GB NVMe SSD
- **Proxmox VE 8.x** - 192.168.0.253
- **Ubuntu LXC** (ID: 102) - 192.168.0.252 (13 services)

---

## 🚨 CRITICAL RESOURCE MANAGEMENT - DUAL PROXMOX CLUSTER

**MANDATORY**: All Docker services in LXC containers MUST include resource limits. These limits account for Proxmox host overhead and VM/LXC resource allocation.

### Node #1 (ThousandSunny) LXC Resource Constraints
- **Proxmox Host**: 2GB RAM reserved
- **Wazuh Manager VM**: 4GB RAM dedicated
- **Ubuntu LXC**: 8GB RAM allocated (ID: 101)
- **CPU**: 4 cores shared across LXC - **LIMIT PER SERVICE: 1.5 CPUs MAX**
- **Storage**: Direct HDD bind mounts to LXC for media services

### Node #2 (GoingMerry) LXC Resource Constraints  
- **Proxmox Host**: 2GB RAM reserved
- **Ubuntu LXC**: 6GB RAM allocated (ID: 102)
- **CPU**: 2 cores allocated to LXC - **LIMIT PER SERVICE: 1.0 CPU MAX**
- **Storage**: NVMe storage only, use NFS for media access

### Required Docker Compose Resource Syntax

**EVERY service MUST include these resource limits:**

```yaml
services:
  service-name:
    image: example/image:latest
    deploy:
      resources:
        limits:
          cpus: '1.0'        # Adjust per node constraints above
          memory: 2G         # Adjust per service needs and node capacity
        reservations:
          cpus: '0.25'       # Minimum guaranteed resources
          memory: 512M
    restart: unless-stopped
```

### Service-Specific Resource Guidelines

#### High-Resource Services (Node #1 Only)
- **Plex/Jellyfin**: CPU: 2.0, RAM: 4G
- **Home Assistant**: CPU: 1.0, RAM: 1G  
- **Database Services**: CPU: 1.5, RAM: 2G
- **AI Services**: CPU: 2.0, RAM: 6G (if implementing)

#### Medium-Resource Services
- **Monitoring (Grafana/Prometheus)**: CPU: 1.0, RAM: 1G
- **ARR Suite (each)**: CPU: 0.5, RAM: 512M
- **Reverse Proxy**: CPU: 0.5, RAM: 256M

#### Light Services (Node #2 Preferred)
- **Portainer Agent**: CPU: 0.1, RAM: 128M
- **Cloudflare Tunnel**: CPU: 0.1, RAM: 128M

### Resource Monitoring Commands

**Before deploying new services, ALWAYS check available resources:**

```bash
# Check current resource usage
docker stats --no-stream

# Check system resources
htop
free -h
df -h

# Check per-node limits
ansible-playbook -i hosts.ini resource-check-playbook.yml
```

### ⚠️ CRITICAL WARNINGS

1. **DO NOT** exceed 80% of total node resources
2. **DO NOT** deploy resource-intensive services on GoingMerry  
3. **DO NOT** forget to include CPU and memory limits in EVERY service
4. **ALWAYS** test resource usage after deployment
5. **MONITOR** `/var/log/syslog` for OOM (Out of Memory) errors

### Resource Allocation Priority

**Node #1 (ThousandSunny) - Total: 4 CPUs, 10GB RAM**
1. Media Services: 40% (1.6 CPU, 4GB RAM)
2. Home Automation: 25% (1 CPU, 2.5GB RAM)  
3. Infrastructure: 20% (0.8 CPU, 2GB RAM)
4. Development: 15% (0.6 CPU, 1.5GB RAM)

**Node #2 (GoingMerry) - Total: 4 CPUs, 14GB RAM**
1. Network Services: 30% (1.2 CPU, 4.2GB RAM)
2. Monitoring: 25% (1 CPU, 3.5GB RAM)
3. Security: 20% (0.8 CPU, 2.8GB RAM)
4. Management: 15% (0.6 CPU, 2.1GB RAM)
5. Communication: 10% (0.4 CPU, 1.4GB RAM)

**FAILURE TO FOLLOW THESE GUIDELINES WILL RESULT IN SYSTEM INSTABILITY AND SERVICE FAILURES**