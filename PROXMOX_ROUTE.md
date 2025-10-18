# SunnyLabX Proxmox Deployment Route

This alternative deployment guide walks you through deploying the SunnyLabX infrastructure with **Node #2 (GoingMerry) running Proxmox VE** instead of Ubuntu Server. This route provides enhanced virtualization capabilities, better resource isolation, and dedicated security monitoring with Security Onion.

## 🎯 Architecture Overview

**Total Deployment Time**: 6-8 hours (including Proxmox setup)
**Services**: 53 containers + 2 VMs on Node #2
**Virtualization**: Proxmox VE 8.x with dedicated VMs

### Node Configuration
- **Node #1 (ThousandSunny)**: Ubuntu Server LTS 24.04 - Media & Application Hub
- **Node #2 (GoingMerry)**: Proxmox VE 8.x - Management & Security Hub
  - **Ubuntu VM**: Docker services (Networking, Monitoring, Management)
  - **Security Onion VM**: Dedicated SIEM/IDS platform

## 📋 Hardware Requirements

### Node #1 (ThousandSunny) - Unchanged
- **Hardware**: Dell XPS 8500, i7-3770, 12GB DDR3, 1TB SSD + 9TB HDD
- **OS**: Ubuntu Server LTS 24.04
- **IP**: 192.168.0.254
- **Role**: Media services, Home automation, Development, AI

### Node #2 (GoingMerry) - Proxmox Host
- **Hardware**: Mini PC, Intel Twin Lake-N150, 16GB DDR4, 500GB NVMe
- **Host OS**: Proxmox VE 8.x
- **IP**: 192.168.0.253
- **Role**: Virtualization host for management services

#### VM Resource Allocation (Node #2)
- **Proxmox Host Reserve**: 2GB RAM, 0.5 CPU cores
- **Available for VMs**: 14GB RAM, 3.5 CPU cores
- **Storage**: 450GB available (50GB reserved for host)

## 🔧 Phase 1: Proxmox Installation & Configuration

### Step 1.1: Proxmox VE Installation

1. **Download Proxmox VE ISO**
   ```bash
   # From command center (TheBaratie)
   wget https://www.proxmox.com/en/downloads/category/iso-images-pve
   ```

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
   
   # Remove enterprise repository (optional)
   nano /etc/apt/sources.list.d/pve-enterprise.list
   # Comment out the enterprise line
   
   # Add no-subscription repository
   echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
   apt update
   ```

### Step 1.2: Network Configuration

1. **Configure Bridge Interface**
   ```bash
   # /etc/network/interfaces (if not auto-configured)
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

### Step 1.3: Storage Configuration

1. **Create VM Storage**
   - **local**: Proxmox system (50GB)
   - **local-lvm**: VM disks (400GB)
   - **VM Templates**: Download Ubuntu 22.04 LTS template

## 🔒 Phase 2: Security Onion VM Deployment

### Step 2.1: Security Onion VM Creation

1. **VM Specifications**
   ```yaml
   VM ID: 100
   Name: security-onion
   CPU: 2 cores
   RAM: 6GB
   Disk: 100GB (thin provisioned)
   Network: vmbr0 (bridged)
   Boot: Ubuntu 22.04 LTS ISO
   ```

2. **Download Security Onion**
   ```bash
   # In Proxmox web interface, download Security Onion ISO
   # Or upload from command center
   wget https://download.securityonion.net/file/securityonion/securityonion-2.3.190-20240214.iso
   ```

3. **VM Creation via Web UI**
   - Navigate to Proxmox web interface
   - Create VM with above specifications
   - Attach Security Onion ISO
   - Start installation

### Step 2.2: Security Onion Configuration

1. **Installation Type**: **Standalone**
2. **Network Configuration**
   ```yaml
   Management Interface: ens18
   IP Address: 192.168.0.100/24
   Gateway: 192.168.0.1
   DNS: 192.168.0.253 (AdGuard Home)
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

## 🐳 Phase 3: Ubuntu Docker VM Deployment

### Step 3.1: Ubuntu VM Creation

1. **VM Specifications**
   ```yaml
   VM ID: 101
   Name: ubuntu-docker
   CPU: 1.5 cores
   RAM: 8GB
   Disk: 300GB (thin provisioned)
   Network: vmbr0 (bridged)
   Boot: Ubuntu Server 22.04 LTS
   ```

2. **Ubuntu Installation**
   ```bash
   # Standard Ubuntu Server installation
   # User: shawnji
   # Enable SSH server
   # Install Docker during setup or post-installation
   ```

3. **Post-Installation Setup**
   ```bash
   # SSH into Ubuntu VM
   ssh shawnji@192.168.0.253  # Or assigned DHCP IP
   
   # Update system
   sudo apt update && sudo apt upgrade -y
   
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   
   # Install Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

### Step 3.2: Configure Static IP for Ubuntu VM

1. **Set Static IP**
   ```bash
   # /etc/netplan/00-installer-config.yaml
   network:
     version: 2
     ethernets:
       ens18:
         dhcp4: false
         addresses: [192.168.0.252/24]
         gateway4: 192.168.0.1
         nameservers:
           addresses: [192.168.0.253, 1.1.1.1]
   
   sudo netplan apply
   ```

### Step 3.3: Docker Services Deployment

1. **Clone Repository**
   ```bash
   git clone https://github.com/BlkLeg/sunnylabx.git
   cd sunnylabx
   ```

2. **Deploy Services** (modified from original)
   ```bash
   # Network Services
   cd goingmerry/networking
   docker-compose up -d
   
   # Monitoring Services  
   cd ../monitoring
   docker-compose up -d
   
   # Management Services
   cd ../management
   docker-compose up -d
   
   # Communication Services
   cd ../communication
   docker-compose up -d
   
   # Automation Services
   cd ../automation
   docker-compose up -d
   
   # Note: Security services modified - no Wazuh (replaced by Security Onion)
   ```

## 📝 Phase 4: Modified Docker Compose Configurations

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

  adguard-home:
    image: adguard/adguardhome:latest
    container_name: adguard-home
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.25'
          memory: 256M
        reservations:
          cpus: '0.05'
          memory: 128M
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "3003:3000/tcp"  # Web interface (port changed for Proxmox compatibility)
    volumes:
      - adguard_work:/opt/adguardhome/work
      - adguard_conf:/opt/adguardhome/conf
    networks:
      - network_services
    logging:
      driver: syslog
      options:
        syslog-address: "tcp://192.168.0.100:514"
        tag: "adguard-home"

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
  adguard_work:
  adguard_conf:
```

## 🔧 Phase 5: Ansible Configuration Updates

### Step 5.1: Updated Inventory

**Modified: ansible/hosts.ini**
```ini
# SunnyLabX Proxmox Route Inventory
# Node configuration for Proxmox-based deployment

[all]
# Physical nodes
node1 ansible_host=192.168.0.254 ansible_user=shawnji ansible_ssh_private_key_file=~/.ssh/id_rsa
proxmox-host ansible_host=192.168.0.253 ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa

# Virtual machines on Node #2
ubuntu-vm ansible_host=192.168.0.252 ansible_user=shawnji ansible_ssh_private_key_file=~/.ssh/id_rsa
security-onion ansible_host=192.168.0.100 ansible_user=admin ansible_ssh_private_key_file=~/.ssh/id_rsa

[thousandsunny]
# Node #1 - Application & Content Hub
node1

[goingmerry]
# Node #2 - Proxmox host
proxmox-host

[goingmerry_vms]
# VMs running on Node #2
ubuntu-vm
security-onion

[docker_hosts]
# Hosts running Docker services
node1
ubuntu-vm

[security_monitoring]
# Security monitoring platforms
security-onion

[management_nodes]
# Management and monitoring services
ubuntu-vm
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

## 📊 Phase 6: Monitoring & Verification

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
   - **AdGuard Home**: http://192.168.0.252:3003
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

## 🔄 Phase 7: Log Integration & Security Monitoring

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

## 📋 Resource Allocation Summary

### Proxmox Host (GoingMerry) - 16GB RAM, 4 CPU cores
```
├── Proxmox Host: 2GB RAM, 0.5 CPU cores
├── Security Onion VM: 6GB RAM, 2 CPU cores  
├── Ubuntu Docker VM: 8GB RAM, 1.5 CPU cores
└── Available Headroom: 0GB RAM, 0 CPU cores
```

### Service Distribution
```
Node #1 (ThousandSunny):
├── Media Services (Plex, Jellyfin, ARR Suite)
├── Home Automation (Home Assistant, IoT)
├── Development (Gitea, Databases)
└── AI Services (if implemented)

Node #2 (Proxmox):
├── Security Onion VM:
│   ├── SIEM/Log Analysis
│   ├── Network IDS/IPS
│   ├── Threat Detection
│   └── Incident Response
└── Ubuntu Docker VM:
    ├── Network Services (Nginx, AdGuard, Cloudflare)
    ├── Monitoring (Prometheus, Grafana)
    ├── Management (Portainer)
    ├── Identity (Authentik)
    └── Communication (Matrix)
```

This Proxmox route provides enhanced security monitoring, better resource isolation, and maintains all the functionality of the original Ubuntu-based deployment while adding enterprise-grade virtualization capabilities and dedicated security infrastructure with Security Onion.