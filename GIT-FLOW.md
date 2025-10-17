# Git Flow & Node Deployment Guide

Purpose
- Describe the recommended git workflow for cloning this repository on each home-lab node during setup and how to organize and push changes so they end up in the correct service folder (for example: nginx changes go to the `goingmerry` folder as configured by the service).

Scope
- This document covers:
  - How to clone the repo on each node
  - Branching, commit and PR conventions
  - Where to place service-specific changes (folder/filename guidance)
  - Best practices for secrets, large files, and conflict resolution
  - An example workflow for nginx changes (goingmerry)

Repository layout (current structure)
- The repo is organized by physical nodes, with services grouped by category within each node:
  - goingmerry/           # Node #2 services
    - networking/         # Network & management services
      - docker-compose-nginx.yml  # Nginx Proxy Manager, AdGuard Home
    - management/         # Central management
      - docker-compose-portainer.yml  # Portainer Controller
    - security/           # Security & identity services
      - docker-compose-security.yml   # Authentik, Wazuh, CrowdSec, etc.
    - monitoring/         # Monitoring stack
      - docker-compose-monitoring.yml # Prometheus, Grafana, Loki, etc.
    - automation/         # Workflow automation
      - docker-compose-automation.yml # n8n
  - thousandsunny/        # Node #1 services
    - infra/              # Core infrastructure
      - docker-compose-gitea.yml      # Gitea, Duplicati, Nextcloud
    - media/              # Media services
      - docker-compose-media.yml      # Plex, Jellyfin, ARR suite, etc.
    - torrent/            # Download clients
      - docker-compose-torrent.yml    # qBittorrent, Deluge
    - ai/                 # AI & ML services
      - docker-compose-ai.yml         # Ollama, WebUI
    - agents/             # Remote agents
      - docker-compose-portainer-agent.yml # Portainer Agent
  - ansible/              # Infrastructure automation
  - README.md
  - GIT-FLOW.md

Each compose file contains service placeholders grouped logically by function within each physical node.

1) Cloning the repo on a node (initial setup)
- Use SSH whenever possible. From the node you are setting up:
  - git clone git@github.com:BlkLeg/sunnylabx.git
  - cd sunnylabx
  - git fetch --all
  - git checkout main
  - git pull origin main
- If your environment requires HTTPS, use:
  - git clone https://github.com/BlkLeg/sunnylabx.git
- If the repo uses submodules, clone recursively:
  - git clone --recurse-submodules git@github.com:BlkLeg/sunnylabx.git

Notes:
- Each node should clone into a consistent path (example: /srv/sunnylabx or /opt/sunnylabx). Document the chosen location in your node provisioning scripts.
- Do not store node-specific secrets in the repo. Use Vaultwarden, a vault, or environment-only files specified in .gitignore.

2) Branching strategy
- Use a simple, clear branching model that fits home-lab scale:
  - main — production-ready configuration (what is deployed on nodes)
  - dev (optional) — integration / testing branch
  - feature/<service>-short-description — for new work
  - fix/<service>-short-description — bugfixes or hotfixes
  - node/<node-name>/<what> — optional when the change is node-specific
- Examples:
  - feature/networking-update-ssl
  - fix/monitoring-grafana-timeout
  - feature/media-add-kavita
  - node/goingmerry/security-config
  - node/thousandsunny/ai-setup

3) Per-node edits vs centralized edits
- Preferred: make configuration changes locally on your working machine, test them in a staging environment (or a node) and push the branch and open a PR for review before merging to main.
- If you must edit on a node (e.g., while provisioning), still create a branch:
  - git checkout -b node/node2/update-goingmerry
  - edit files in the correct service folder
  - git add <files>
  - git commit -m "fix(goingmerry/nginx): adjust proxy timeout for service X"
  - git push -u origin node/node2/update-goingmerry
  - Open a PR toward main

4) Where to put changes (organization rules)
- Always commit service-specific configuration into the correct node and category folder.
  - Example: Nginx Proxy Manager config → goingmerry/networking/docker-compose-nginx.yml
  - Example: Media service config → thousandsunny/media/docker-compose-media.yml
  - Example: Security service config → goingmerry/security/docker-compose-security.yml
  - The repository's categorized folders are the canonical place for any config that drives deployments.
- Naming convention:
  - Use descriptive filenames: docker-compose-<category>.yml, .env.example, README.md
  - Keep runtime secrets out: add .env to .gitignore and include .env.example with placeholders.
- If you add a new service:
  - Add it to the appropriate category compose file on the correct node
  - Update the service's section in the compose file with proper placeholder configuration
  - Document the change in the folder's README.md explaining deployment and target node.

5) Commit message conventions
- Use short, conventional messages with scope:
  - type(scope): short description
  - types: feat, fix, chore, docs, ci
- Examples:
  - feat(networking): add upstream for api.example.local to nginx config
  - fix(monitoring): correct Grafana dashboard persistence volume
  - feat(media): add Kavita service to media stack
  - chore(infra): update Duplicati backup schedule
- Include more details in the body when necessary (why, migration steps, manual steps to apply).

6) Pushing, PRs, and merging
- Workflow:
  1. git pull origin main (stay up to date)
  2. git checkout -b feature/<something>
  3. make changes committed under correct folder (e.g., services/goingmerry/nginx/)
  4. git add, git commit -m "..."
  5. git push -u origin feature/<something>
  6. Open a Pull Request to main, describe what changed, which node(s) this affects, and any manual steps required on nodes
- PR checks:
  - Ensure the branch is up to date with main (rebase or merge main into branch)
  - Run linters, config checkers, or dry-run deployment locally if possible
- Once approved, merge to main using merge commit or squash (establish a team convention).
- After merge:
  - Pull main on each node that needs the changes:
    - git checkout main
    - git pull origin main
  - If you use automation (CI or something like a deployment script), the change will be applied automatically per your automation.

7) Example: Making networking changes (goingmerry)
- Suppose you need to update Nginx Proxy Manager configuration or add a new service to the networking stack.
- Steps:
  1. On your workstation or the node: git pull origin main
  2. Create a branch: git checkout -b fix/networking-proxy-timeout
  3. Edit the compose file: goingmerry/networking/docker-compose-nginx.yml
  4. Test locally if possible: 
     - cd goingmerry/networking
     - docker-compose up --build
  5. Commit:
     - git add goingmerry/networking/docker-compose-nginx.yml
     - git commit -m "fix(networking): increase proxy_read_timeout for nginx"
  6. Push and open PR:
     - git push -u origin fix/networking-proxy-timeout
     - Open PR describing the change and which node(s) should pull after merge
  7. Merge into main and then apply on the target node:
     - On goingmerry (Node #2): git checkout main && git pull origin main
     - Restart the networking stack: 
       - cd goingmerry/networking
       - docker-compose up -d
- Important: if your deployment references the category folder names in infra tooling (Portainer stack name, compose path), be sure to keep those names consistent.

8) Secrets and credentials
- Never commit secrets (private keys, passwords, certs).
- Use .env files with .env in .gitignore; include .env.example with placeholders.
- For secrets use:
  - Vaultwarden for passwords
  - HashiCorp Vault or other secret store for automations
  - git-crypt or SOPS if you need encrypted secrets in repo (document decryption key handling)

9) Large files & binaries
- Use Git LFS for large binary files (media images, VM disks) — otherwise keep them out of the repo and reference external storage.

10) Conflict resolution & merges
- Always pull main before starting changes.
- If a conflict arises during merge:
  - Resolve locally, run service tests, commit the resolved state, then push.
- If multiple nodes will edit the same files concurrently, coordinate via an issue/PR.

11) Emergency hotfix process
- Create branch fix/<service>-hotfix
- Make minimal change required and push to origin
- Open PR to main with high priority tag (or merge directly if team policy permits)
- Tag the release if necessary: git tag -a vYYYYMMDD-hotfix -m "hotfix for ..."
- Pull and restart services on affected nodes immediately after merge.

12) Access and permissions
- Use SSH deploy keys or personal machine SSH keys.
- Keep personal accounts for auditability; prefer team accounts only where necessary.
- If using CI to apply changes, create a machine account with least privilege.

13) Automation & deployment hints
- If you use Ansible for node provisioning:
  - Update ansible/hosts.ini with your node IPs and SSH configuration
  - Run base setup: ansible-playbook -i ansible/hosts.ini ansible/playbook.yml
  - Install Docker: ansible-playbook -i ansible/hosts.ini ansible/docker-playbook.yml
  - SSH connections remain secure during firewall configuration
- If you use Portainer / stack deployments:
  - Keep the compose files inside service folder and point Portainer to that path or use a CI job to deploy from repo.
- If you automate node provisioning (Ansible, Terraform), reference the repo path and ensure your automation pulls main after merges.

14) Housekeeping & docs
- Add a small README.md to each category folder describing:
  - What services the category contains
  - Which node the category runs on
  - How to test changes to the compose file
  - Any manual steps required after changing configurations
- Keep the main README.md updated with the current service mapping
- Keep GIT-FLOW.md in the repo root and update it as processes evolve.

Quick command cheatsheet
- Clone:
  - git clone git@github.com:BlkLeg/sunnylabx.git
- Start a branch:
  - git checkout -b feature/<category>-short
- Sync:
  - git pull origin main
- Commit:
  - git add <files>
  - git commit -m "type(category): short desc"
  - git push -u origin <branch>
- Apply on node after merge:
  - git checkout main && git pull origin main
  - cd <node>/<category>
  - docker-compose up -d

Notes and final reminders
- Always place service configuration files in the correct node and category folder (e.g., networking services → `goingmerry/networking/`).
- Keep secrets out of git; use placeholder files and a secret manager.
- Use PRs for review and coordination even if you are the only operator — this keeps history and notes about why changes were made.
- Each compose file contains multiple related services grouped by function and physical node location.

Appendix A — Example: networking-related file paths
- Example paths for networking services (Node #2):
  - goingmerry/networking/docker-compose-nginx.yml (Nginx Proxy Manager, AdGuard Home)
  - goingmerry/networking/.env.example (environment variable template)
  - goingmerry/networking/README.md (category documentation)
- Example paths for media services (Node #1):
  - thousandsunny/media/docker-compose-media.yml (Plex, Jellyfin, ARR suite)
  - thousandsunny/media/.env.example
- Follow the node/category/compose-file naming convention consistently.

Appendix B — Example commit message
- git commit -m "fix(networking): extend proxy timeout for nginx upstream to 120s

Reason: downstream API times out on heavy requests. Tested with local docker-compose in goingmerry/networking/."
