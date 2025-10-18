# Hardware Details:

**Command Center: TheBaratie (Laptop)**

Nitro V 15 ANV15-41

- GeForce RTX 4050
- AMD Ryzen 5 7535HS w/ Radeon Graphics
- 16GB DDR5 RAM
- 1TB SSD + 500GB SSD
- PopOS - 192.168.0.222

**Node #1 ThousandSunny (Headless Server)**

- Dell XPS 8500
- GeForce GT 620
- i7-3770 CPU
- 8GB DDR3 + 4GB DDR3
- 1TB SSD (OS) + 9TB HDDs
- Ubuntu LTS 24.04 - 192.168.0.254

**Node #2 GoingMerry (Headless Server)**

- Mini PC
- Intel Twin Lake-N150
- 16GB DDR4
- 500GB NVMe SSD
- Ubuntu LTS 24.04 - 192.168.0.253

---

## 🚨 CRITICAL RESOURCE MANAGEMENT INSTRUCTIONS FOR FUTURE AGENTS

**MANDATORY**: All Docker services MUST include resource limits to prevent node overload. These limits are based on the actual hardware capabilities listed above.

### Node #1 (ThousandSunny) Resource Constraints
- **CPU**: i7-3770 (4 cores, 8 threads) - **LIMIT PER SERVICE: 2 CPUs MAX**
- **RAM**: 12GB DDR3 total - **LEAVE 2GB FOR SYSTEM = 10GB AVAILABLE**
- **Storage**: 1TB SSD + 9TB HDD - Media services get HDD mounts

### Node #2 (GoingMerry) Resource Constraints  
- **CPU**: Intel Twin Lake-N150 (4 cores) - **LIMIT PER SERVICE: 1.5 CPUs MAX**
- **RAM**: 16GB DDR4 total - **LEAVE 2GB FOR SYSTEM = 14GB AVAILABLE**
- **Storage**: 500GB NVMe - Lightweight services only, use NFS for media

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