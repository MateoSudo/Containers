# Cosmos Integration for Media Stack

This guide explains how to integrate your media stack with **Cosmos** for centralized authentication, SSL termination, and single sign-on (SSO).

## What is Cosmos?

**Cosmos** is a reverse proxy and application management platform that provides:
- 🔐 **Built-in authentication** (no need for Keycloak)
- 🔒 **Automatic SSL certificates** via Let's Encrypt
- 🌐 **Clean domain routing** (no port numbers)
- 📱 **Web-based management UI**
- 🛡️ **Security features** and access control

## Current Setup vs Cosmos Integration

### Current Setup (Direct Access)
```
http://localhost:7878  → Radarr
http://localhost:8989  → Sonarr
http://localhost:9696  → Prowlarr
http://localhost:8096  → Jellyfin
http://localhost:8686  → Lidarr
http://localhost:9117  → Jackett
http://localhost:9091  → Transmission
```

### Cosmos Integration (Clean URLs)
```
https://radarr.mrintellisense.com     → Radarr
https://sonarr.mrintellisense.com     → Sonarr
https://prowlarr.mrintellisense.com   → Prowlarr
https://jellyfin.mrintellisense.com   → Jellyfin
https://lidarr.mrintellisense.com     → Lidarr
https://jackett.mrintellisense.com    → Jackett
https://transmission.mrintellisense.com → Transmission
```

## Benefits of Cosmos Integration

✅ **Single Sign-On**: One login for all services  
✅ **Automatic SSL**: HTTPS certificates managed by Cosmos  
✅ **Clean URLs**: No port numbers in addresses  
✅ **Centralized Management**: All apps in one dashboard  
✅ **Security**: Built-in authentication and access control  
✅ **Easy Setup**: No complex OAuth/Keycloak configuration  

## Quick Setup

### 1. Run the Integration Script
```bash
chmod +x setup-cosmos-integration.sh
sudo ./setup-cosmos-integration.sh
```

### 2. Access Cosmos UI
Open your browser and go to: **https://localhost/cosmos-ui/**

### 3. Add Applications to Cosmos
In the Cosmos UI, add these applications:

| Service | Internal IP | Port | Domain |
|---------|-------------|------|--------|
| **Sonarr** | 172.19.0.5 | 8989 | sonarr.mrintellisense.com |
| **Radarr** | 172.19.0.6 | 7878 | radarr.mrintellisense.com |
| **Lidarr** | 172.19.0.7 | 8686 | lidarr.mrintellisense.com |
| **Prowlarr** | 172.19.0.9 | 9696 | prowlarr.mrintellisense.com |
| **Jackett** | 172.19.0.10 | 9117 | jackett.mrintellisense.com |
| **Jellyfin** | 172.19.0.8 | 8096 | jellyfin.mrintellisense.com |
| **Transmission** | 172.19.0.4 | 9091 | transmission.mrintellisense.com |

### 4. Configure Authentication
For each application in Cosmos:
1. Enable authentication
2. Set up user accounts
3. Configure access permissions

## Manual Setup (Alternative)

If you prefer manual setup:

### 1. Switch to Cosmos Configuration
```bash
# Backup current setup
cp docker-compose.yml docker-compose.yml.backup

# Use Cosmos-compatible version
cp docker-compose-cosmos.yml docker-compose.yml

# Restart containers
docker compose down
docker compose up -d
```

### 2. Configure Cosmos Applications
In Cosmos UI, add each application with:
- **Name**: Service name (e.g., "Sonarr")
- **URL**: Internal IP and port (e.g., "172.19.0.5:8989")
- **Domain**: Your domain (e.g., "sonarr.mrintellisense.com")
- **Authentication**: Enable and configure

## Network Configuration

### Static IPs (Preserved)
All containers maintain their static IPs for internal communication:

| Container | IP Address | Purpose |
|-----------|------------|---------|
| **PIA VPN** | 172.19.0.4 | VPN routing |
| **Sonarr** | 172.19.0.5 | TV management |
| **Radarr** | 172.19.0.6 | Movie management |
| **Lidarr** | 172.19.0.7 | Music management |
| **Jellyfin** | 172.19.0.8 | Media server |
| **Prowlarr** | 172.19.0.9 | Indexer management |
| **Jackett** | 172.19.0.10 | Alternative indexer |

### Port Configuration
- **Web UIs**: No direct port exposure (handled by Cosmos)
- **VPN Ports**: Still exposed for torrent traffic
  - 51413: Transmission TCP/UDP
  - 8888: HTTP proxy
  - 8388: SOCKS5 proxy

## Troubleshooting

### Check Cosmos Status
```bash
# Check if Cosmos is running
pgrep -x "cosmos"

# Check Cosmos logs
journalctl -u cosmos -f
```

### Check Container Status
```bash
# View all containers
docker compose ps

# Check specific service logs
docker compose logs sonarr
docker compose logs radarr
```

### Network Connectivity
```bash
# Test internal connectivity
docker exec torrent-sonarr curl -s http://172.19.0.6:7878
docker exec torrent-radarr curl -s http://172.19.0.5:8989
```

### DNS Configuration
Ensure your domains point to your server:
```bash
# Test DNS resolution
nslookup sonarr.mrintellisense.com
nslookup radarr.mrintellisense.com
```

## Rollback (If Needed)

To revert to direct access:
```bash
# Restore original configuration
cp docker-compose.yml.backup docker-compose.yml

# Restart containers
docker compose down
docker compose up -d
```

## Security Considerations

### Cosmos Authentication
- ✅ Built-in user management
- ✅ Password policies
- ✅ Session management
- ✅ Access logging

### Network Security
- ✅ Containers not directly exposed
- ✅ Internal network isolation
- ✅ VPN traffic still protected
- ✅ SSL termination at Cosmos

### Best Practices
1. **Strong Passwords**: Use complex passwords for Cosmos users
2. **Regular Updates**: Keep Cosmos updated
3. **Access Logs**: Monitor access patterns
4. **Backup Configuration**: Backup Cosmos settings

## Advanced Configuration

### Custom Domains
You can use any domain structure:
```
https://tv.mrintellisense.com      → Sonarr
https://movies.mrintellisense.com  → Radarr
https://music.mrintellisense.com   → Lidarr
https://media.mrintellisense.com   → Jellyfin
```

### Load Balancing
Cosmos can handle multiple instances:
- Multiple Jellyfin instances
- Redundant indexers
- Failover configurations

### Monitoring
Integrate with monitoring tools:
- Prometheus metrics
- Grafana dashboards
- Health checks

## Support

### Common Issues
1. **Container not accessible**: Check Cosmos routing configuration
2. **SSL errors**: Verify domain DNS settings
3. **Authentication issues**: Check Cosmos user configuration
4. **Network connectivity**: Verify static IP assignments

### Logs Location
- **Cosmos logs**: `journalctl -u cosmos`
- **Container logs**: `docker compose logs [service]`
- **Network logs**: `docker network inspect media_network`

## Migration Checklist

- [ ] Backup current configuration
- [ ] Run Cosmos integration script
- [ ] Configure applications in Cosmos UI
- [ ] Set up authentication for each service
- [ ] Test all services via new URLs
- [ ] Update bookmarks and shortcuts
- [ ] Verify SSL certificates
- [ ] Test authentication flow
- [ ] Monitor for any issues

## Conclusion

Cosmos integration provides a much simpler and more secure approach than implementing Keycloak. You get:

- **Easier setup** (no OAuth complexity)
- **Built-in features** (SSL, auth, monitoring)
- **Better UX** (clean URLs, SSO)
- **Centralized management** (one dashboard)

The integration maintains all your existing functionality while adding enterprise-grade features through Cosmos's built-in capabilities. 