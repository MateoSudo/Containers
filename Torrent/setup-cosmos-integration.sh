#!/bin/bash

echo "🚀 Cosmos Integration Setup"
echo "=========================="
echo ""

# Check if we're running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root"
   exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📋 Step 1: Checking current setup..."
echo "====================================="

# Check if Cosmos is running
if pgrep -x "cosmos" > /dev/null; then
    echo "✅ Cosmos is running"
    echo "   - Port 80: HTTP"
    echo "   - Port 443: HTTPS"
    echo "   - UI: https://localhost/cosmos-ui/"
else
    echo "❌ Cosmos is not running"
    echo "   Please start Cosmos first"
    exit 1
fi

# Check current containers
echo ""
echo "📋 Current containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep torrent

echo ""
echo "📋 Step 2: Switching to Cosmos-compatible configuration..."
echo "=========================================================="

# Backup current compose file
if [ -f "docker-compose.yml" ]; then
    cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ Backed up current docker-compose.yml"
fi

# Use the Cosmos-compatible version
cp docker-compose-cosmos.yml docker-compose.yml
echo "✅ Applied Cosmos-compatible configuration"

echo ""
echo "📋 Step 3: Stopping current containers..."
docker compose down

echo ""
echo "📋 Step 4: Starting containers with Cosmos routing..."
docker compose up -d

echo ""
echo "📋 Step 5: Waiting for containers to start..."
sleep 10

echo ""
echo "📋 Step 6: Checking container status..."
docker compose ps

echo ""
echo "🎉 Cosmos Integration Setup Complete!"
echo "===================================="
echo ""
echo "📋 Next Steps for Cosmos Configuration:"
echo "======================================="
echo ""
echo "1. Open Cosmos UI: https://localhost/cosmos-ui/"
echo ""
echo "2. Add these applications to Cosmos:"
echo "   • Sonarr:    172.19.0.5:8989"
echo "   • Radarr:    172.19.0.6:7878"
echo "   • Lidarr:    172.19.0.7:8686"
echo "   • Prowlarr:  172.19.0.9:9696"
echo "   • Jackett:   172.19.0.10:9117"
echo "   • Jellyfin:  172.19.0.8:8096"
echo "   • Transmission: 172.19.0.4:9091"
echo ""
echo "3. Configure domains in Cosmos:"
echo "   • sonarr.mrintellisense.com"
echo "   • radarr.mrintellisense.com"
echo "   • lidarr.mrintellisense.com"
echo "   • prowlarr.mrintellisense.com"
echo "   • jackett.mrintellisense.com"
echo "   • jellyfin.mrintellisense.com"
echo "   • transmission.mrintellisense.com"
echo ""
echo "4. Enable authentication in Cosmos for each app"
echo ""
echo "📋 Benefits of Cosmos Integration:"
echo "=================================="
echo "✅ Single sign-on across all services"
echo "✅ Automatic SSL certificates"
echo "✅ Centralized authentication"
echo "✅ Clean URLs (no port numbers)"
echo "✅ Built-in security features"
echo "✅ Easy management through Cosmos UI"
echo ""
echo "🌐 Access your services through Cosmos:"
echo "======================================"
echo "• https://sonarr.mrintellisense.com"
echo "• https://radarr.mrintellisense.com"
echo "• https://lidarr.mrintellisense.com"
echo "• https://prowlarr.mrintellisense.com"
echo "• https://jackett.mrintellisense.com"
echo "• https://jellyfin.mrintellisense.com"
echo "• https://transmission.mrintellisense.com"
echo ""
echo "📝 Notes:"
echo "========="
echo "• All containers now run without direct port exposure"
echo "• Cosmos handles all routing and SSL termination"
echo "• VPN ports (51413, 8888, 8388) remain exposed for torrent traffic"
echo "• Static IPs are preserved for internal communication"
echo ""
echo "🔧 Troubleshooting:"
echo "==================="
echo "• Check Cosmos logs: journalctl -u cosmos"
echo "• Check container logs: docker compose logs [service-name]"
echo "• Verify network connectivity: docker network inspect media_network"
echo ""
echo "✅ Setup complete! Configure Cosmos UI to start using SSO." 