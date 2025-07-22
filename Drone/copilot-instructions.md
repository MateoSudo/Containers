# Drone CI/CD Deployment Instructions

## Project Overview
This subdirectory deploys Drone CI/CD in Docker containers on a Debian Proxmox LXC environment. The setup includes:

- **Host Environment**: Debian Proxmox LXC with Docker runtime
- **Networking**: Cloudflare DNS with wildcard Let's Encrypt certificates (*.mrintellisense.com)
- **Proxy Setup**: Cosmos Cloud routes external traffic to Docker containers
- **CI/CD Capability**: Drone server + runner with container deployment using Docker
- **Container Runtime**: Docker with socket access for CI/CD pipeline deployments
- **Service Discovery**: Docker's embedded DNS for inter-container communication

## Architecture
```
Internet → Cloudflare DNS → DMZ Static IP → Cosmos Cloud → Docker Network → Drone Server
                                                       → Docker DNS → Drone Runner → Docker Socket → Container Deployments
```

## Key Configuration Points

### Environment Variables (.env)
- `DRONE_SERVER_HOST=drone.mrintellisense.com` - Matches Cloudflare DNS subdomain
- `DRONE_SERVER_PROTO=https` - Cosmos Cloud handles SSL termination with Let's Encrypt
- `DRONE_RPC_HOST=drone-server:8082` - Uses Docker's embedded DNS for service discovery
- `DRONE_RPC_SECRET` - Secure communication between server/runner
- `DRONE_GITHUB_CLIENT_ID/SECRET` - OAuth integration for repository access
- `DRONE_USER_CREATE=username:MateoSudo,admin:true` - Admin user setup

### Cosmos Cloud Integration
- Configure in Cosmos Cloud dashboard: `drone.mrintellisense.com` → `http://drone-server:8082`
- Automatic SSL with Cosmos Cloud's Let's Encrypt integration
- Wildcard certificate `*.mrintellisense.com` managed by Cosmos Cloud
- Docker service discovery via container names and ports
- No manual proxy configuration in containers - Cosmos handles routing

### Docker Socket Access
- Runner requires `/var/run/docker.sock` access for container deployment
- Privileged mode ensures full container management capabilities
- Docker-in-Docker (DinD) capability for isolated build environments
- Network sharing for deployed containers

## Development Guidelines

### When Creating Configuration Files:
1. **Always use inline comments** explaining each configuration option
2. **Reference .env variables** specifically (e.g., `${DRONE_SERVER_HOST}`)
3. **Use Docker service names** for inter-container communication (e.g., `drone-server`)
4. **Document security implications** of privileged access and socket mounting
5. **Explain Cosmos Cloud proxy integration** for external access and SSL termination
6. **Include health checks** for service reliability
7. **Document scaling considerations** for production use
8. **Configure for Cosmos Cloud discovery** - expose ports without host binding

### Container Deployment Strategy:
- Use `docker-compose.yml` for service orchestration
- Mount Docker socket for CI/CD container deployment capabilities
- Configure Docker networks for internal service communication
- Ensure runner can deploy containers using Docker during pipeline execution
- Leverage Docker's embedded DNS for service discovery
- **Cosmos Cloud Integration**: Services exposed only to Cosmos Cloud proxy

### Security Considerations:
- RPC secret provides secure server/runner communication
- GitHub OAuth limits repository access to authorized users
- Privileged container access required for full CI/CD functionality
- Socket mounting enables container deployment but requires careful security review
- Docker network isolation for service segmentation
- **Cosmos Cloud Security**: External access only through authenticated proxy

### Networking Setup:
- Custom Docker network for Drone components communication
- Docker's embedded DNS resolves service names (drone-server, drone-runner)
- Cosmos Cloud integration for external access with automatic SSL
- **No host port binding** - Cosmos Cloud discovers services via Docker API
- DNS resolution through Cloudflare for `drone.mrintellisense.com`
- Internal Docker networking only - external access via Cosmos Cloud

### Docker DNS Resolution:
- **Server-Runner Communication**: `DRONE_RPC_HOST=drone-server:8082`
- **Database Access**: `database:5432` (if using external database)
- **Service Discovery**: Automatic via Docker's embedded DNS
- **Network Aliases**: Use service names defined in docker-compose.yml
- **Cosmos Cloud Access**: Routes to `http://drone-server:8082` internally

## File Structure
```
Drone/
├── .env                    # Environment variables and secrets
├── docker-compose.yml      # Main deployment configuration
├── copilot-instructions.md # This file - development guidelines
└── README.md              # User documentation and setup guide
```

## Container Communication Examples
```yaml
# In docker-compose.yml
services:
  drone-server:
    # Server accessible internally at: drone-server:8082
    # External access via: https://drone.mrintellisense.com (Cosmos Cloud)
    ports:
      - "8082"  # Expose to Docker network only
  
  drone-runner:
    environment:
      - DRONE_RPC_HOST=drone-server:8082  # Uses Docker DNS
```

## Cosmos Cloud Configuration
- **Service Discovery**: Cosmos Cloud automatically detects Docker containers
- **Proxy Route**: `drone.mrintellisense.com` → `http://drone-server:8082`
- **SSL Termination**: Automatic wildcard certificate management
- **Authentication**: Optional authentication layers via Cosmos Cloud
- **Health Checks**: Cosmos Cloud monitors container health

## Next Steps for Development
1. Ensure docker-compose.yml exposes ports without host binding for Cosmos Cloud
2. Create health checks for all services using Docker's health check syntax
3. Configure Cosmos Cloud routes in the dashboard for `drone.mrintellisense.com`
4. Test container deployment capabilities through CI/CD pipelines using Docker
5. Implement proper secret management using Docker secrets
6. Configure Docker networks for service isolation and communication
7. Verify Cosmos Cloud SSL certificate management for wildcard domains
8. Set up Cosmos Cloud authentication if required for admin access