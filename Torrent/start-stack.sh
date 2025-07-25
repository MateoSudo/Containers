!/bin/bash

# Torrent Media Stack Deployment Script
echo "[INFO] Starting Torrent Media Stack deployment..."

# Ensure we're in the right directory
cd "$(dirname "$0")"

# Stop any existing stack
echo "Stopping existing stack..."
if [ -f docker-compose.yml ]; then
    docker compose down --remove-orphans 2>/dev/null || echo "No existing stack found"
else
    # Fallback to individual container cleanup
    docker stop qbittorrent sonarr radarr lidarr prowlarr jellyfin pia-vpn 2>/dev/null || true
    docker rm qbittorrent sonarr radarr lidarr prowlarr jellyfin pia-vpn 2>/dev/null || true
fi

# Create necessary directories
echo "Creating media directories..."
sudo mkdir -p /mnt/truenas/{downloads,media/{tv,movies,music}}
sudo chown -R 1000:1000 /mnt/truenas/
sudo chmod -R 755 /mnt/truenas/

# Check if .env exists
if [ ! -f .env ]; then
    echo "Creating .env from template..."
    cp .env.example .env
    echo "[WARNING] Please edit .env with your PIA credentials!"
fi

# Start the stack with Docker Compose
echo "Starting Torrent Media Stack..."
if command -v docker &> /dev/null; then
    # Use docker compose (modern syntax)
    docker compose up -d
else
    echo "Docker not found, please install Docker"
    exit 1
fi

echo "[SUCCESS] Torrent Media Stack deployed successfully!"
echo ""
<<<<<<< HEAD
echo "[INFO] Services available via Cosmos Cloud proxy only:"
echo "   - QBittorrent: http://localhost:8083 (direct access via VPN)"
echo "   - All other services: Internal only, accessible via Cosmos Cloud"
echo ""
echo "[INFO] Cosmos Cloud Configuration (hostname-based):"
echo "   - Jellyfin:  Container: jellyfin,  Port: 8096, Domain: jellyfin.mrintellisense.com"
echo "   - Sonarr:    Container: sonarr,    Port: 8989, Domain: sonarr.mrintellisense.com"
echo "   - Radarr:    Container: radarr,    Port: 7878, Domain: radarr.mrintellisense.com"
echo "   - Lidarr:    Container: lidarr,    Port: 8686, Domain: lidarr.mrintellisense.com"
echo "   - Prowlarr:  Container: prowlarr,  Port: 9696, Domain: prowlarr.mrintellisense.com"
echo "   - QBittorrent: Container: pia-vpn, Port: 8083, Domain: qbittorrent.mrintellisense.com"
echo ""
echo "[INFO] Network: All services on media-network (172.20.0.0/16)"
echo "[INFO] Security: Only QBittorrent port exposed to host, all others internal-only"
=======
echo "🌐 Services available at:"
echo "   - QBittorrent: http://localhost:8083"
echo "   - Sonarr: http://localhost:8989"
echo "   - Radarr: http://localhost:7878"
echo "   - Lidarr: http://localhost:8686"
echo "   - Prowlarr: http://localhost:9696"
echo "   - Jellyfin: http://localhost:8096"
>>>>>>> feature/drone-podman-integration
