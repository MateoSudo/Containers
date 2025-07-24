# Drone CI/CD Deployment Guide

## Overview
This directory contains the configuration for deploying Drone CI/CD in a Podman containerized environment with Cosmos OS proxy integration and Cloudflare DNS management.

## Architecture
```
GitHub Repository
       ↓
   Drone Webhook
       ↓
Internet → Cloudflare DNS (drone.mrintellisense.com)
       ↓
   DMZ Static IP
       ↓
   Cosmos OS Proxy (HTTPS with Let's Encrypt *.mrintellisense.com)
       ↓
   localhost:8080 → Drone Server Container
       ↓
   Drone Runner Container → Podman Socket → Container Deployments
```

## Prerequisites

### 1. Cosmos OS Configuration
Configure Cosmos OS to proxy traffic:
- **Source**: `drone.mrintellisense.com`
- **Target**: `http://localhost:8080`
- **SSL**: Use existing wildcard certificate `*.mrintellisense.com`

### 2. Cloudflare DNS
Ensure DNS record exists:
- **Type**: A or CNAME
- **Name**: `drone.mrintellisense.com`
- **Value**: Your DMZ static IP address

### 3. GitHub OAuth Application
1. Go to GitHub Settings → Developer settings → OAuth Apps
2. Create new OAuth App with:
   - **Application name**: Drone CI/CD
   - **Homepage URL**: `https://drone.mrintellisense.com`
   - **Authorization callback URL**: `https://drone.mrintellisense.com/login`
3. Note the Client ID and Client Secret for `.env` file

### 4. Podman Socket Access
Ensure Podman socket is accessible:
```bash
# Check if Podman socket exists
ls -la /run/podman/podman.sock

# If needed, create Docker-compatible symlink
sudo ln -sf /run/podman/podman.sock /var/run/docker.sock
```

## Installation

### 1. Environment Configuration
Verify your `.env` file contains all required variables:
```bash
# Drone Server Configuration
DRONE_RPC_SECRET=894bc099130d2ae59a13a73b84b1428b  # Your current secret
DRONE_SERVER_HOST=drone.mrintellisense.com         # Matches your DNS
DRONE_SERVER_PROTO=http                            # Cosmos handles HTTPS
DRONE_GITHUB_CLIENT_ID=Ov23lilOWlysdSQVSuiP        # From GitHub OAuth app
DRONE_GITHUB_CLIENT_SECRET=1c47c349a25498855163b799544273e41eb1c135  # From GitHub OAuth app
DRONE_USER_CREATE=username:MateoSudo,admin:true    # Your GitHub username
DRONE_DATABASE_DRIVER=sqlite3
DRONE_DATABASE_DATASOURCE=/data/database.sqlite

# Drone Runner Configuration
DRONE_RPC_HOST=drone_server                        # Container name
DRONE_RPC_PROTO=http                              # Internal communication
DRONE_RUNNER_CAPACITY=2                           # Max concurrent builds
DRONE_RUNNER_NAME=podman-runner
DRONE_RUNNER_NETWORKS=drone-net
```

### 2. Deploy Services
```bash
# Navigate to Drone directory
cd /path/to/Containers/Drone

# Deploy the stack
podman-compose up -d

# Check service status
podman-compose ps

# View logs
podman-compose logs drone-server
podman-compose logs drone-runner
```

### 3. Verify Installation
1. **Check container health**:
   ```bash
   podman-compose ps
   # Both services should show as "healthy"
   ```

2. **Access Drone Web Interface**:
   - Open `https://drone.mrintellisense.com`
   - Should redirect to GitHub OAuth
   - Login with your GitHub account (MateoSudo)

3. **Verify runner connection**:
   - In Drone UI, go to Settings → Runners
   - Should see "podman-runner" as active

## Usage

### Setting Up a Repository
1. **In Drone Web Interface**:
   - Click "Sync" to refresh repository list
   - Find your repository and click "Activate"
   - Configure repository settings as needed

2. **Add `.drone.yml` to your repository**:
   ```yaml
   kind: pipeline
   type: docker
   name: default

   steps:
     - name: test
       image: alpine:latest
       commands:
         - echo "Hello from Drone CI/CD!"
         - echo "Running on $(hostname)"
   
     - name: deploy
       image: alpine:latest
       commands:
         - echo "Deploying application..."
         # Add your deployment commands here
       when:
         branch:
           - main
   ```

### Container Deployment in Pipelines
The runner has access to the Podman socket, enabling container deployments:

```yaml
steps:
  - name: deploy-container
    image: quay.io/podman/stable:latest
    volumes:
      - name: podman-socket
        path: /var/run/docker.sock
    commands:
      - podman run -d --name myapp -p 8090:80 nginx:alpine
      - podman ps
    when:
      branch:
        - main

volumes:
  - name: podman-socket
    host:
      path: /var/run/docker.sock
```

## Troubleshooting

### Common Issues

1. **Drone server not accessible via HTTPS**:
   - Check Cosmos OS proxy configuration
   - Verify Cloudflare DNS resolution
   - Check wildcard certificate validity

2. **Runner not connecting to server**:
   ```bash
   # Check runner logs
   podman-compose logs drone-runner
   
   # Verify RPC secret matches
   podman-compose exec drone-server env | grep DRONE_RPC_SECRET
   podman-compose exec drone-runner env | grep DRONE_RPC_SECRET
   ```

3. **Container deployment fails in pipelines**:
   ```bash
   # Check Podman socket permissions
   ls -la /run/podman/podman.sock
   
   # Test socket access from runner
   podman-compose exec drone-runner podman ps
   ```

4. **GitHub OAuth issues**:
   - Verify OAuth app callback URL matches `https://drone.mrintellisense.com/login`
   - Check client ID and secret in `.env` file
   - Ensure DRONE_SERVER_HOST matches your domain

### Useful Commands

```bash
# View all logs
podman-compose logs -f

# Restart services
podman-compose restart

# Update containers
podman-compose pull
podman-compose up -d

# Clean up
podman-compose down
podman-compose down -v  # Also removes volumes

# Check service health
podman-compose exec drone-server wget -qO- http://localhost/healthz
```

## Security Considerations

1. **RPC Secret**: Keep `DRONE_RPC_SECRET` secure and unique
2. **GitHub Secrets**: Protect OAuth client ID and secret
3. **Privileged Access**: Runner has privileged access for container operations
4. **Socket Mounting**: Podman socket access enables full container management
5. **Network Isolation**: Services communicate over internal Docker network

## Backup and Maintenance

### Backup
```bash
# Backup Drone data
cp -r ./drone_server_data /backup/drone-$(date +%Y%m%d)

# Backup configuration
cp .env /backup/drone-env-$(date +%Y%m%d)
cp podman-compose.yml /backup/drone-compose-$(date +%Y%m%d)
```

### Updates
```bash
# Update container images
podman-compose pull

# Restart with new images
podman-compose up -d

# Clean up old images
podman image prune
```

## Support
For issues specific to this deployment, check:
1. Container logs: `podman-compose logs`
2. Cosmos OS proxy logs
3. Cloudflare DNS configuration
4. GitHub webhook delivery logs
