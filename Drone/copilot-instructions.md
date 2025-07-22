# Drone CI/CD Deployment Instructions

## Project Overview
This subdirectory deploys Drone CI/CD in Podman containers on a Debian Proxmox LXC environment. The setup includes:

- **Host Environment**: Debian Proxmox LXC with privileged Cosmos OS
- **Networking**: Cloudflare DNS with wildcard Let's Encrypt certificates (*.mrintellisense.com)
- **Proxy Setup**: Cosmos OS routes external traffic to http://localhost:port
- **CI/CD Capability**: Drone server + runner with container deployment on localhost
- **Container Runtime**: Podman with socket access for CI/CD pipeline deployments

## Architecture
```
Internet → Cloudflare DNS → DMZ Static IP → Cosmos OS Proxy → http://localhost:8080 → Drone Server
                                                           → Drone Runner → Podman Socket → Container Deployments
```

## Key Configuration Points

### Environment Variables (.env)
- `DRONE_SERVER_HOST=drone.mrintellisense.com` - Matches Cloudflare DNS subdomain
- `DRONE_SERVER_PROTO=http` - Cosmos OS handles HTTPS termination
- `DRONE_RPC_SECRET` - Secure communication between server/runner
- `DRONE_GITHUB_CLIENT_ID/SECRET` - OAuth integration for repository access
- `DRONE_USER_CREATE=username:MateoSudo,admin:true` - Admin user setup

### Cosmos OS Integration
- Configure proxy: `drone.mrintellisense.com` → `http://localhost:8080`
- Wildcard certificate `*.mrintellisense.com` must cover drone subdomain
- No SSL termination needed in containers (Cosmos handles HTTPS)

### Podman Socket Access
- Runner requires `/run/podman/podman.sock` access for container deployment
- Privileged mode ensures full container management capabilities
- Alternative symlink: `/var/run/docker.sock` → `/run/podman/podman.sock`

## Development Guidelines

### When Creating Configuration Files:
1. **Always use inline comments** explaining each configuration option
2. **Reference .env variables** specifically (e.g., `${DRONE_SERVER_HOST}`)
3. **Document security implications** of privileged access and socket mounting
4. **Explain Cosmos OS proxy integration** for external access
5. **Include health checks** for service reliability
6. **Document scaling considerations** for production use

### Container Deployment Strategy:
- Use `podman-compose.yml` for service orchestration
- Mount Podman socket for CI/CD container deployment capabilities
- Configure internal networking between Drone components
- Ensure runner can deploy containers on localhost during pipeline execution

### Security Considerations:
- RPC secret provides secure server/runner communication
- GitHub OAuth limits repository access to authorized users
- Privileged container access required for full CI/CD functionality
- Socket mounting enables container deployment but requires careful security review

### Networking Setup:
- Internal `drone-net` network for component communication
- Port 8080 exposure for Cosmos OS proxy integration
- No direct external port binding (handled by Cosmos OS)
- DNS resolution through Cloudflare for `drone.mrintellisense.com`

## File Structure
```
Drone/
├── .env                    # Environment variables and secrets
├── podman-compose.yml      # Main deployment configuration
├── copilot-instructions.md # This file - development guidelines
└── README.md              # User documentation and setup guide
```

## Next Steps for Development
1. Ensure podman-compose.yml includes comprehensive inline documentation
2. Create health checks for all services
3. Document Cosmos OS proxy configuration requirements
4. Test container deployment capabilities through CI/CD pipelines
5. Implement proper secret management for production use