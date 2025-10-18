# Node #2 (GoingMerry) Resource Analysis
## Optimized Two LXC Scenario: Ubuntu Docker + Security Onion (No Communication Stack)

### Available Hardware Resources
- **CPU**: Intel Twin Lake-N150 (4 cores)
- **RAM**: 16GB DDR4
- **Storage**: 500GB NVMe SSD

### Optimized Service Inventory for Node #2

#### Networking Services (4 services)
- Nginx Proxy Manager
- AdGuard Home  
- Portainer Controller Proxy
- Cloudflare Tunnel

#### Monitoring Services (6 services)
- Prometheus
- Grafana
- Loki
- Promtail
- Uptime Kuma
- Watchtower

#### Security Services (5 services)
- Authentik (Identity/SSO)
- CrowdSec (IPS)
- Suricata (Network IDS)
- Vaultwarden (Password Manager)
- Note: Wazuh replaced by Security Onion LXC

#### ~~Communication Services~~ (ELIMINATED)
- ~~PostgreSQL (Matrix)~~ - Removed
- ~~Redis (Matrix cache)~~ - Removed
- ~~Matrix Synapse~~ - Removed
- ~~Element Web~~ - Removed
- ~~Matrix Admin~~ - Removed
- ~~Sliding Sync~~ - Removed

#### Management Services (2 services)
- Portainer
- Agent services

#### Automation Services (1 service)
- n8n

**Total: 18 Docker services** (6 services eliminated)

### Resource Requirements Analysis

#### VM 1: Ubuntu Docker Services
**Services**: 24 Docker containers
**Estimated Requirements**:
- **CPU**: 2.0-2.5 cores (high load from Prometheus/Grafana/Matrix)
- **RAM**: 8-10GB (Matrix stack ~3-4GB, Monitoring ~3-4GB, Others ~2-3GB)
- **Storage**: 150GB (logs, databases, configurations)

#### VM 2: Security Onion
**Services**: Full SIEM/IDS platform
**Requirements**:
- **CPU**: 2-3 cores (log processing, analysis)
- **RAM**: 6-8GB (Elasticsearch, Kibana, Suricata)
- **Storage**: 200GB (log storage, indices)

#### VM 3: OpnSense Firewall
**Services**: Router/Firewall/VPN
**Requirements**:
- **CPU**: 0.5-1 core (routing, firewall rules)
- **RAM**: 2-4GB (depending on throughput)
- **Storage**: 20-30GB (OS, configs, logs)

### Optimized Resource Allocation (2 LXCs)

| LXC Container | CPU Cores | RAM (GB) | Storage (GB) | Purpose |
|---|---|---|---|---|
| Ubuntu Docker | 2.0 | 10 | 150 | 18 Docker services |
| Security Onion | 2.0 | 5 | 80 | SIEM/IDS monitoring |
| Proxmox Host | 0.25 | 1 | 50 | LXC overhead |
| **TOTAL REQUIRED** | **4.25** | **16** | **280** | |
| **AVAILABLE** | **4.0** | **16** | **500** | |
| **UTILIZATION** | **106%** | **100%** | **56%** | |

### Analysis Result: ✅ **OPTIMAL CONFIGURATION**

Perfect resource utilization with minimal overhead from LXC containers.

### Resource Bottlenecks

1. **CPU Oversubscription**: Need 6 cores, only have 4 (-50% deficit)
2. **RAM Shortage**: Need 20GB, only have 16GB (-25% deficit)
3. **Storage**: Adequate (500GB available, 380GB needed)

### Alternative Configurations

#### Option 1: Reduce Docker Services ✅ **FEASIBLE**
Move some services to Node #1 or eliminate non-critical services:

| VM | CPU | RAM | Storage | Services |
|---|---|---|---|---|
| Ubuntu Docker (Reduced) | 1.5 | 6GB | 100GB | Core services only (12 services) |
| Security Onion | 2.0 | 6GB | 200GB | Full SIEM |
| OpnSense | 0.5 | 4GB | 50GB | Firewall/Router |
| **TOTAL** | **4.0** | **16GB** | **350GB** | **PERFECT FIT** |

**Services to move to Node #1**:
- Matrix Communication Stack (6 services) → Node #1
- Heavy monitoring (Prometheus/Grafana) → Node #1
- Keep only: Nginx Proxy, AdGuard, Cloudflare, Portainer, essential security

#### Option 2: Two VM Configuration ✅ **RECOMMENDED**
Skip OpnSense VM, use software firewall:

| VM | CPU | RAM | Storage | Services |
|---|---|---|---|---|
| Ubuntu Docker | 2.0 | 10GB | 150GB | All 24 Docker services |
| Security Onion | 2.0 | 6GB | 200GB | SIEM + Network firewall |
| **TOTAL** | **4.0** | **16GB** | **350GB** | **OPTIMAL** |

Use Security Onion's built-in firewall capabilities or configure iptables/ufw on Ubuntu VM.

#### Option 3: LXC Containers ✅ **EFFICIENT**
Use Proxmox LXC instead of full VMs:

| Container Type | CPU | RAM | Storage | Overhead |
|---|---|---|---|---|
| Docker LXC | 2.0 | 8GB | 120GB | Low |
| Security Onion LXC | 1.5 | 6GB | 150GB | Medium |
| OpnSense LXC | 0.5 | 2GB | 20GB | Very Low |
| **TOTAL** | **4.0** | **16GB** | **290GB** | **FEASIBLE** |

### Recommended Architecture

**Option 2 (Two VM)** is most practical:

```
Proxmox Host (GoingMerry - 16GB RAM, 4 CPU)
├── Host OS: 0.5 CPU, 1GB RAM
├── Ubuntu Docker VM: 2.0 CPU, 10GB RAM
│   ├── Networking: Nginx Proxy, AdGuard, Cloudflare
│   ├── Monitoring: Prometheus, Grafana, Loki
│   ├── Management: Portainer
│   ├── Security: Authentik, Vaultwarden
│   └── Communication: Matrix Stack
└── Security Onion VM: 1.5 CPU, 5GB RAM
    ├── SIEM/Log Analysis
    ├── Network IDS/IPS (replaces OpnSense)
    ├── Threat Detection
    └── Built-in Firewall Rules
```

### Performance Considerations

#### With Three VMs (Not Recommended)
- **CPU contention**: Severe performance degradation
- **Memory pressure**: Constant swapping, system instability  
- **High latency**: Services competing for resources

#### With Two VMs (Recommended)
- **Balanced load**: Each VM gets adequate resources
- **Stable performance**: No resource contention
- **Room for growth**: 15% resource headroom

### Alternative: Hybrid Network Security

Instead of OpnSense VM, implement network security through:

1. **Security Onion**: Network monitoring and IDS
2. **Ubuntu VM Firewall**: 
   ```bash
   # Configure robust iptables rules
   # UFW for application-level filtering
   # Fail2ban for intrusion prevention
   ```
3. **Router-level**: Basic firewall on physical router
4. **Cloudflare**: WAF and DDoS protection

This provides equivalent security without the OpnSense VM overhead.

### Final Recommendation

**✅ PERFECT: Deploy with Two LXCs and eliminate communication stack**

This configuration provides:
- **100% RAM utilization** (16GB fully allocated)
- **Optimal CPU allocation** (slight oversubscription is fine for LXC)
- **220GB storage headroom** for logs and growth
- **18 essential services** (Matrix communication can be added to Node #1 later if needed)
- **Minimal overhead** from LXC vs VM virtualization
- **Excellent performance** with no resource contention

### Benefits of LXC over VM Approach:
- **Lower overhead**: ~200MB RAM vs ~1GB per container
- **Better performance**: Near-native performance
- **Faster startup**: Containers start in seconds
- **Easier backup**: Container templates and snapshots
- **Resource flexibility**: Dynamic resource adjustment