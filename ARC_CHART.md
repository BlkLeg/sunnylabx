# 🏗️ SunnyLabX Dual Proxmox Architecture Chart

## 🌐 Network Infrastructure Overview

```
                    ┌─────────────────────────────────────────────────────────────┐
                    │                     Internet                                 │
                    │                  (via NordVPN)                              │
                    └─────────────────────┬───────────────────────────────────────┘
                                          │
                    ┌─────────────────────▼───────────────────────────────────────┐
                    │              ISP Router/Modem                               │
                    │              192.168.0.1/24                                │
                    └─────────────────────┬───────────────────────────────────────┘
                                          │
            ┌─────────────────────────────┼─────────────────────────────────┐
            │                             │                                 │
┌───────────▼──────────┐                  │                  ┌──────────────▼────────────┐
│   Node #1 Host       │                  │                  │     Node #2 Host          │
│   ThousandSunny      │                  │                  │     GoingMerry            │
│   192.168.0.254      │                  │                  │     192.168.0.253         │
│   12GB RAM, 4 CPU    │                  │                  │     16GB RAM, 4 CPU       │
└───────────┬──────────┘                  │                  └──────────────┬────────────┘
            │                             │                                 │
            │                             │                                 │
    ┌───────▼────────┐                    │                    ┌────────────▼─────────────┐
    │  Proxmox VE    │                    │                    │      Proxmox VE         │
    │  Cluster Node  │◄───────────────────┼────────────────────►│    Cluster Node        │
    │      #1        │                    │                    │         #2             │
    └───────┬────────┘                    │                    └────────────┬─────────────┘
            │                             │                                 │
            │                             │                                 │
            ▼                             │                                 ▼
```

## 🖥️ Node #1 (ThousandSunny) - Storage & Media Powerhouse

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                          ThousandSunny (192.168.0.254)                                 │
│                        Proxmox VE 8.x - 12GB RAM, 4 CPU                               │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│  Host Resources: 2GB RAM, 0.5 CPU                                                      │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                   Debian LXC Container (CT 101)                                 │   │
│  │                    10GB RAM, 3.5 CPU, 12GB SWAP                                │   │
│  │                      IP: 10.0.0.251/24                                         │   │
│  ├─────────────────────────────────────────────────────────────────────────────────┤   │
│  │                                                                                 │   │
│  │  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐                   │   │
│  │  │  Media Services │ │ Infrastructure  │ │ IoT/Automation  │                   │   │
│  │  │      (9)        │ │      (15)       │ │       (7)       │                   │   │
│  │  ├─────────────────┤ ├─────────────────┤ ├─────────────────┤                   │   │
│  │  │ • Plex/Jellyfin │ │ • PostgreSQL    │ │ • Home Assistant│                   │   │
│  │  │ • Sonarr        │ │ • Redis         │ │ • MQTT Broker   │                   │   │
│  │  │ • Radarr        │ │ • Gitea         │ │ • InfluxDB      │                   │   │
│  │  │ • Prowlarr      │ │ • Nextcloud     │ │ • Zigbee2MQTT   │                   │   │
│  │  │ • Bazarr        │ │ • Vaultwarden   │ │ • Node-RED      │                   │   │
│  │  │ • Overseerr     │ │ • Authentik     │ │ • ESPHome       │                   │   │
│  │  │ • Immich        │ │ • Traefik       │ │ • Frigate       │                   │   │
│  │  │ • Kavita        │ │ • ... more      │ │                 │                   │   │
│  │  │ • Tautulli      │ │                 │ │                 │                   │   │
│  │  └─────────────────┘ └─────────────────┘ └─────────────────┘                   │   │
│  │                                                                                 │   │
│  │  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐                   │   │
│  │  │ Torrent/Download│ │  Development    │ │ Security (SIEM) │                   │   │
│  │  │       (3)       │ │       (2)       │ │       (3)       │                   │   │
│  │  ├─────────────────┤ ├─────────────────┤ ├─────────────────┤                   │   │
│  │  │ • qBittorrent   │ │ • Code-server   │ │ • Wazuh Manager │                   │   │
│  │  │ • Deluge        │ │ • Git services  │ │ • Wazuh Indexer │                   │   │
│  │  │ • Jackett       │ │                 │ │ • Wazuh Dashboard│                   │   │
│  │  └─────────────────┘ └─────────────────┘ └─────────────────┘                   │   │
│  │                                                                                 │   │
│  │                      Total: 37+ Services                                       │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                          Storage Mounts                                        │   │
│  │  • /mnt/hdd-1: 4TB (Movies)                                                    │   │
│  │  • /mnt/hdd-2: 4TB (TV Shows)                                                  │   │
│  │  • /mnt/hdd-3: 4TB (Music/Books)                                               │   │
│  │  • /mnt/hdd-4: 4TB (Backups)                                                   │   │
│  │  • SSD: 1TB (System + LXC storage)                                             │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

## 🌐 Node #2 (GoingMerry) - Network & Security Hub

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                            GoingMerry (192.168.0.253)                                  │
│                         Proxmox VE 8.x - 16GB RAM, 4 CPU                              │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│  Host Resources: 2GB RAM, 0.5 CPU                                                      │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                    OPNsense Firewall VM (VM 110)                               │   │
│  │                      1GB RAM, 0.5 CPU, 20GB Disk                               │   │
│  │                        IP: 10.0.0.1/24                                         │   │
│  ├─────────────────────────────────────────────────────────────────────────────────┤   │
│  │  ┌───────────────┐ ┌───────────────┐ ┌─────────────────┐                       │   │
│  │  │   Firewall    │ │ NordVPN Client│ │ Network Gateway │                       │   │
│  │  │   Rules       │ │  Integration  │ │   10.0.0.1      │                       │   │
│  │  └───────────────┘ └───────────────┘ └─────────────────┘                       │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                   Debian LXC Container (CT 102)                                 │   │
│  │                     5GB RAM, 2 CPU, 13GB SWAP                                  │   │
│  │                       IP: 10.0.0.252/24                                        │   │
│  ├─────────────────────────────────────────────────────────────────────────────────┤   │
│  │                                                                                 │   │
│  │  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐                   │   │
│  │  │    Network      │ │   Monitoring    │ │   Automation    │                   │   │
│  │  │      (2)        │ │       (6)       │ │       (1)       │                   │   │
│  │  ├─────────────────┤ ├─────────────────┤ ├─────────────────┤                   │   │
│  │  │ • Nginx Proxy   │ │ • Prometheus    │ │ • n8n           │                   │   │
│  │  │ • Cloudflare    │ │ • Grafana       │ │                 │                   │   │
│  │  │                 │ │ • Loki          │ │ Communication   │                   │   │
│  │  │                 │ │ • Promtail      │ │ Stack ELIMINATED│                   │   │
│  │  │                 │ │ • AlertManager  │ │ (Matrix, Discord│                   │   │
│  │  │                 │ │ • Node-Exporter │ │ SMTP, Webhooks) │                   │   │
│  │  └─────────────────┘ └─────────────────┘ └─────────────────┘                   │   │
│  │                                                                                 │   │
│  │                   Total: 9 Services (Communication Eliminated)                 │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐   │
│  │                        Available Resources                                      │   │
│  │  • 8GB RAM Available for Future Expansion (+1GB from communication elimination)│   │
│  │  • 1 CPU Core Available                                                        │   │
│  │  • High-Speed SSD Storage                                                      │   │
│  └─────────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

## 🔐 Security & Network Flow Architecture

```
                             ┌─────────────────────┐
                             │      Internet       │
                             │    (via NordVPN)    │
                             └──────────┬──────────┘
                                        │
                             ┌──────────▼──────────┐
                             │    ISP Router       │
                             │   192.168.0.1       │
                             └──────────┬──────────┘
                                        │
                        ┌───────────────┼───────────────┐
                        │               │               │
              ┌─────────▼─────────┐     │     ┌─────────▼─────────┐
              │  ThousandSunny    │     │     │   GoingMerry      │
              │  192.168.0.254    │     │     │  192.168.0.253    │
              └─────────┬─────────┘     │     └─────────┬─────────┘
                        │               │               │
                        │               │               │
              ┌─────────▼─────────┐     │     ┌─────────▼─────────┐
              │    Proxmox VE     │◄────┼────►│   Proxmox VE      │
              │   Cluster Node    │     │     │  Cluster Node     │
              └─────────┬─────────┘     │     └─────────┬─────────┘
                        │               │               │
                        │               │               │
                        │               │               ▼
                        │               │     ┌─────────────────────┐
                        │               │     │   OPNsense VM       │
                        │               │     │    10.0.0.1         │
                        │               │     │  ┌─────────────────┐ │
                        │               │     │  │ NordVPN Client  │ │
                        │               │     │  │   WAN: DHCP     │ │
                        │               │     │  │ LAN: 10.0.0.1   │ │
                        │               │     │  └─────────────────┘ │
                        │               │     └──────────┬──────────┘
                        │               │                │
                        │               │     Internal Network
                        │               │      (10.0.0.0/24)
                        │               │                │
                        ▼               │                ▼
              ┌─────────────────────┐   │     ┌─────────────────────┐
              │   Ubuntu LXC 101    │   │     │   Ubuntu LXC 102    │
              │    10.0.0.251       │◄──┼────►│    10.0.0.252       │
              │                     │   │     │                     │
              │ ┌─────────────────┐ │   │     │ ┌─────────────────┐ │
              │ │ Dockerized      │ │   │     │ │ Network &       │ │
              │ │ Wazuh SIEM      │ │   │     │ │ Monitoring      │ │
              │ │ Manager:55000   │ │   │     │ │ Services        │ │
              │ │ Dashboard:443   │ │   │     │ │                 │ │
              │ │ Agents:1514     │ │   │     │ │                 │ │
              │ └─────────────────┘ │   │     │ └─────────────────┘ │
              │                     │   │     │                     │
              │ • 37+ Services      │   │     │ • 9 Services        │
              │ • Media & Storage   │   │     │ • Network & Comms   │
              │ • IoT & Development │   │     │ • Monitoring        │
              └─────────────────────┘   │     └─────────────────────┘
                        │               │               │
                        └───────────────┼───────────────┘
                                        │
                              ┌─────────▼─────────┐
                              │  Wazuh Agents     │
                              │ • Host Monitoring │
                              │ • Container Logs  │
                              │ • Security Events │
                              └───────────────────┘
```

## 📊 Resource Allocation Matrix

```
╔═══════════════════════════════════════════════════════════════════════════════════╗
║                          RESOURCE ALLOCATION SUMMARY                             ║
╠═══════════════════════════════════════════════════════════════════════════════════╣
║                                                                                   ║
║  Node #1 (ThousandSunny) - 12GB RAM, 4 CPU, 12GB SWAP                          ║
║  ┌─────────────────────────────────────────────────────────────────────────┐     ║
║  │ Component              │ RAM    │ CPU   │ Storage │ Purpose              │     ║
║  ├─────────────────────────────────────────────────────────────────────────┤     ║
║  │ Proxmox Host          │ 2GB    │ 0.5   │ 100GB   │ Hypervisor           │     ║
║  │ Ubuntu LXC (CT 101)   │ 10GB   │ 3.5   │ 200GB   │ Docker Services      │     ║
║  │  ├─ Media Services    │ ~4GB   │ 1.5   │ -       │ Plex/ARR Suite       │     ║
║  │  ├─ Infrastructure    │ ~3GB   │ 1.0   │ -       │ Databases/Apps       │     ║
║  │  ├─ IoT/Automation    │ ~1.5GB │ 0.5   │ -       │ Home Assistant       │     ║
║  │  ├─ Wazuh SIEM        │ ~1GB   │ 0.3   │ -       │ Security Monitoring  │     ║
║  │  └─ Other Services    │ ~0.5GB │ 0.2   │ -       │ Development/Misc     │     ║
║  │ SWAP Buffer           │ -      │ -     │ 12GB    │ Memory Overflow      │     ║
║  └─────────────────────────────────────────────────────────────────────────┘     ║
║                                                                                   ║
║  Node #2 (GoingMerry) - 16GB RAM, 4 CPU, 13GB SWAP                             ║
║  ┌─────────────────────────────────────────────────────────────────────────┐     ║
║  │ Component              │ RAM    │ CPU   │ Storage │ Purpose              │     ║
║  ├─────────────────────────────────────────────────────────────────────────┤     ║
║  │ Proxmox Host          │ 2GB    │ 0.5   │ 50GB    │ Hypervisor           │     ║
║  │ OPNsense VM (110)     │ 1GB    │ 0.5   │ 20GB    │ Firewall/VPN         │     ║
║  │ Ubuntu LXC (CT 102)   │ 6GB    │ 2.0   │ 100GB   │ Network Services     │     ║
║  │  ├─ Network Services  │ ~2GB   │ 0.7   │ -       │ Nginx/Traefik        │     ║
║  │  ├─ Monitoring Stack  │ ~3GB   │ 1.0   │ -       │ Prometheus/Grafana   │     ║
║  │  └─ Communication     │ ~1GB   │ 0.3   │ -       │ Matrix/Discord       │     ║
║  │ Available Resources   │ 7GB    │ 1.0   │ -       │ Future Expansion     │     ║
║  │ SWAP Buffer           │ -      │ -     │ 13GB    │ Memory Overflow      │     ║
║  └─────────────────────────────────────────────────────────────────────────┘     ║
║                                                                                   ║
║  CLUSTER TOTALS: 28GB RAM, 8 CPU, 25GB SWAP, 52+ Services                      ║
╚═══════════════════════════════════════════════════════════════════════════════════╝
```

## 🚀 Service Distribution Flowchart

```
                          ┌─────────────────────────────────┐
                          │        SunnyLabX Cluster        │
                          │     46+ Total Services          │
                          │      (Optimized Setup)          │
                          └─────────────┬───────────────────┘
                                        │
                        ┌───────────────┼───────────────┐
                        │               │               │
              ┌─────────▼─────────┐     │     ┌─────────▼─────────┐
              │  Node #1 Services │     │     │  Node #2 Services │
              │      (39+)        │     │     │        (9)        │
              └─────────┬─────────┘     │     └─────────┬─────────┘
                        │               │               │
         ┌──────────────┼─────────┐     │     ┌─────────┼──────────────┐
         │              │         │     │     │         │              │
    ┌────▼────┐   ┌─────▼─────┐  │     │     │  ┌──────▼──────┐ ┌────▼────┐
    │ Media   │   │Infrastructure│ │     │     │  │  Network    │ │Monitoring│
    │   (9)   │   │    (15)    │  │     │     │  │     (2)     │ │   (6)   │
    └─────────┘   └───────────┘  │     │     │  └─────────────┘ └─────────┘
                                 │     │     │
         ┌───────────────────────┘     │     └─────────────────────┐
         │                             │                           │
    ┌────▼────┐   ┌──────▼──────┐      │        ┌─────────▼─────────┐
    │IoT/Auto │   │ Development │      │        │   Automation     │
    │   (7)   │   │     (2)     │      │        │       (1)        │
    └─────────┘   └─────────────┘      │        └───────────────────┘
                                       │
         ┌─────────────────────────────┘
         │
    ┌────▼────┐   ┌──────▼──────┐
    │Torrent/ │   │   Wazuh     │
    │Download │   │   SIEM      │
    │   (3)   │   │    (3)      │
    └─────────┘   └─────────────┘
```

## 🔒 Security Architecture Layers

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                            SECURITY ARCHITECTURE                                   │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  Layer 1: Network Perimeter Security                                              │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                         │   │
│  │  │ ISP Firewall│  │ OPNsense VM │  │  NordVPN    │                         │   │
│  │  │   Router    │  │  Advanced   │  │  Tunnel     │                         │   │
│  │  │  Gateway    │  │  Firewall   │  │ Encryption  │                         │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                         │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                     │
│  Layer 2: Virtualization Security                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                         │   │
│  │  │ Proxmox VE  │  │ LXC Container│  │ VM Isolation│                         │   │
│  │  │ Hypervisor  │  │  Isolation  │  │   Security  │                         │   │
│  │  │  Security   │  │   Namespaces│  │             │                         │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                         │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                     │
│  Layer 3: Application Security                                                    │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                         │   │
│  │  │ Authentik   │  │ Vaultwarden │  │  SSL/TLS    │                         │   │
│  │  │ SSO/MFA     │  │  Password   │  │ Certificates│                         │   │
│  │  │ Management  │  │  Manager    │  │  Traefik    │                         │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                         │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                     │
│  Layer 4: Monitoring & Detection                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────────┐   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                         │   │
│  │  │ Wazuh SIEM  │  │ Prometheus  │  │  CrowdSec   │                         │   │
│  │  │ Manager     │  │ Monitoring  │  │ Intrusion   │                         │   │
│  │  │ (Dockerized)│  │  & Alerts   │  │ Prevention  │                         │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                         │   │
│  └─────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## 📈 Performance & Optimization Benefits

```
╔══════════════════════════════════════════════════════════════════════════════════════╗
║                         OPTIMIZATION ACHIEVEMENTS                                   ║
╠══════════════════════════════════════════════════════════════════════════════════════╣
║                                                                                      ║
║  🎯 Resource Efficiency                                                             ║
║  ┌────────────────────────────────────────────────────────────────────────────┐     ║
║  │ • Eliminated Services: Portainer, Duplicati, Watchtower, Uptime Kuma       │     ║
║  │ • VM to Container: Wazuh SIEM moved from VM to Docker (saves 4GB RAM)      │     ║
║  │ • Mutual Exclusivity: Plex/Jellyfin saves 1-2GB during normal operation   │     ║
║  │ • Total RAM Liberation: ~5.75GB freed for application workloads            │     ║
║  │ • Service Count: Optimized from 62 → 52+ with better functionality         │     ║
║  └────────────────────────────────────────────────────────────────────────────┘     ║
║                                                                                      ║
║  🚀 Performance Improvements                                                        ║
║  ┌────────────────────────────────────────────────────────────────────────────┐     ║
║  │ • Direct Storage Access: Media services via NFS bind mounts               │     ║
║  │ • Container Optimization: Better resource limits and CPU sharing          │     ║
║  │ • Network Segmentation: Internal 10.0.0.0/24 for VM/LXC communication    │     ║
║  │ • SWAP Buffering: 25GB total SWAP for memory pressure handling            │     ║
║  │ • Load Distribution: Strategic service placement across nodes             │     ║
║  └────────────────────────────────────────────────────────────────────────────┘     ║
║                                                                                      ║
║  🔒 Security Enhancements                                                           ║
║  ┌────────────────────────────────────────────────────────────────────────────┐     ║
║  │ • VPN Distribution: All traffic routed through NordVPN via OPNsense       │     ║
║  │ • Advanced Firewall: OPNsense VM with enterprise-grade security           │     ║
║  │ • SIEM Integration: Dockerized Wazuh for comprehensive monitoring         │     ║
║  │ • Process Isolation: VM/LXC separation for security boundaries            │     ║
║  │ • Network Isolation: Internal network with controlled external access     │     ║
║  └────────────────────────────────────────────────────────────────────────────┘     ║
║                                                                                      ║
║  📊 Operational Excellence                                                          ║
║  ┌────────────────────────────────────────────────────────────────────────────┐     ║
║  │ • Unified Management: Single Proxmox cluster interface                    │     ║
║  │ • Professional Backup: Native Proxmox backup solutions                    │     ║
║  │ • Containerization: Advanced Docker practices with resource limits        │     ║
║  │ • Scalability: Easy expansion with 7GB RAM headroom on Node #2            │     ║
║  │ • High Availability: Cluster-ready architecture for future growth         │     ║
║  └────────────────────────────────────────────────────────────────────────────┘     ║
╚══════════════════════════════════════════════════════════════════════════════════════╝
```

---

## 🎯 Architecture Summary

This dual Proxmox cluster represents a **production-ready homelab** with enterprise-grade security, optimal resource utilization, and streamlined service deployment using **Debian containers**. The architecture provides comprehensive security monitoring through Dockerized Wazuh and secure network isolation via OPNsense with NordVPN integration.

**Total Infrastructure**: 46+ services across 2 nodes with optimized resource allocation and enhanced security posture using Debian LXCs.