#!/bin/bash

# Torrent Media Stack Deployment Script
echo "🚀 Starting Torrent Media Stack deployment..."

# Ensure we're in the right directory
cd "$(dirname "$0")"

# Stop any existing containers with our naming convention
echo "Stopping existing containers..."
docker stop torrent-qbittorrent torrent-sonarr torrent-radarr torrent-lidarr torrent-prowlarr torrent-jellyfin torrent-pia-vpn torrent-qbittorrent-proxy 2>/dev/null || true
docker rm torrent-qbittorrent torrent-sonarr torrent-radarr torrent-lidarr torrent-prowlarr torrent-jellyfin torrent-pia-vpn torrent-qbittorrent-proxy 2>/dev/null || true

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

# Start the stack with named containers
echo "Starting Torrent Media Stack..."
if command -v docker &> /dev/null; then
    # Use docker compose
    docker compose up -d
else
    echo "docker not found, please install it"
    exit 1
fi

echo "✅ Torrent Media Stack deployed successfully!"
echo ""
echo "🌐 Services available at:"
echo "   - QBittorrent: http://localhost:8083"
echo "   - Sonarr: http://localhost:8989"
echo "   - Radarr: http://localhost:7878"
echo "   - Lidarr: http://localhost:8686"
echo "   - Prowlarr: http://localhost:9696"
echo "   - Jellyfin: http://localhost:8096"
