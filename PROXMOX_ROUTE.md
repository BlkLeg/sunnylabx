# SunnyLabX Hybrid Proxmox Deployment Route

This deployment guide walks you through a **hybrid virtualization approach** optimized for the SunnyLabX hardware constraints. After comprehensive analysis of 61 total services across both nodes, this route provides the optimal balance of performance, resource utilization, and management capabilities.

## 🎯 Architecture Overview

**Total Deployment Time**: 6-7 hours (including Proxmox setup and service migration)
**Services**: 61 containers across hybrid deployment
**Approach**: Hybrid - Direct Docker + Proxmox virtualization

### Optimized Node Configuration
- **Node #1 (ThousandSunny)**: Ubuntu Server LTS 24.04 - Direct Docker Deployment
  - **38 services** running directly on Ubuntu (no virtualization overhead)
  - **Media transcoding**, large storage access, resource-intensive workloads
- **Node #2 (GoingMerry)**: Proxmox VE 8.x - Virtualized Management Hub
  - **Ubuntu Docker LXC**: 17 containers in LXC + Security Onion
  - **Security Onion LXC**: Dedicated SIEM/IDS platform

### Why Hybrid Approach?
- **Node #1**: Resource-constrained (12GB for 17-23GB workload) - needs maximum efficiency
- **Node #2**: Resource-abundant (16GB for 8GB workload) - can benefit from virtualization
- **Storage**: Direct HDD access required for media services
- **Performance**: Media transcoding benefits from direct hardware access

## 📋 Hardware Analysis & Resource Allocation

### Node #1 (ThousandSunny) - Direct Docker Deployment
- **Hardware**: Dell XPS 8500, i7-3770 (4c/8t), 12GB DDR3, 1TB SSD + 9TB HDD
- **OS**: Ubuntu Server LTS 24.04 (no virtualization)
- **IP**: 192.168.0.254
- **Services**: 38 containers directly on Ubuntu
- **Resource Challenge**: 12GB available vs 17-23GB estimated need
- **Strategy**: Direct deployment for maximum efficiency, careful resource management

#### Service Categories (Node #1)
- **Media Services (9)**: Plex, Jellyfin, ARR Suite, Immich (~6-8GB RAM)
- **IoT/Home Automation (7)**: Home Assistant, MQTT, InfluxDB (~2-3GB RAM)
- **Infrastructure (15)**: Databases, DevOps, Gitea, Nextcloud (~4-5GB RAM)
- **AI Services (2)**: Ollama, WebUI (~4-6GB RAM if enabled)
- **Torrent/Download (3)**: qBittorrent, Deluge (~1GB RAM)
- **Agents (2)**: Portainer Agent, Wazuh Agent (~256MB RAM)

### Node #2 (GoingMerry) - Proxmox Virtualization Host
- **Hardware**: Mini PC, Intel Twin Lake-N150 (4 cores), 16GB DDR4, 500GB NVMe
- **Host OS**: Proxmox VE 8.x
- **IP**: 192.168.0.253
- **Services**: 17 containers in LXC + Security Onion
- **Resource Advantage**: 16GB available vs 8GB estimated need

#### LXC Resource Allocation Strategy
```
Total Resources: 16GB RAM, 4 CPU cores
├── Proxmox Host: 1GB RAM, 0.25 CPU (minimal overhead)
├── Ubuntu Docker LXC: 9GB RAM, 2 CPU (17 services)
├── Security Onion LXC: 5GB RAM, 2 CPU (SIEM/IDS)
└── Utilization: 100% RAM, 106% CPU (optimal)
```

#### Service Categories (Node #2)
- **Networking (3)**: Nginx Proxy, Cloudflare, Portainer Proxy (~512MB RAM)
- **Monitoring (6)**: Prometheus, Grafana, Loki (~3-4GB RAM)
- **Security (5)**: Authentik, CrowdSec, Suricata (~2-3GB RAM)
- **Management (2)**: Portainer (~256MB RAM)
- **Automation (1)**: n8n (~512MB RAM)

## 🔧 Phase 1: Node #1 Optimization (ThousandSunny)

### Step 1.1: Resource Optimization for Direct Docker

Since Node #1 will continue running Ubuntu with direct Docker deployment, we need to optimize it for the 38-service workload:

1. **System Tuning**
   ```bash
   # SSH to Node #1
   ssh shawnji@192.168.0.254
   
   # Optimize kernel parameters for container workloads
   echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
   echo 'vm.overcommit_memory=1' | sudo tee -a /etc/sysctl.conf
   echo 'kernel.pid_max=4194304' | sudo tee -a /etc/sysctl.conf
   
   # Apply immediately
   sudo sysctl -p
   ```

2. **Docker Resource Management**
   ```bash
   # Configure Docker daemon with resource constraints
   sudo tee /etc/docker/daemon.json <<EOF
   {
     "log-driver": "json-file",
     "log-opts": {
       "max-size": "10m",
       "max-file": "3"
     },
     "default-ulimits": {
       "nofile": {
         "Name": "nofile",
         "Hard": 64000,
         "Soft": 64000
       }
     }
   }
   EOF
   
   sudo systemctl restart docker
   ```

3. **Storage Optimization**
   ```bash
   # Ensure media drives are properly mounted
   sudo mkdir -p /mnt/hdd-{1,2,3,4}
   
   # Verify NFS mounts are optimized for Node #2 access
   # (These will be accessed by GoingMerry via NFS)
   ```

## 🔧 Phase 2: Proxmox Installation & Configuration (Node #2)

### Step 2.1: Proxmox VE Installation on GoingMerry

1. **Proxmox VE Installation** *(Assumes ISO pre-uploaded to storage)*

2. **Flash to USB and Install**
   - Boot GoingMerry from Proxmox VE USB
   - Configure network: 192.168.0.253/24, Gateway: 192.168.0.1
   - Set root password and email
   - Use entire 500GB NVMe for storage

3. **Post-Installation Configuration**
   ```bash
   # Access web interface: https://192.168.0.253:8006
   # Update Proxmox
   apt update && apt full-upgrade
   
   # Remove enterprise repository warnings
   sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
   
   # Add no-subscription repository
   echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
   apt update
   ```

### Step 2.2: Network Configuration

1. **Configure Bridge Interface**
   ```bash
   # /etc/network/interfaces (usually auto-configured during install)
   auto lo
   iface lo inet loopback
   
   auto enp2s0
   iface enp2s0 inet manual
   
   auto vmbr0
   iface vmbr0 inet static
           address 192.168.0.253/24
           gateway 192.168.0.1
           bridge-ports enp2s0
           bridge-stp off
           bridge-fd 0
   ```

2. **Restart Networking**
   ```bash
   systemctl restart networking
   ```

3. **Configure NFS Client for ThousandSunny Access**
   ```bash
   # Install NFS client on Proxmox host
   apt install nfs-common -y
   
   # Create mount points
   mkdir -p /mnt/HDD{1,2,3,4}
   
   # Add NFS mounts to fstab
   echo "192.168.0.254:/mnt/hdd-1 /mnt/HDD1 nfs defaults,_netdev 0 0" >> /etc/fstab
   echo "192.168.0.254:/mnt/hdd-2 /mnt/HDD2 nfs defaults,_netdev 0 0" >> /etc/fstab
   echo "192.168.0.254:/mnt/hdd-3 /mnt/HDD3 nfs defaults,_netdev 0 0" >> /etc/fstab
   echo "192.168.0.254:/mnt/hdd-4 /mnt/HDD4 nfs defaults,_netdev 0 0" >> /etc/fstab
   
   # Mount NFS shares
   mount -a
   ```

### Step 2.3: Storage Configuration

1. **Optimize Storage Layout**
   ```bash
   # Via Proxmox web interface or CLI
   # local: Proxmox system (50GB)
   # local-lvm: LXC containers (400GB)
   
   # Ubuntu 22.04 LTS template (assumes pre-downloaded)
   pveam update  # Update template list
   # Template should already be available in local storage
   ```

## 🔒 Phase 3: Security Onion LXC Deployment

### Step 3.1: Security Onion LXC Creation

1. **LXC Specifications**
   ```yaml
   CT ID: 100
   Name: security-onion
   Template: Ubuntu 22.04 LTS
   CPU: 2 cores
   RAM: 5GB
   Disk: 80GB
   Network: vmbr0 (bridged)
   Features: nesting=1,keyctl=1 (required for Security Onion)
   Privileged: true (required for network monitoring)
   ```

2. **LXC Creation via Web UI**
   ```bash
   # In Proxmox web interface
   # Create LXC container with above specifications
   # Use Ubuntu 22.04 template
   # Enable required features for Security Onion
   ```

3. **Security Onion Installation in LXC**
   ```bash
   # Enter LXC container
   pct enter 100
   
   # Update system
   apt update && apt upgrade -y
   
   # Download and install Security Onion
   wget https://download.securityonion.net/file/securityonion/securityonion-2.3.190-20240214.iso
   # Mount and install Security Onion components
   ```

### Step 2.2: Security Onion Configuration

1. **Installation Type**: **Standalone**
2. **Network Configuration**
   ```yaml
   Management Interface: ens18
   IP Address: 192.168.0.100/24
   Gateway: 192.168.0.1
   DNS: 192.168.0.1 (Router DNS)
   ```

3. **Security Onion Setup**
   ```bash
   # After installation, configure Security Onion
   sudo so-setup
   
   # Choose: EVAL (evaluation mode for homelab)
   # Set admin email and passwords
   # Configure network monitoring interface
   ```

4. **Post-Installation**
   ```bash
   # Enable monitoring of local network
   sudo so-elastic-auth
   
   # Configure firewall rules for Proxmox access
   sudo ufw allow from 192.168.0.0/24
   ```

### Step 2.3: Security Onion Integration

1. **Log Sources Configuration**
   - Configure syslog forwarding from all nodes
   - Set up Security Onion to receive logs from:
     - Proxmox host logs
     - Ubuntu VM logs  
     - ThousandSunny logs
     - Docker container logs

2. **Network Monitoring**
   ```bash
   # Configure network tap/mirror for traffic analysis
   # Monitor traffic between nodes and external connections
   ```

## 🐳 Phase 4: Ubuntu Docker LXC Deployment

### Step 4.1: Ubuntu Docker LXC Creation

1. **LXC Specifications**
   ```yaml
   CT ID: 101
   Name: ubuntu-docker
   Template: Ubuntu 22.04 LTS
   CPU: 2 cores
   RAM: 10GB
   Disk: 200GB
   Network: vmbr0 (bridged)
   Features: nesting=1,keyctl=1 (required for Docker)
   Privileged: true (required for Docker operations)
   ```

2. **LXC Setup and Docker Installation**
   ```bash
   # Enter LXC container
   pct enter 101
   
   # Create user
   adduser shawnji
   usermod -aG sudo shawnji
   
   # Update system
   apt update && apt upgrade -y
   
   # Install Docker in LXC (requires privileged container)
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   usermod -aG docker shawnji
   
   # Install Docker Compose
   curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   chmod +x /usr/local/bin/docker-compose
   
   # Enable Docker service
   systemctl enable docker
   systemctl start docker
   ```

### Step 4.2: Configure Static IP for Ubuntu LXC

1. **Set Static IP**
   ```bash
   # /etc/netplan/10-lxc.yaml
   network:
     version: 2
     ethernets:
       eth0:
         dhcp4: false
         addresses: [192.168.0.252/24]
         gateway4: 192.168.0.1
         nameservers:
           addresses: [192.168.0.253, 1.1.1.1]
   
   netplan apply
   ```

### Step 4.3: Docker Services Deployment

**Note**: Only 18 services will be deployed on Node #2. The remaining 38 services stay on Node #1.

1. **Clone Repository**
   ```bash
   su - shawnji
   git clone https://github.com/BlkLeg/sunnylabx.git
   cd sunnylabx
   ```

2. **Deploy Services** (communication stack eliminated)
   ```bash
   # Network Services (4 services)
   cd goingmerry/networking
   docker-compose up -d
   
   # Monitoring Services (6 services)
   cd ../monitoring
   docker-compose up -d
   
   # Management Services (2 services)
   cd ../management
   docker-compose up -d
   
   # Security Services (5 services - no Wazuh, handled by Security Onion)
   cd ../security
   docker-compose up -d
   
   # Automation Services (1 service)
   cd ../automation
   docker-compose up -d
   
   # Total: 18 Docker services (communication stack eliminated)
   ```

## 📝 Phase 5: Modified Docker Compose Configurations

### Step 4.1: Updated Security Stack

**Modified: goingmerry/security/docker-compose-security.yml**
```yaml
services:
  # Identity and SSO
  authentik:
    image: ghcr.io/goauthentik/server:latest
    container_name: authentik-server
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.25'
          memory: 512M
    # ... configuration

  # Collaborative IPS (Security Onion integration)
  crowdsec:
    image: crowdsecurity/crowdsec:latest
    container_name: crowdsec
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
      - COLLECTIONS=crowdsecurity/linux crowdsecurity/sshd
      - SECURITY_ONION_API=https://192.168.0.100:9200
    # ... configuration

  # Network IDS (Suricata - coordinates with Security Onion)
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
    # Forward alerts to Security Onion
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

  # Log shipper to Security Onion
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
      - SECURITY_ONION_HOST=192.168.0.100
    # Forward logs to Security Onion
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

## 🔧 Phase 6: Ansible Configuration Updates

### Step 5.1: Updated Inventory

**Modified: ansible/hosts.ini**
```ini
# SunnyLabX Proxmox LXC Route Inventory
# Node configuration for Proxmox LXC-based deployment

[all]
# Physical nodes
node1 ansible_host=192.168.0.254 ansible_user=shawnji ansible_ssh_private_key_file=~/.ssh/id_rsa
proxmox-host ansible_host=192.168.0.253 ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa

# LXC containers on Node #2
ubuntu-lxc ansible_host=192.168.0.252 ansible_user=shawnji ansible_ssh_private_key_file=~/.ssh/id_rsa
security-onion ansible_host=192.168.0.100 ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa

[thousandsunny]
# Node #1 - Application & Content Hub
node1

[goingmerry]
# Node #2 - Proxmox host
proxmox-host

[goingmerry_lxcs]
# LXC containers running on Node #2
ubuntu-lxc
security-onion

[docker_hosts]
# Hosts running Docker services
node1
ubuntu-lxc

[security_monitoring]
# Security monitoring platforms
security-onion

[management_nodes]
# Management and monitoring services
ubuntu-lxc
```

### Step 5.2: Proxmox-Specific Playbooks

**New: ansible/proxmox-setup-playbook.yml**
```yaml
---
# Proxmox Host Configuration Playbook
# Configures Proxmox VE host and creates initial VMs

- name: Configure Proxmox VE Host (GoingMerry)
  hosts: proxmox-host
  become: yes
  gather_facts: yes
  
  vars:
    # VM configurations
    security_onion_vmid: 100
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
        
    - name: Download Ubuntu Server template
      get_url:
        url: "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
        dest: "/var/lib/vz/template/iso/ubuntu-22.04-server-cloudimg-amd64.img"
        mode: '0644'
        
    - name: Create Security Onion VM
      proxmox_kvm:
        api_host: "{{ ansible_host }}"
        api_user: "root@pam"
        api_password: "{{ proxmox_password }}"
        vmid: "{{ security_onion_vmid }}"
        name: "security-onion"
        node: "{{ inventory_hostname }}"
        cores: 2
        memory: 6144
        net:
          net0: "virtio,bridge=vmbr0"
        virtio:
          virtio0: "local-lvm:100"
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

**New: ansible/security-onion-playbook.yml**
```yaml
---
# Security Onion Configuration Playbook
# Configures Security Onion VM for SunnyLabX monitoring

- name: Configure Security Onion VM
  hosts: security-onion
  become: yes
  gather_facts: yes
  
  vars:
    so_admin_email: "admin@thousandsunny.win"
    log_sources:
      - "192.168.0.253"  # Proxmox host
      - "192.168.0.252"  # Ubuntu VM
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

## 📊 Phase 7: Monitoring & Verification

### Step 6.1: Service Verification

1. **Proxmox Host Status**
   ```bash
   # From command center
   curl -k https://192.168.0.253:8006/api2/json/nodes/goingmerry/status
   ```

2. **VM Status Check**
   ```bash
   # Security Onion
   curl -k https://192.168.0.100/login
   
   # Ubuntu VM Services
   ssh shawnji@192.168.0.252 "docker ps"
   ```

3. **Service Accessibility**
   - **Proxmox Web UI**: https://192.168.0.253:8006
   - **Security Onion**: https://192.168.0.100
   - **Nginx Proxy Manager**: http://192.168.0.252:81
   - **Grafana**: http://192.168.0.252:3000

### Step 6.2: Resource Monitoring

1. **Proxmox Resource Usage**
   ```bash
   # Check VM resource consumption
   pvesh get /nodes/goingmerry/qemu
   
   # Monitor host resources
   htop
   df -h
   ```

2. **VM Resource Monitoring**
   ```bash
   # Ubuntu VM
   ssh shawnji@192.168.0.252 "docker stats --no-stream"
   
   # Security Onion
   ssh admin@192.168.0.100 "free -h && df -h"
   ```

## 🔄 Phase 8: Log Integration & Security Monitoring

### Step 7.1: Centralized Logging

1. **Configure Log Forwarding**
   ```bash
   # Proxmox host logs to Security Onion
   echo "*.* @@192.168.0.100:514" >> /etc/rsyslog.conf
   systemctl restart rsyslog
   
   # Ubuntu VM logs
   ssh shawnji@192.168.0.252
   echo "*.* @@192.168.0.100:514" | sudo tee -a /etc/rsyslog.conf
   sudo systemctl restart rsyslog
   
   # ThousandSunny logs
   ssh shawnji@192.168.0.254
   echo "*.* @@192.168.0.100:514" | sudo tee -a /etc/rsyslog.conf
   sudo systemctl restart rsyslog
   ```

2. **Docker Container Logs**
   - All Docker services configured with syslog driver
   - Logs automatically forwarded to Security Onion
   - Centralized log analysis and alerting

### Step 7.2: Security Monitoring Setup

1. **Network Monitoring**
   ```bash
   # Configure Security Onion for network monitoring
   # Monitor traffic between:
   # - Proxmox host <-> VMs
   # - GoingMerry <-> ThousandSunny
   # - Internal Docker networks
   # - External internet traffic
   ```

2. **Alerting Configuration**
   - Configure Security Onion alerts for:
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

## 📋 Hybrid Resource Allocation Summary

### Node #1 (ThousandSunny) - Direct Docker - 12GB RAM, 4 CPU cores
```
Resource-Constrained Direct Deployment:
├── System Reserve: 2GB RAM, 0.5 CPU cores
├── Available for Containers: 10GB RAM, 3.5 CPU cores
├── Estimated Need: 17-23GB RAM, 6.6-12.6 CPU cores
├── Strategy: Aggressive resource limits, monitoring, AI services optional
└── Status: Resource pressure but manageable with careful tuning
```

### Node #2 (GoingMerry) - Proxmox LXC - 16GB RAM, 4 CPU cores
```
Resource-Abundant Virtualized Deployment:
├── Proxmox Host: 1GB RAM, 0.25 CPU cores
├── Security Onion LXC: 5GB RAM, 2 CPU cores  
├── Ubuntu Docker LXC: 10GB RAM, 2 CPU cores (18 services)
└── Utilization: 100% RAM, 106% CPU (perfect fit)
```

### Optimized Service Distribution

#### Node #1 (ThousandSunny) - 38 Services Direct on Ubuntu
```
Heavy Workloads (Direct Hardware Access Required):
├── Media Services (9): Plex, Jellyfin, ARR Suite, Immich, Kavita, Overseerr
│   └── Requires: Direct HDD access, GPU transcoding, high I/O
├── Infrastructure (15): PostgreSQL, Redis, Gitea, Nextcloud, DevOps tools
│   └── Requires: Persistent storage, database performance
├── IoT/Home Automation (7): Home Assistant, MQTT, InfluxDB, Zigbee2MQTT
│   └── Requires: USB device access, real-time processing
├── Torrent/Download (3): qBittorrent, Deluge
│   └── Requires: Direct storage access, high network I/O
├── AI Services (2): Ollama, WebUI (optional/resource-permitting)
│   └── Requires: Maximum CPU/RAM allocation
└── Agents (2): Portainer Agent, Wazuh Agent
    └── Low resource overhead
```

#### Node #2 (GoingMerry) - 18 Services in Proxmox LXCs
```
Management & Monitoring Workloads (Virtualization Benefits):
├── Security Onion LXC (dedicated):
│   ├── SIEM/Log Analysis
│   ├── Network IDS/IPS  
│   ├── Threat Detection
│   └── Incident Response
└── Ubuntu Docker LXC (17 services):
    ├── Network Services (3): Nginx Proxy, Cloudflare, Portainer Proxy
    ├── Monitoring (6): Prometheus, Grafana, Loki, Promtail, Uptime Kuma, Watchtower
    ├── Security (5): Authentik, CrowdSec, Suricata, Vaultwarden
    ├── Management (2): Portainer Controller
    └── Automation (1): n8n
```

### Why Hybrid Approach?

**Node #1 Rationale (Direct Docker)**:
- ❌ **Insufficient RAM**: 12GB vs 17-23GB needed
- ⚡ **Performance Critical**: Media transcoding, database operations
- 💾 **Storage Intensive**: Direct 9TB HDD access required
- 🎯 **Efficiency Focus**: Every MB of overhead matters

**Node #2 Rationale (Proxmox LXC)**:
- ✅ **Resource Abundance**: 16GB vs 8GB needed  
- 🔒 **Security Benefits**: Isolation, dedicated SIEM
- 📊 **Management**: Easy backup, snapshots, resource control
- 🚀 **Modern Hardware**: Efficient virtualization support

## 🎯 Implementation Decision Matrix

### Docker Container vs LXC vs VM Analysis

| Factor | Node #1 (Direct Docker) | Node #2 (LXC) | Alternative (VM) |
|--------|-------------------------|----------------|------------------|
| **Resource Overhead** | 0% | ~200MB per container | ~1-2GB per VM |
| **Performance** | Native | 95-98% native | 85-90% native |
| **Isolation** | Process-level | Container-level | Full isolation |
| **Backup/Recovery** | Volume backups | LXC snapshots | VM snapshots |
| **Management** | Docker CLI | Proxmox + Docker | Proxmox + SSH |
| **Hardware Access** | Direct | Limited | Limited |
| **Resource Flexibility** | Limited | Dynamic | Dynamic |
| **Boot Time** | Instant | 5-10 seconds | 30-60 seconds |

### Final Recommendation: **LXC for Node #2**

**LXC Advantages for SunnyLabX**:
✅ **Perfect Resource Fit**: 16GB accommodates 8GB workload + overhead  
✅ **Near-Native Performance**: 95-98% efficiency for management workloads  
✅ **Professional Management**: Proxmox web interface, snapshots, templates  
✅ **Security Benefits**: Process isolation without VM overhead  
✅ **Future Flexibility**: Easy to adjust resources, add containers  
✅ **Backup Strategy**: Built-in LXC snapshots and templates  

**Why Not VMs**:
❌ **Resource Waste**: 1-2GB overhead per VM too expensive  
❌ **Performance Penalty**: Unnecessary for containerized workloads  
❌ **Complexity**: Extra management layer without significant benefits  

## 🚀 Migration Path

### Phase 1: Prepare Node #2 (GoingMerry)
1. **Backup existing Ubuntu services** from GoingMerry
2. **Install Proxmox VE** (fresh installation recommended)
3. **Create LXC containers** with proper resource allocation
4. **Migrate services** one category at a time

### Phase 2: Optimize Node #1 (ThousandSunny)  
1. **System tuning** for increased container density
2. **Resource limit implementation** across all services
3. **Storage optimization** for media and database workloads
4. **Monitoring setup** for resource usage tracking

### Phase 3: Integration & Testing
1. **Inter-node communication** verification
2. **NFS mount** optimization between nodes
3. **Security Onion** deployment and log integration
4. **Comprehensive testing** of all service interactions

## 🎊 Benefits of Hybrid Proxmox Route

### Enhanced Capabilities
- **Enterprise Virtualization**: Professional VM/LXC management on Node #2
- **Dedicated Security**: Security Onion SIEM with full network monitoring
- **Resource Optimization**: Direct deployment where needed, virtualization where beneficial
- **Operational Excellence**: Best practices for backup, monitoring, and maintenance

### Maintained Performance  
- **Media Performance**: Direct hardware access on Node #1 for transcoding
- **Storage Performance**: No virtualization overhead for 9TB media storage
- **Network Performance**: Optimized routing between physical and virtual services

### Future-Proofing
- **Scalability**: Easy to add new LXC containers on Node #2
- **Testing**: Safe isolated environments for new services
- **Backup Strategy**: Professional-grade backup and recovery procedures
- **Upgrade Path**: Foundation for future hardware upgrades

This hybrid Proxmox route provides the optimal balance of performance, resource utilization, and management capabilities tailored specifically to your SunnyLabX hardware constraints and service requirements.