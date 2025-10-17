## Rules for this project
- Node #1 is the ThousandSunny & Node #2 is GoingMerry
- Node #1 192.168.0.254 Node #2 192.168.0.253 - Both running Ubuntu Server LTS 24.04
- Node #1 Interface: enp3s0 & Node #2 Interface: enp2s0
- Command Center: TheBaratie (Laptop) 192.168.0.222 - PopOS
- Each node has its purposes.
- Never use "Version" in any future docker-compose.yml scripts. This is obsolete on ALL nodes.
- Docker compose is the correct syntax
- The nodes should be able to speak to each other.
- ThousandSunny media drives are mounted at /mnt/hdd-1 /mnt/hdd-2 /mnt/hdd-3 & /mnt/hdd-4 - use named mounts - simple structure
- GoingMerry has ThousandSunny's drives mounted via NFS at /mnt/HDD1-4 respectively.
- Cloudflare tunnels + WAF are used for external access
- ISP Restrictions: No port forwarding; Unable to change DNS server via router interface (restricted)
- Two branches will exist, the base branch, with all of the placeholder values and dir structure & main branch with real configs.
- The docker networks should be set up logically.
- Registered domains: thousandsunny.win thousandsunny.info sunnyserverx.site | all managed via Cloudflare
- Resource limits will be applied to all services respectively to ensure neither of the nodes are overwhelmed.

## Media Locations for the ThousandSunny - Node #1 - EACH HAVE DATA PRESENT! BE CAREFUL WITH OPERATIONS
# TV Directories
- /mnt/hdd-1/TV Shows
- /mnt/hdd-2/tv-2
- /mnt/hdd-3/tv-3
- /mnt/hdd-4/tv
# Movie Directories
- /mnt/hdd-1/Movies
- /mnt/hdd-2/movies-2
- /mnt/hdd-3/moviess-3
- /mnt/hdd-4/movies

# Previous Immich folder - Careful! There is data in here!
- /mnt/hdd-3/immich