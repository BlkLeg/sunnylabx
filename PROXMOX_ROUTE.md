# SunnyLabX Dual Proxmox Deployment Route

This deployment guide walks you through a **dual Proxmox virtualization approach** optimized for the SunnyLabX hardware constraints. After comprehensive analysis of service overlap and resource optimization, this route provides unified management, superior backup capabilities, and significant resource savings through elimination of redundant services.

## 🎯 Architecture Overview

**Total Deployment Time**: 8-10 hours (including dual Proxmox setup and service migration)
**Services**: 42-44 containers across dual Proxmox deployment (optimized from 48-50)
**Approach**: Dual Proxmox - Unified virtualization across both nodes

### Optimized Node Configuration
- **Node #1 (ThousandSunny)**: Proxmox VE 8.x - Application & Storage Hub
  - **Debian Docker VM**: 39+ containers (media, databases, development, security)
  - **Resource Optimization**: Direct storage access via bind mounts
- **Node #2 (GoingMerry)**: Proxmox VE 8.x - Management & Security Hub  
  - **Debian Docker LXC**: 9 containers (monitoring, networking) - communication eliminated
  - **OPNsense Firewall VM**: Advanced network security with NordVPN

### Why Dual Proxmox Approach?
- **Unified Management**: Single interface for both nodes via Proxmox cluster
- **Resource Optimization**: 1.75GB RAM saved through service elimination
- **Superior Backups**: Built-in VM/LXC snapshots and incremental backups
- **Simplified Monitoring**: Native infrastructure monitoring included
- **Better Resource Allocation**: Dynamic resource management across cluster

## 📋 Hardware Analysis & Resource Allocation

### Node #1 (ThousandSunny) - Proxmox Application Hub
- **Hardware**: Dell XPS 8500, i7-3770 (4c/8t), 12GB DDR3, 1TB SSD + 9TB HDD
- **Host OS**: Proxmox VE 8.x
- **IP**: 192.168.0.254
- **Services**: 37+ containers in Debian LXC (includes Dockerized Wazuh SIEM)
- **Resource Advantage**: 12GB available vs 7-8GB estimated need (comfortable headroom)
- **Strategy**: LXC deployment with aggressive resource limits, direct storage bind mounts

#### Service Categories (Node #1) - Optimized
- **Media Services (4)**: Plex OR Jellyfin (backup), Radarr, Immich (~4-5GB RAM) - *Jellyfin only runs when Plex is down*
- **Infrastructure (13)**: Databases, DevOps, Gitea, Nextcloud (~4-5GB RAM) - **Duplicati eliminated**
- **Torrent/Download (1)**: Deluge (~0.5GB RAM)
- **Agents (1)**: **Portainer Agent eliminated** (~128MB RAM)
- **Automation**: Home Assistant, MQTT, InfluxDB moved to Node #2

### Node #2 (GoingMerry) - Proxmox Management Hub
- **Hardware**: Mini PC, Intel Twin Lake-N150 (4 cores), 16GB DDR4, 500GB NVMe
- **Host OS**: Proxmox VE 8.x
- **IP**: 192.168.0.253
- **Services**: 9 containers in Debian LXC + OPNsense VM (communication stack eliminated)
- **Resource Advantage**: 16GB available vs 4GB estimated need (significant headroom)

#### VM/LXC Resource Allocation Strategy (Debian)
```
Total Resources: 16GB RAM, 4 CPU cores, 25GB SWAP
├── Proxmox Host: 1GB RAM, 0.25 CPU (minimal overhead)
├── Debian Docker LXC: 8GB RAM, 3.25 CPU (14 services - includes automation stack)
├── OPNsense Firewall VM: 1GB RAM, 0.5 CPU (NordVPN distribution)
└── Utilization: 62.5% RAM, 100% CPU + 6GB unallocated + 25GB SWAP buffer
```

#### Service Categories (Node #2) - Streamlined
- **Networking (2)**: Nginx Proxy, Cloudflare (~256MB RAM)
- **Monitoring (6)**: Prometheus, Grafana, Loki, Promtail, AlertManager, Node-Exporter (~2-3GB RAM)
- **Security (2)**: Authentik, CrowdSec (~1GB RAM)
- **Automation (4)**: n8n, Home Assistant, MQTT, InfluxDB (~2.5GB RAM)
- **Total: 14 services**

## 🔧 Phase 1: Node #1 Proxmox Installation (ThousandSunny)

### Step 1.1: Proxmox VE Installation on ThousandSunny

1. **Pre-Installation: GPU Compatibility Fix**
   ```bash
   # Boot from Proxmox VE USB drive
   # At GRUB boot menu, select "Install Proxmox VE (Graphical)"
   # Press 'e' to edit boot parameters before booting
   
   # Find the line starting with "linux /boot/..."
   # Add "nomodeset" to the end of that line:
   # Example: linux /boot/vmlinuz-... quiet nomodeset
   
   # Press Ctrl+X or F10 to boot with modified parameters
   # This prevents GPU driver conflicts during installation
   ```

2. **Proxmox VE Installation** *(After GPU parameter fix)*
   - Complete installation with modified boot parameters
   - Configure network: 192.168.0.254/24, Gateway: 192.168.0.1
   - Set root password and email
   - Use 1TB SSD for Proxmox system and LXC storage
   - Configure HDD storage as additional storage for media bind mounts

2. **Post-Installation Configuration**
   ```bash
   # SSH to Node #1
   ssh root@192.168.0.254
   
   # Update Proxmox
   apt update && apt full-upgrade
   
   # Remove enterprise repository warnings
   sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
   
   # Add no-subscription repository
   echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
   apt update
   ```

3. **GPU Driver Management (Blacklist Nouveau)**
   ```bash
   # Blacklist nouveau driver to prevent conflicts
   echo "blacklist nouveau" >> /etc/modprobe.d/blacklist-nouveau.conf
   echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nouveau.conf
   
   # Update initramfs to apply changes
   update-initramfs -u
   
   # Optional: Install NVIDIA drivers if GPU will be used for transcoding
   # Note: This step can be deferred until LXC GPU passthrough is needed
   # apt install nvidia-driver
   
4. **Configure HDD Storage for Media**
   ```bash
   # Mount HDDs for media storage (direct access via bind mounts)
   mkdir -p /mnt/hdd-{1,2,3,4}
   
   # Add to fstab for persistent mounting
   echo "/dev/sdb1 /mnt/hdd-1 ext4 defaults 0 2" >> /etc/fstab
   echo "/dev/sdc1 /mnt/hdd-2 ext4 defaults 0 2" >> /etc/fstab
   echo "/dev/sdd1 /mnt/hdd-3 ext4 defaults 0 2" >> /etc/fstab
   echo "/dev/sde1 /mnt/hdd-4 ext4 defaults 0 2" >> /etc/fstab
   
   # Mount all HDD storage
   mount -a
   ```

5. **Storage Configuration**
   ```bash
   # Optimize storage layout via web interface
   # local: Proxmox system (100GB from SSD)
   # local-lvm: LXC containers (900GB from SSD)
   # hdd-storage: Media storage (9TB across HDDs)
   ```

## 🔧 Phase 2: Node #2 Proxmox Installation & Cluster Setup (GoingMerry)

### Prerequisites: Required ISO Files
Before starting, ensure the following ISO files are available:
- **Proxmox VE 8.2-1 ISO**: Downloaded and flashed to USB drive for both node installations
- **OPNsense ISO**: Latest release for firewall VM installation  
- **Debian Cloud Image**: `debian-12-generic-amd64.tar.xz` uploaded to Proxmox storage for LXCs

*Note: This guide assumes ISOs are pre-downloaded and available locally to avoid extended download times during deployment.*

### Step 2.1: Proxmox VE Installation on GoingMerry

1. **Proxmox VE Installation** *(Uses pre-prepared USB drive)*
   - Boot GoingMerry from Proxmox VE USB
   - Configure network: 192.168.0.253/24, Gateway: 192.168.0.1
   - Set root password and email
   - Use entire 500GB NVMe for storage

2. **Post-Installation Configuration**
   ```bash
   # SSH to Node #2
   ssh root@192.168.0.253
   
   # Update Proxmox
   apt update && apt full-upgrade
   
   # Remove enterprise repository warnings
   sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
   
   # Add no-subscription repository
   echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
   apt update
   ```

3. **Upload Required ISOs to Proxmox Storage**
   ```bash
   # Access Proxmox web interface: https://192.168.0.253:8006
   # Navigate to: Datacenter > Storage > local > ISO Images
   # Upload the following files:
   # - ubuntu-22.04-server-amd64.iso (for Wazuh Manager VM)
   # - jammy-server-cloudimg-amd64.img (for Ubuntu LXCs)
   # 
   # Alternative: Copy via SCP if files are on local network
   # scp ubuntu-22.04-server-amd64.iso root@192.168.0.253:/var/lib/vz/template/iso/
   # scp jammy-server-cloudimg-amd64.img root@192.168.0.253:/var/lib/vz/template/iso/
   ```

### Step 2.2: Proxmox Cluster Configuration

1. **Create Cluster on Node #2**
   ```bash
   # On GoingMerry (192.168.0.253)
   pvecm create sunnylabx-cluster
   
   # Verify cluster status
   pvecm status
   ```

2. **Join Node #1 to Cluster**
   ```bash
   # On ThousandSunny (192.168.0.254)
   # First, get cluster join information from Node #2
   # Access Node #2 web UI: Datacenter > Cluster > Join Information
   
   # Join the cluster
   pvecm add 192.168.0.253
   
   # Enter cluster password when prompted
   ```

3. **Configure Cluster Network**
   ```bash
   # Verify both nodes are visible in cluster
   # Access either node's web interface
   # Datacenter > Cluster should show both nodes
   ```

## 🔒 Phase 3: OPNsense Firewall VM Deployment (Enhanced Security)

### Step 3.1: OPNsense VM Creation for NordVPN Distribution
   
   # Enable and start Wazuh Manager
   sudo systemctl daemon-reload
   sudo systemctl enable wazuh-manager
   sudo systemctl start wazuh-manager
   ```

3. **Wazuh Dashboard Installation (Optional - Web UI)**
   ```bash
   # Install Wazuh Dashboard for web management
   sudo apt install wazuh-dashboard -y
   
   # Configure Dashboard
   sudo -u wazuh-dashboard /usr/share/wazuh-dashboard/bin/wazuh-dashboard-keystore create
   sudo -u wazuh-dashboard /usr/share/wazuh-dashboard/bin/wazuh-dashboard-keystore add opensearch.password
   
   # Enable and start Dashboard
   sudo systemctl daemon-reload
   sudo systemctl enable wazuh-dashboard
   sudo systemctl start wazuh-dashboard
   
   # Dashboard will be available at: https://192.168.0.100:443
   ```

## 🔧 Phase 3: OPNsense Firewall VM Deployment (Enhanced Security)

### Step 3B.1: OPNsense VM Creation for NordVPN Distribution

1. **VM Specifications**
   ```yaml
   VM ID: 110
   Name: opnsense-firewall
   OS: OPNsense (FreeBSD-based)
   CPU: 1 core
   RAM: 1GB (minimal for firewall operations)
   Disk: 20GB (sufficient for OS and configs)
   Network: 2x vmbr (WAN and LAN interfaces)
   IP WAN: DHCP from Proxmox host NordVPN
   IP LAN: 10.0.0.1/24 (internal network for VMs/LXCs)
   ```

2. **OPNsense VM Creation via Proxmox Web UI**
   ```bash
   # Deploy on Node #2 (GoingMerry) for better resource distribution
   # Access GoingMerry Proxmox: https://192.168.0.253:8006
   
   # Create VM Steps:
   # 1. Click "Create VM"
   # 2. General: VM ID 110, Name "opnsense-firewall", Node "goingmerry"
   # 3. OS: Select OPNsense-XX.X-OpenSSL-dvd-amd64.iso
   # 4. System: Default settings (UEFI if available)
   # 5. Disks: 20GB disk on local-lvm storage
   # 6. CPU: 1 core, type "host"
   # 7. Memory: 1024MB (1GB)
   # 8. Network: 
   #    - net0: vmbr0 (WAN - connects to Proxmox host NordVPN)
   #    - net1: vmbr1 (LAN - internal secure network)
   # 9. Confirm and Create
   ```

3. **Network Bridge Configuration**
   ```bash
   # On GoingMerry Proxmox host, create internal bridge
   # /etc/network/interfaces - add new bridge
   
   auto vmbr1
   iface vmbr1 inet static
           address 10.0.0.254/24
           bridge-ports none
           bridge-stp off
           bridge-fd 0
           bridge-vlan-aware yes
   
   # Restart networking
   systemctl restart networking
   ```

### Step 3B.2: OPNsense Installation and Configuration

1. **OPNsense Installation**
   ```bash
   # Start VM and access console
   # Follow OPNsense installation wizard:
   # - Install to disk (20GB)
   # - Set root password
   # - Configure interfaces:
   #   - WAN: vtnet0 (DHCP from Proxmox NordVPN)
   #   - LAN: vtnet1 (10.0.0.1/24)
   ```

2. **NordVPN Configuration**
   ```bash
   # Access OPNsense web interface: https://10.0.0.1
   # Default credentials: root / opnsense
   
   # Configure NordVPN:
   # 1. VPN → OpenVPN → Clients
   # 2. Add NordVPN configuration
   # 3. Import NordVPN .ovpn config file
   # 4. Set as default gateway
   # 5. Configure DNS to NordVPN servers
   ```

3. **Firewall Rules and NAT**
   ```bash
   # Configure firewall rules:
   # 1. Allow LAN → WAN traffic via NordVPN
   # 2. Block direct WAN access
   # 3. Allow specific ports for services:
   #    - 22 (SSH) - LAN only
   #    - 443 (HTTPS) - for management interfaces
   #    - 8006 (Proxmox) - LAN only
   
   # Configure NAT:
   # 1. Outbound NAT via NordVPN interface
   # 2. Port forwarding for essential services
   ```

### Step 3B.3: VM/LXC Network Reconfiguration

1. **Update LXC Network Configuration**
   ```bash
   # Update both LXCs to use internal network (Wazuh runs as containers in LXC 101)
   pct set 101 -net0 name=eth0,bridge=vmbr1,ip=10.0.0.251/24,gw=10.0.0.1
   pct set 102 -net0 name=eth0,bridge=vmbr1,ip=10.0.0.252/24,gw=10.0.0.1
   
   # Restart LXCs to apply network changes
   pct restart 101
   pct restart 102
   ```

2. **Update Wazuh Container Configuration**
   ```bash
   # Update Wazuh containers to use internal network (if needed)
   # Containers automatically inherit LXC network configuration
   # Wazuh Manager will be accessible at: 10.0.0.251:55000 (API)
   # Wazuh Dashboard: https://10.0.0.251:443
   # Wazuh Agent connections: 10.0.0.251:1514
   ```

3. **DNS and Service Discovery Update**
   ```bash
   # Update all service configurations to use new IP addresses:
   # - Wazuh Manager (Dockerized): 10.0.0.251:55000 (API), 10.0.0.251:443 (Dashboard)
   # - Node #1 LXC: 10.0.0.251  
   # - Node #2 LXC: 10.0.0.252
   # - OPNsense: 10.0.0.1
   
   # Update Prometheus targets and Wazuh agent configurations
   # All agents now point to 10.0.0.251:1514 for Wazuh Manager
   ```

## �🐳 Phase 4: LXC Container Deployment (Dual Node)

### Step 4.1: Node #1 (ThousandSunny) VM Deployment

1. **Primary Debian VM for Docker Services**
   ```yaml
   VM ID: 101
   Name: debian-docker-main
   Template: Debian 12 (Bookworm)
   CPU: 4 cores
   RAM: 10.5GB
   Disk: 200GB (on local-lvm)
   Network: vmbr0 (bridged)
   Static IP: 192.168.0.251/24
   Features: KVM virtualization, QEMU Guest Agent
   Security: Full VM isolation
   ```

2. **Create and Configure Main VM**
   ```bash
   # On ThousandSunny Proxmox (192.168.0.254)
   # Create VM via web UI or CLI:
   qm create 101 \
     --name debian-docker-main \
     --memory 10752 \
     --cores 4 \
     --net0 virtio,bridge=vmbr0 \
     --virtio0 local-lvm:200 \
     --bootdisk virtio0 \
     --ostype l26 \
     --agent enabled=1 \
     --cpu host
   
   # Import Debian cloud image
   qm importdisk 101 debian-12-generic-amd64.qcow2 local-lvm
   
   # Configure VM
   qm set 101 --scsihw virtio-scsi-pci
   qm set 101 --boot c --bootdisk virtio0
   qm set 101 --serial0 socket --vga serial0
   
   # Start VM
   qm start 101
   ```

3. **Configure Main VM Environment**
   ```bash
   # SSH into the VM (after initial setup)
   ssh sunnylabx@192.168.0.251
   
   # Update system
   sudo apt update && sudo apt upgrade -y
   
   # Install QEMU Guest Agent
   sudo apt install qemu-guest-agent -y
   sudo systemctl enable qemu-guest-agent
   sudo systemctl start qemu-guest-agent
   
   # Install Docker and Docker Compose
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker sunnylabx
   
   # Install Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   
   # Enable Docker service
   sudo systemctl enable docker
   sudo systemctl start docker
   
   # Configure storage mounts
   sudo mkdir -p /mnt/hdd-{1,2,3,4}
   # Add mount points to /etc/fstab for direct storage access
   ```

### Step 4.2: Node #2 (GoingMerry) LXC Deployment

1. **Secondary Ubuntu LXC for Specific Services**
   ```yaml
   CT ID: 102
   Name: ubuntu-docker-secondary
   Template: Ubuntu 22.04 LTS
   CPU: 2 cores
   RAM: 6GB
   Disk: 100GB (on local-lvm)
   Network: vmbr0 (bridged)
   Static IP: 192.168.0.252/24
   Features: nesting=1,keyctl=1 (required for Docker)
   Privileged: true (required for Docker operations)
   ```

2. **Create and Configure Secondary LXC**
   ```bash
   # On GoingMerry Proxmox (192.168.0.253)
   pct create 102 local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
     --hostname debian-docker-secondary \
     --memory 6144 \
     --swap 12800 \
     --cores 2 \
     --rootfs local-lvm:100 \
     --net0 name=eth0,bridge=vmbr0,ip=192.168.0.252/24,gw=192.168.0.1 \
     --features nesting=1,keyctl=1 \
     --unprivileged 0
   
   # Start LXC
   pct start 102
   
   # Configure identical to main LXC (Docker installation)
   pct enter 102
   # ... repeat Docker installation steps from Step 4.1.3
   ```

### Step 4.3: Service Distribution Strategy

1. **Node #1 (ThousandSunny) - 36 Services** *(Optimized from 38)*
   ```bash
   # Media Stack (ThousandSunny services)
   # Development Stack (ThousandSunny services)  
   # Storage-intensive services requiring NFS access
   # Services requiring higher RAM allocation
   ```

2. **Node #2 (GoingMerry) - 13 Services** *(Optimized from 17)*
   ```bash
   # Networking Services (3 services - AdGuard removed)
   # Monitoring Services (6 services - Portainer, Duplicati, Watchtower, Uptime Kuma eliminated)
   # Communication Services (4 services)
   ```

3. **Eliminated Services** *(Liberated 1.75GB RAM)*
   ```bash
   # Removed due to Proxmox native capabilities:
   # - Portainer (replaced by Proxmox web UI)
   # - Duplicati (replaced by Proxmox backup solutions)
   # - Watchtower (replaced by Proxmox update management)
   # - Uptime Kuma (redundant with Proxmox monitoring + Wazuh)
   # - AdGuard Home (networking service eliminated)
   ```

### Step 4.4: Deploy Services on Both Nodes

1. **Clone Repository on Both LXCs**
   ```bash
   # On both Node #1 and Node #2 LXCs
   su - sunnylabx
   git clone https://github.com/BlkLeg/sunnylabx.git
   cd sunnylabx
   ```

2. **Node #1 Service Deployment**
   ```bash
   # SSH to Node #1 LXC
   ssh sunnylabx@192.168.0.251
   cd sunnylabx
   
   # Deploy ThousandSunny services (36 services)
   cd thousandsunny
   
   # Media Services
   docker-compose -f docker-compose-media.yml up -d
   # Note: Jellyfin container exists but remains stopped - only starts when Plex fails
   # This mutual exclusivity saves 1-2GB RAM during normal operation
   
   # Torrent Services  
   docker-compose -f docker-compose-torrent.yml up -d
   
   # Development and other Node #1 specific services
   # (Full deployment commands per existing compose files)
   ```

3. **Node #2 Service Deployment**
   ```bash
   # SSH to Node #2 LXC
   ssh sunnylabx@192.168.0.252
   cd sunnylabx
   
   # Deploy GoingMerry services (13 services)
   cd goingmerry
   
   # Networking Services (3 services - optimized)
   # Note: AdGuard removed, only essential networking
   
   # Monitoring Services (6 services - optimized)
   # Note: Portainer, Duplicati, Watchtower, Uptime Kuma removed
   
   # Communication Services (4 services)
   # (Deployment commands per existing compose files)
   ```
   
   # Management Services (2 services)
   cd ../management
   docker-compose up -d
   
   # Security Services (5 services - Wazuh agents integrated with VM)
   cd ../security
   docker-compose up -d
   
   # Automation Services (1 service)
   cd ../automation
   docker-compose up -d
   
   # Total: 18 Docker services (communication stack eliminated)
   ```

## 📝 Phase 5: Optimized Service Configurations (Post-Elimination)

### Step 5.1: Service Configuration Updates for Dual Proxmox

1. **Media Services Mutual Exclusivity Configuration**
   ```yaml
   # Plex/Jellyfin Resource Optimization
   # docker-compose-media.yml configuration strategy:
   
   services:
     plex:
       # Primary media server - always enabled
       restart: unless-stopped
       
     jellyfin:
       # Backup media server - disabled by default
       restart: "no"  # Only start manually when Plex fails
       profiles:
         - backup    # Use Docker Compose profiles for conditional startup
       
   # Usage:
   # Normal operation: docker-compose up -d (only Plex starts)
   # Plex failure: docker-compose --profile backup up jellyfin -d
   # 
   # Resource Benefit: Saves 1-2GB RAM during normal operation
   # Service count remains 9 but effective resource usage reduced
   ```

2. **Eliminated Services Documentation**
   ```yaml
   # Services removed due to Proxmox native capabilities:
   
   # Management Services (replaced by Proxmox):
   - portainer        # → Proxmox web UI for container management
   - duplicati        # → Proxmox backup solutions (PVE backups)
   - watchtower       # → Proxmox update management
   - uptime-kuma      # → Redundant with Proxmox monitoring + Wazuh
   
   # Networking Services (eliminated):
   - adguard-home     # → Complete removal (reduced networking stack)
   
   # Total RAM Liberation: ~2.75-3.75GB (including Plex/Jellyfin optimization)
   # Service Count Reduction: 62 → 48-50 services
   ```
          memory: 256M
    environment:
      - COLLECTIONS=crowdsecurity/linux crowdsecurity/sshd
      - WAZUH_MANAGER_API=https://192.168.0.100:55000
    # ... configuration

  # Network IDS (Suricata - coordinates with Wazuh)
  suricata:
    image: jasonish/suricata:latest
    container_name: suricata
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.1'
          memory: 256M
    # Forward alerts to Wazuh Manager
    # ... configuration

  # Password manager
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.25'
          memory: 256M
        reservations:
          cpus: '0.05'
          memory: 128M
    # ... configuration

  # Log shipper to Wazuh Manager
  logstash:
    image: docker.elastic.co/logstash/logstash:8.10.0
    container_name: logstash-so
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.1'
          memory: 256M
    environment:
      - WAZUH_MANAGER_HOST=192.168.0.100
    # Forward logs to Wazuh Manager
    # ... configuration

networks:
  security_network:
    driver: bridge
    name: security_network

volumes:
  authentik_data:
  crowdsec_data:
  suricata_logs:
  vaultwarden_data:
  logstash_config:
```

### Step 4.2: Network Services Configuration

**Enhanced: goingmerry/networking/docker-compose-nginx.yml**
```yaml
services:
  nginx-proxy-manager:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx-proxy-manager
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
        reservations:
          cpus: '0.1'
          memory: 128M
    ports:
      - "80:80"
      - "443:443"
      - "81:81"
    volumes:
      - nginx_data:/data
      - nginx_letsencrypt:/etc/letsencrypt
    networks:
      - network_services
    logging:
      driver: syslog
      options:
        syslog-address: "tcp://192.168.0.100:514"
        tag: "nginx-proxy-manager"

  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.1'
          memory: 128M
        reservations:
          cpus: '0.05'
          memory: 64M
    command: tunnel run
    environment:
      - TUNNEL_TOKEN=${CLOUDFLARE_TUNNEL_TOKEN}
    networks:
      - network_services
    logging:
      driver: syslog
      options:
        syslog-address: "tcp://192.168.0.100:514"
        tag: "cloudflared"

networks:
  network_services:
    driver: bridge
    name: network_services

volumes:
  nginx_data:
  nginx_letsencrypt:
```

## 🔧 Phase 6: Ansible Configuration Updates (Dual Proxmox)

### Step 6.1: Updated Inventory for Dual Proxmox Cluster

**Modified: ansible/hosts.ini**
```ini
# SunnyLabX Dual Proxmox Cluster Inventory
# Updated for Node #1 and Node #2 both running Proxmox VE

[all]
# Proxmox cluster nodes
thousandsunny ansible_host=192.168.0.254 ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa
goingmerry ansible_host=192.168.0.253 ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa

# LXC containers
ubuntu-docker-main ansible_host=192.168.0.251 ansible_user=sunnylabx ansible_ssh_private_key_file=~/.ssh/id_rsa
ubuntu-docker-secondary ansible_host=192.168.0.252 ansible_user=sunnylabx ansible_ssh_private_key_file=~/.ssh/id_rsa

[proxmox_cluster]
# Both Proxmox VE nodes in cluster
thousandsunny
goingmerry

[thousandsunny_node]
# Node #1 - Primary services node
thousandsunny

[goingmerry_node]
# Node #2 - Secondary services node
goingmerry

[lxc_containers]
# All LXC containers across both nodes
ubuntu-docker-main
ubuntu-docker-secondary

[docker_hosts]
# Hosts running Docker services in LXCs
ubuntu-docker-main
ubuntu-docker-secondary

[management_cluster]
# Proxmox cluster management
thousandsunny
goingmerry
```

### Step 6.2: Dual Proxmox Cluster Setup Playbook

**New: ansible/proxmox-cluster-setup.yml**
```yaml
---
# Dual Proxmox Cluster Configuration Playbook
# Configures both Proxmox nodes and establishes cluster

- name: Configure Proxmox Cluster (Both Nodes)
  hosts: proxmox_cluster
  become: yes
  gather_facts: yes
  serial: 1  # Configure nodes sequentially
  
  vars:
    cluster_name: "sunnylabx-cluster"
    cluster_network: "192.168.0.0/24"
    
    # Node-specific configurations
    node_configs:
      thousandsunny:
        ip: "192.168.0.254"
        role: "primary"
        storage_type: "hybrid"  # SSD + NFS
        lxc_vmid_start: 101
      goingmerry:
        ip: "192.168.0.253"
        role: "secondary"
        storage_type: "nvme"
        lxc_vmid_start: 102
    
    # VM/LXC configurations
    wazuh_manager_vmid: 100
    ubuntu_main_vmid: 101
    ubuntu_secondary_vmid: 102

  tasks:
    # Proxmox repository setup
    - name: Remove enterprise repositories
      lineinfile:
        path: /etc/apt/sources.list.d/pve-enterprise.list
        regexp: '^deb'
        line: '#deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise'
        state: present

    - name: Add no-subscription repository
      apt_repository:
        repo: "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription"
        filename: pve-no-subscription
        state: present

    - name: Update package cache
      apt:
        update_cache: yes
        upgrade: dist

    # Cluster configuration
    - name: Create cluster on primary node
      command: pvecm create {{ cluster_name }}
      when: inventory_hostname == 'thousandsunny'
      register: cluster_creation
      failed_when: cluster_creation.rc != 0 and 'already exists' not in cluster_creation.stderr

    - name: Join secondary node to cluster
      command: pvecm add {{ hostvars['thousandsunny']['ansible_host'] }}
      when: inventory_hostname == 'goingmerry'
      register: cluster_join
      failed_when: cluster_join.rc != 0 and 'already member' not in cluster_join.stderr

    # Storage configuration
    - name: Configure NFS client on secondary node
      package:
        name: nfs-common
        state: present
      when: inventory_hostname == 'goingmerry'

    - name: Create NFS mount points on secondary node
      file:
        path: "/mnt/HDD{{ item }}"
        state: directory
        mode: '0755'
      loop: [1, 2, 3, 4]
      when: inventory_hostname == 'goingmerry'

    - name: Configure NFS mounts in fstab
      lineinfile:
        path: /etc/fstab
        line: "192.168.0.254:/mnt/hdd-{{ item }} /mnt/HDD{{ item }} nfs defaults,_netdev 0 0"
        state: present
      loop: [1, 2, 3, 4]
      when: inventory_hostname == 'goingmerry'

    - name: Mount NFS shares
      command: mount -a
      when: inventory_hostname == 'goingmerry'
```

### Step 6.3: LXC Container Management Playbook

**New: ansible/lxc-container-setup.yml**
```yaml
---
# LXC Container Creation and Configuration
# Creates optimized containers on both Proxmox nodes

- name: Create and Configure LXC Containers
  hosts: proxmox_cluster
  become: yes
  gather_facts: yes
  
  vars:
    lxc_configs:
      debian-docker-main:
        vmid: 101
        node: thousandsunny
        ip: "192.168.0.251"
        memory: 10240
        swap: 12288
        cores: 4
        disk: 200
        services_count: 39
      debian-docker-secondary:
        vmid: 102
        node: goingmerry
        ip: "192.168.0.252"
        memory: 5120
        swap: 12800
        cores: 2
        disk: 100
        services_count: 9

  tasks:
    - name: Download Ubuntu LXC template
      command: pveam download local debian-12-standard_12.2-1_amd64.tar.zst
      register: template_download
      failed_when: template_download.rc != 0 and 'already exists' not in template_download.stderr

    - name: Create LXC containers
      shell: |
        pct create {{ item.value.vmid }} local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
          --hostname {{ item.key }} \
          --memory {{ item.value.memory }} \
          --swap {{ item.value.swap }} \
          --cores {{ item.value.cores }} \
          --rootfs local-lvm:{{ item.value.disk }} \
          --net0 name=eth0,bridge=vmbr0,ip={{ item.value.ip }}/24,gw=192.168.0.1 \
          --features nesting=1,keyctl=1 \
          --unprivileged 0
      loop: "{{ lxc_configs | dict2items }}"
      when: inventory_hostname == item.value.node
      register: lxc_creation
      failed_when: lxc_creation.rc != 0 and 'already exists' not in lxc_creation.stderr

    - name: Start LXC containers
      command: pct start {{ item.value.vmid }}
      loop: "{{ lxc_configs | dict2items }}"
      when: inventory_hostname == item.value.node
      register: lxc_start
      failed_when: lxc_start.rc != 0 and 'already running' not in lxc_start.stderr
```
    ubuntu_docker_vmid: 101
    
  tasks:
    - name: Update Proxmox packages
      apt:
        update_cache: yes
        upgrade: dist
        
    - name: Install additional Proxmox tools
      apt:
        name:
          - qemu-guest-agent
          - cloud-init
        state: present
        
    - name: Verify Ubuntu Server template exists
      stat:
        path: "/var/lib/vz/template/iso/ubuntu-22.04-server-cloudimg-amd64.img"
      register: ubuntu_template
      
    - name: Fail if Ubuntu template not found
      fail:
        msg: "Ubuntu cloud image not found. Please upload jammy-server-cloudimg-amd64.img to Proxmox storage."
      when: not ubuntu_template.stat.exists
      
    - name: Verify Ubuntu Server ISO exists
      stat:
        path: "/var/lib/vz/template/iso/ubuntu-22.04-server-amd64.iso"
      register: ubuntu_server_iso
      
    - name: Fail if Ubuntu Server ISO not found
      fail:
        msg: "Ubuntu Server ISO not found. Please upload ubuntu-22.04-server-amd64.iso to Proxmox storage."
      when: not ubuntu_server_iso.stat.exists
        
    - name: Create Wazuh Manager VM
      proxmox_kvm:
        api_host: "{{ ansible_host }}"
        api_user: "root@pam"
        api_password: "{{ proxmox_password }}"
        vmid: "{{ wazuh_manager_vmid }}"
        name: "wazuh-manager"
        node: "{{ inventory_hostname }}"
        cores: 2
        memory: 4096
        net:
          net0: "virtio,bridge=vmbr0"
        virtio:
          virtio0: "local-lvm:50"
        ide:
          ide2: "local:iso/ubuntu-22.04-server-amd64.iso,media=cdrom"
        state: present
        
    - name: Create Ubuntu Docker VM
      proxmox_kvm:
        api_host: "{{ ansible_host }}"
        api_user: "root@pam"  
        api_password: "{{ proxmox_password }}"
        vmid: "{{ ubuntu_docker_vmid }}"
        name: "ubuntu-docker"
        node: "{{ inventory_hostname }}"
        cores: 2
        memory: 8192
        net:
          net0: "virtio,bridge=vmbr0"
        virtio:
          virtio0: "local-lvm:300"
        ide:
          ide2: "local:iso/ubuntu-22.04-server-cloudimg-amd64.img,media=cdrom"
        state: present
```

**New: ansible/wazuh-manager-playbook.yml**
```yaml
---
# Wazuh Manager Configuration Playbook
# Configures Wazuh Manager VM for SunnyLabX monitoring

- name: Configure Wazuh Manager VM
  hosts: wazuh-manager
  become: yes
  gather_facts: yes
  
  vars:
    wazuh_admin_email: "admin@thousandsunny.win"
    agent_sources:
      - "192.168.0.253"  # Proxmox host
      - "192.168.0.252"  # Ubuntu LXC
      - "192.168.0.254"  # ThousandSunny
      
  tasks:
    - name: Update Security Onion system
      apt:
        update_cache: yes
        upgrade: dist
        
    - name: Configure Security Onion setup
      template:
        src: security-onion-setup.conf.j2
        dest: /etc/securityonion/setup.conf
        mode: '0600'
        
    - name: Run Security Onion setup
      command: so-setup --accept-salt-minion-key
      args:
        creates: /etc/securityonion/.setup-complete
        
    - name: Configure log collection from homelab nodes
      template:
        src: rsyslog-homelab.conf.j2
        dest: /etc/rsyslog.d/10-homelab.conf
      notify: restart rsyslog
      
    - name: Open firewall for log collection
      ufw:
        rule: allow
        port: '514'
        proto: tcp
        src: '192.168.0.0/24'
        
  handlers:
    - name: restart rsyslog
      service:
        name: rsyslog
        state: restarted
```

## 📊 Phase 7: Monitoring & Verification (Dual Proxmox Cluster)

### Step 7.1: Cluster Status Verification

1. **Proxmox Cluster Health Check**
   ```bash
   # From either Proxmox node, check cluster status
   ssh root@192.168.0.254  # or ssh root@192.168.0.253
   
   # Verify cluster membership
   pvecm status
   
   # Check node status
   pvecm nodes
   
   # Verify cluster network
   pvecm mtunnel
   ```

2. **Service Distribution Verification**
   ```bash
   # Node #1 (ThousandSunny) - 36 services
   ssh sunnylabx@192.168.0.251 "docker ps | wc -l"
   
   # Node #2 (GoingMerry) - 13 services  
   ssh sunnylabx@192.168.0.252 "docker ps | wc -l"
   
   # Wazuh Manager VM
   ssh sunnylabx@192.168.0.100 "systemctl status wazuh-manager wazuh-indexer wazuh-dashboard"
   ```

3. **Web Interface Accessibility**
   - **ThousandSunny Proxmox**: https://192.168.0.254:8006
   - **GoingMerry Proxmox**: https://192.168.0.253:8006
   - **Wazuh Dashboard**: https://192.168.0.100
   - **Services via reverse proxy**: https://your-domain.com (via Traefik)

### Step 7.2: Resource Utilization Monitoring

1. **Proxmox Cluster Resource Overview**
   ```bash
   # Check cluster-wide resource usage
   # Access any Proxmox web UI → Datacenter view
   # Shows combined resources across both nodes
   
   # CLI resource check on both nodes
   for node in 192.168.0.254 192.168.0.253; do
     echo "=== Node $node ==="
     ssh root@$node "pveversion && free -h && df -h /"
   done
   ```

2. **Optimized Resource Allocation Verification**
   ```bash
   # Expected resource distribution:
   # Node #1: 8GB LXC + 4GB Wazuh VM + 2GB Proxmox = 14GB total used of 12GB
   # (Note: Wazuh VM should be on Node #1 for better distribution)
   # Node #2: 6GB LXC + 2GB Proxmox = 8GB total used of 16GB
   
   # Verify actual allocation
   ssh root@192.168.0.254 "pct list && qm list"
   ssh root@192.168.0.253 "pct list && qm list"
   ```

3. **Service Performance Monitoring**
   ```bash
   # Container resource usage on both nodes
   ssh sunnylabx@192.168.0.251 "docker stats --no-stream"
   ssh sunnylabx@192.168.0.252 "docker stats --no-stream"
   
   # Wazuh Manager resource usage
   ssh sunnylabx@192.168.0.100 "htop -n 1"
   ```

## 🔄 Phase 8: Integrated Security & Log Management

### Step 8.1: Monitoring Stack Integration

1. **Prometheus Targets Configuration**
   ```yaml
   # Update Prometheus configuration to include both Proxmox nodes
   # This replaces eliminated Portainer/Uptime Kuma functionality
   
   # /prometheus/prometheus.yml (in monitoring LXC)
   scrape_configs:
     - job_name: 'proxmox-thousandsunny'
       static_configs:
         - targets: ['192.168.0.254:9100']  # node-exporter on Proxmox
     
     - job_name: 'proxmox-goingmerry'
       static_configs:
         - targets: ['192.168.0.253:9100']  # node-exporter on Proxmox
     
     - job_name: 'lxc-containers'
       static_configs:
         - targets: ['192.168.0.251:9100', '192.168.0.252:9100']
   ```

2. **Grafana Dashboard Updates**
   ```bash
   # Import updated dashboards that include:
   # - Proxmox cluster overview (replaces Portainer functionality)
   # - Optimized resource allocation views
   # - Service health monitoring (replaces Uptime Kuma)
   ```

3. **Network Monitoring**
   ```bash
   # Configure network monitoring
   # Monitor traffic between:
   # - Proxmox host <-> VMs
   # - GoingMerry <-> ThousandSunny
   # - Internal Docker networks
   # - External internet traffic
   ```

4. **Alerting Configuration**
   Configure alerts for:
   - Failed SSH attempts
   - Unusual network traffic
   - Container anomalies
   - Resource exhaustion
   - Service failures

## 🛠️ Troubleshooting & Maintenance

### Common Issues

1. **VM Network Connectivity**
   ```bash
   # Check bridge configuration
   ip addr show vmbr0
   
   # Verify VM network settings
   pvesh get /nodes/goingmerry/qemu/101/config
   ```

2. **Resource Constraints**
   ```bash
   # Monitor Proxmox resource usage
   pvesh get /nodes/goingmerry/status
   
   # Adjust VM resources if needed
   pvesh set /nodes/goingmerry/qemu/101 -memory 6144
   ```

3. **Security Onion Issues**
   ```bash
   # Check Security Onion services
   ssh admin@192.168.0.100 "sudo so-status"
   
   # Restart services if needed
   ssh admin@192.168.0.100 "sudo so-restart"
   ```

### Backup Strategy

1. **VM Snapshots**
   ```bash
   # Create VM snapshots before changes
   pvesh create /nodes/goingmerry/qemu/101/snapshot -snapname pre-update
   ```

2. **Docker Volume Backups**
   ```bash
   # Backup Docker volumes from Ubuntu VM
   ssh shawnji@192.168.0.252 "docker run --rm -v nginx_data:/data -v $(pwd):/backup ubuntu tar czf /backup/nginx_backup.tar.gz /data"
   ```

## 📋 Dual Proxmox Cluster Resource Summary (Debian)

### Node #1 (ThousandSunny) - Proxmox VE + Debian VM - 12GB RAM, 4 CPU cores, 12GB SWAP
```
Optimized Proxmox Deployment:
├── Proxmox Host: 1.5GB RAM, 0.5 CPU cores
├── Debian Docker VM: 8GB RAM (12GB SWAP), 3.5 CPU cores (19 services)
│   └── Note: Additional 0.5GB overhead for VM vs LXC
├── Available for expansion: 2.5GB RAM, 0 CPU cores + SWAP buffer
└── Utilization: 79% RAM (accounts for VM overhead), 87.5% CPU (maintained efficiency)
```

### Node #2 (GoingMerry) - Proxmox VE + Debian LXC - 16GB RAM, 4 CPU cores, 13GB SWAP
```
Enhanced Security Proxmox Deployment (Communication Stack Eliminated):
├── Proxmox Host: 2GB RAM, 0.5 CPU cores  
├── OPNsense Firewall VM: 1GB RAM, 0.5 CPU cores (NordVPN distribution)
├── Debian Docker LXC: 5GB RAM (13GB SWAP), 2 CPU cores (9 services - communication eliminated)
├── Available for expansion: 8GB RAM, 1 CPU core + SWAP buffer
└── Utilization: 50% RAM, 75% CPU (excellent headroom + 1GB saved from communication elimination)
```

### Optimized Service Distribution (46+ Services Total)

#### Node #1 (ThousandSunny) - 19 Services in VM
```
Storage & Media-Intensive Workloads:
├── Media Services (4): Plex OR Jellyfin (backup), Radarr, Immich
│   └── Benefits: NFS access to 4x4TB HDDs, optimized storage I/O
│   └── Note: Jellyfin only runs when Plex is down (mutual exclusivity saves ~1-2GB RAM)
├── Infrastructure (13): PostgreSQL, Redis, Gitea, Nextcloud, DevOps tools  
│   └── Benefits: High-performance storage, database optimization
├── Torrent/Download (1): Deluge
│   └── Benefits: Direct storage access for downloads
├── Development (1): Git services
│   └── Benefits: Local development environment
├── Security Benefits:
│   └── Full VM isolation for enhanced security
│   └── QEMU Guest Agent for better integration
│   └── Snapshot support with memory state
└── Total: 19 services (streamlined resource efficiency)
```

#### Node #2 (GoingMerry) - 9 Services in LXC (Streamlined)
```
Network & Management Workloads:
├── Network Services (2): Nginx Proxy, Cloudflare DDNS
├── Monitoring (6): Prometheus, Grafana, Loki, Promtail, AlertManager, Node-Exporter
├── Automation (1): n8n workflow automation
└── Total: 9 services (streamlined efficiency)
```

#### Dockerized Wazuh SIEM Stack (Node #1 LXC)
```
Containerized Security Monitoring Platform:
├── Wazuh Manager: SIEM, log analysis, threat detection (Docker)
├── Wazuh Indexer: Search and data storage (Docker, Elasticsearch replacement)
├── Wazuh Dashboard: Web interface and visualization (Docker, Kibana replacement)
├── Resource Efficiency: 4.6GB RAM within existing LXC (no VM overhead)
└── Benefit: Better containerization practice, improved resource utilization
```

#### Dedicated OPNsense Firewall VM (Node #2)
```
Enhanced Network Security Platform:
├── OPNsense Firewall: Advanced firewall and routing
├── NordVPN Integration: VPN client for all VM/LXC traffic
├── NAT & Port Forwarding: Secure external access
├── DNS Filtering: Enterprise-grade DNS security
├── Network Segmentation: Isolated internal network (10.0.0.0/24)
└── Resource: 1GB RAM, 0.5 CPU cores (minimal overhead for maximum security)
```

### Service Elimination Benefits (1.75GB RAM Liberation)

#### Management Services Eliminated (Replaced by Proxmox Native):
- **Portainer**: ❌ → ✅ Proxmox container management UI
- **Duplicati**: ❌ → ✅ Proxmox backup solutions (vzdump, PBS)
- **Watchtower**: ❌ → ✅ Proxmox update management
- **Uptime Kuma**: ❌ → ✅ Proxmox monitoring + Wazuh alerting

#### Network Services Optimized:
- **AdGuard Home**: ❌ Completely eliminated (DNS filtering via router/upstream)

#### Resource Liberation Impact:
- **Total RAM Freed**: ~1.75GB across both nodes
- **Service Count**: 62 → 48-50 services (19-23% reduction)
- **Management Overhead**: Eliminated redundant monitoring/management stack

## 🎯 Dual Proxmox Architecture Advantages

### 1. **Unified Management Platform**
```
Benefits:
├── Single interface for both nodes (cluster view)
├── Centralized backup and restore operations
├── Live migration capabilities between nodes
├── Template management for rapid deployment
└── Resource allocation flexibility
```

### 2. **Enhanced Security Posture**
```
Security Improvements:
├── VM/LXC isolation vs direct container access
├── Snapshot-based security (rollback capabilities)
├── Network segmentation between VMs/LXCs
└── Integrated monitoring across infrastructure
```

### 3. **Operational Efficiency**
```
Management Benefits:
├── Eliminated duplicate management services
├── Native backup solutions replace Duplicati
├── Integrated monitoring replaces separate stack
├── Automated update management
└── Professional virtualization management
```

### 4. **Resource Optimization**
```
Resource Benefits:
├── Better resource allocation control
├── Dynamic resource adjustment
├── Elimination of management service overhead
├── More efficient use of available hardware
└── Improved performance isolation
```

## 🏁 Implementation Summary (Debian + Streamlined Services Edition)

### **Why Dual Proxmox vs Hybrid Approach?**

**Original Hybrid Issues**:
- ❌ **Management Complexity**: Two different management paradigms
- ❌ **Service Duplication**: Portainer, Uptime Kuma, Duplicati redundancy
- ❌ **Resource Waste**: 1.75GB in management overhead
- ❌ **Communication Overkill**: Matrix, Discord, SMTP services rarely used
- ❌ **Backup Inconsistency**: Different backup strategies per node
- ❌ **Security Gaps**: No unified VPN distribution or advanced firewall

**Dual Proxmox + Debian Solutions**:
- ✅ **Unified Management**: Single Proxmox cluster interface
- ✅ **Service Consolidation**: Native Proxmox capabilities eliminate redundancy
- ✅ **Resource Efficiency**: 6.75GB freed (5.75GB + 1GB communication elimination)
- ✅ **Debian Stability**: More stable and lightweight than Ubuntu for containers
- ✅ **Professional Operations**: Enterprise-grade virtualization management
- ✅ **Enhanced Security**: Dockerized Wazuh SIEM + OPNsense VM with NordVPN distribution
- ✅ **Streamlined Services**: Communication stack eliminated (overkill removed)
- ✅ **SWAP Buffer**: 25GB SWAP across both nodes for memory stability
- ✅ **Containerization Excellence**: Wazuh moved from VM to Docker for better practice
- ✅ **Scalability**: Easy addition of new nodes to cluster

### **Final Architecture: Production-Ready Secure Homelab with Enhanced Containerization**
- **48-50 optimized services**
- **Dual Proxmox cluster** with unified management
- **Advanced network security** (OPNsense VM with NordVPN)
- **Enhanced memory management** (25GB SWAP total)
- **Efficient resource utilization** across both nodes
- **Professional backup and monitoring** capabilities
- **1.75GB RAM liberation** for application workloads  
✅ **Security Benefits**: Process isolation + VPN distribution + advanced firewall  
✅ **Future Flexibility**: Easy to adjust resources, add containers  
✅ **Backup Strategy**: Built-in LXC snapshots and templates  
✅ **Network Security**: All traffic routed through NordVPN tunnel

**Why Not VMs for Everything**:
❌ **Resource Waste**: 1-2GB overhead per VM too expensive  
❌ **Performance Penalty**: Unnecessary for containerized workloads  
❌ **Complexity**: Extra management layer without significant benefits  
✅ **Strategic VM Use**: Only for specialized services (OPNsense firewall)  

## 🚀 Migration Path (Enhanced)

### Phase 1: Prepare Node #2 (GoingMerry)
1. **Backup existing services** from GoingMerry
2. **Install Proxmox VE** (fresh installation recommended)
3. **Deploy OPNsense VM** with NordVPN configuration
4. **Create Debian LXC containers** with proper resource allocation and SWAP
5. **Migrate essential services** (eliminate communication stack overkill)

### Phase 2: Optimize Node #1 (ThousandSunny)  
1. **System tuning** for increased container density
2. **Deploy Debian LXC** with Dockerized Wazuh SIEM stack
3. **Resource limit implementation** across all services
4. **Storage optimization** for media and database workloads
5. **SWAP configuration** for memory stability
6. **Monitoring setup** for resource usage tracking

### Phase 3: Security Integration & Testing
1. **Wazuh Manager deployment** and agent installation
2. **OPNsense network reconfiguration** for all VMs/LXCs
3. **NordVPN tunnel verification** and failover testing
4. **Inter-node communication** verification through secure network
5. **NFS mount** optimization between nodes
6. **Comprehensive testing** of all service interactions

## 🎊 Benefits of Enhanced Dual Proxmox Route

### Enhanced Security Capabilities
- **Enterprise Virtualization**: Professional VM/LXC management on both nodes
- **Dedicated Security Monitoring**: Wazuh Manager SIEM with full network analysis
- **Advanced Network Security**: OPNsense firewall with NordVPN distribution
- **Network Isolation**: Internal 10.0.0.0/24 network for all services
- **Resource Optimization**: Direct deployment where needed, virtualization where beneficial
- **Operational Excellence**: Best practices for backup, monitoring, and maintenance
- **Memory Stability**: 25GB SWAP ensures stable operation under high load

### Maintained Performance  
- **Media Performance**: Direct hardware access on Node #1 for transcoding
- **Storage Performance**: No virtualization overhead for 9TB media storage
- **Network Performance**: Optimized routing through OPNsense firewall
- **Security Performance**: Minimal overhead from OPNsense VM (1GB RAM)

### Future-Proofing
- **Scalability**: Easy to add new LXC containers on Node #2
- **Testing**: Safe isolated environments for new services
- **Backup Strategy**: Professional-grade backup and recovery procedures
- **Upgrade Path**: Foundation for future hardware upgrades

This hybrid Proxmox route provides the optimal balance of performance, resource utilization, and management capabilities tailored specifically to your SunnyLabX hardware constraints and service requirements.