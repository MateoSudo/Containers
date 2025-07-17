#!/bin/bash

# Media Stack Setup Script for Podman Compose
echo "Setting up Media Stack with Podman Compose..."

# Create necessary directories on TrueNAS mount
echo "Creating media directories on TrueNAS..."
sudo mkdir -p /mnt/truenas/{downloads/{complete,incomplete},torrents,media/{tv,movies,music}}

#Set proper permissions (adjust UID/GID as needed - 1000:1000 is common)
echo "Setting permissions..."
sudo chown -R 1000:1000 /mnt/truenas/
sudo chmod -R 755 /mnt/truenas/

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo ""
    echo "⚠️  IMPORTANT: Please edit .env file with your PIA credentials before starting!"
    echo "Edit command: nano .env"
    echo ""
else
    echo ".env file already exists"
fi

# Check if podman-compose is installed
if ! command -v podman-compose &> /dev/null; then
    echo "podman-compose is not installed. You can install it with:"
    echo "pip3 install podman-compose"
    echo "or"
    echo "sudo dnf install podman-compose  # On Fedora/RHEL"
    echo "sudo apt install podman-compose  # On Ubuntu/Debian"
fi

echo ""
echo "📁 Directory structure created:"
echo "   /mnt/truenas/downloads/ - QBittorrent downloads"
echo "   /mnt/truenas/media/tv/ - TV shows library"
echo "   /mnt/truenas/media/movies/ - Movies library"
echo "   /mnt/truenas/media/music/ - Music library"
echo ""
echo "🚀 Next steps:"
echo "1. Edit .env file with your PIA credentials: nano .env"
echo "2. Timezone is set to America/Chicago (Central Time)"
echo "3. Start the stack: podman-compose up -d"
echo ""
echo "🌐 Services will be available at:"
echo "   - QBittorrent Web UI: http://localhost:8080"
echo "   - Sonarr (TV): http://localhost:8989"
echo "   - Radarr (Movies): http://localhost:7878"
echo "   - Lidarr (Music): http://localhost:8686"
echo "   - Prowlarr (Indexers): http://localhost:9696"
echo "   - Jellyfin (Media Server): http://localhost:8096"
echo ""
echo "📖 Default QBittorrent login: admin/adminadmin (change after first login)"
echo ""
echo "🔧 For Drone CI/CD integration in subfolders:"
echo "   Create .drone.yml in each subfolder with path-based triggers"
echo "   Example: see DRONE_SUBFOLDER_GUIDE.md"
