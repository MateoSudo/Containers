#!/bin/bash

# Torrent Media Stack Deployment Script
echo "🚀 Starting Torrent Media Stack deployment..."

# Ensure we're in the right directory
cd "$(dirname "$0")"

# Stop any existing containers with our naming convention
echo "Stopping existing containers..."
docker stop qbittorrent sonarr radarr lidarr prowlarr jellyfin pia-vpn 2>/dev/null || true
docker rm qbittorrent sonarr radarr lidarr prowlarr jellyfin pia-vpn 2>/dev/null || true

# Create necessary directories
echo "Creating media directories..."
sudo mkdir -p /mnt/truenas/{downloads/{complete,incomplete},torrents,media/{tv,movies,music}}
sudo chown -R 1000:1000 /mnt/truenas/
sudo chmod -R 755 /mnt/truenas/

# Check if .env exists
if [ ! -f .env ]; then
    echo "Creating .env from template..."
    cp .env.example .env
    echo "⚠️  Please edit .env with your PIA credentials!"
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

echo "✅ Torrent Media Stack deployed successfully!"
echo ""
echo "🌐 Services available via Cosmos Cloud proxy:"
echo "   - QBittorrent: Via VPN (configure in Cosmos as qbittorrent:8083)"
echo "   - Sonarr: Configure in Cosmos as sonarr:8989"
echo "   - Radarr: Configure in Cosmos as radarr:7878"  
echo "   - Lidarr: Configure in Cosmos as lidarr:8686"
echo "   - Prowlarr: Configure in Cosmos as prowlarr:9696"
echo "   - Jellyfin: Configure in Cosmos as jellyfin:8096"
echo ""
echo "🔧 Cosmos Cloud Configuration:"
echo "   - Container: jellyfin, Port: 8096, Domain: jellyfin.mrintellisense.com"
echo "   - Container: sonarr, Port: 8989, Domain: sonarr.mrintellisense.com"
echo "   - Container: radarr, Port: 7878, Domain: radarr.mrintellisense.com"
echo "   - And so on for each service..."
