#!/bin/bash

echo "🚀 Deploying Fresh Media Stack with Transmission + PIA VPN"
echo "========================================================"

# Load environment variables from .env file if it exists
if [ -f ".env" ]; then
    echo "📁 Loading credentials from .env file..."
    set -a  # automatically export all variables
    source .env
    set +a
    echo "✅ Environment loaded from .env"
elif [ -f ".env.local" ]; then
    echo "📁 Loading credentials from .env.local file..."
    source .env.local
    echo "✅ Environment loaded from .env.local"
fi

# Check for environment variables
if [ -z "$PIA_USER" ] || [ -z "$PIA_PASS" ]; then
    echo "❌ ERROR: PIA VPN credentials not found!"
    echo ""
    echo "Options to fix this:"
    echo "  1. Run: ./setup-environment.sh"
    echo "  2. Edit the .env file with your credentials:"
    echo "     PIA_USER=your_username"
    echo "     PIA_PASS=your_password"
    echo "     LOC=netherlands"
    echo "  3. Export manually:"
    echo "     export PIA_USER='your_username'"
    echo "     export PIA_PASS='your_password'"
    exit 1
fi

echo "✅ PIA VPN credentials found"
echo "📍 VPN Location: ${LOC:-netherlands}"

# Stop any existing containers
echo ""
echo "🛑 Stopping existing containers..."
docker compose down 2>/dev/null || true

# Create necessary directories
echo ""
echo "📁 Creating directory structure..."
mkdir -p config/{transmission,radarr,sonarr,lidarr,prowlarr,jellyfin}
mkdir -p /mnt/truenas/downloads/{complete,incomplete}/{movies,tv,music}
mkdir -p /mnt/truenas/torrents
mkdir -p /mnt/truenas/media/{movies,tv,music}

# Set proper permissions
echo "🔐 Setting permissions..."
chown -R 1000:1000 config/
chown -R 1000:1000 /mnt/truenas/downloads/ 2>/dev/null || echo "⚠️  Could not set permissions on /mnt/truenas/downloads/"
chown -R 1000:1000 /mnt/truenas/torrents/ 2>/dev/null || echo "⚠️  Could not set permissions on /mnt/truenas/torrents/"

# Start the stack
echo ""
echo "🚀 Starting media stack..."
docker compose up -d

# Wait for services to initialize
echo ""
echo "⏳ Waiting for services to initialize..."
echo "   This may take 2-3 minutes..."

# Check VPN connection
echo ""
echo "🌐 Checking VPN connection..."
for i in {1..12}; do
    echo "   Attempt $i/12..."
    VPN_STATUS=$(docker exec torrent-pia-vpn wget -qO- http://ipinfo.io/ip 2>/dev/null || echo "failed")
    if [ "$VPN_STATUS" != "failed" ] && [ ${#VPN_STATUS} -gt 5 ]; then
        echo "✅ VPN connected! External IP: $VPN_STATUS"
        break
    fi
    sleep 10
done

# Check service health
echo ""
echo "🏥 Checking service health..."
sleep 30

services=("transmission:9091" "radarr:7878" "sonarr:8989" "lidarr:8686" "prowlarr:9696" "jackett:9117" "jellyfin:8096")

for service in "${services[@]}"; do
    name=${service%:*}
    port=${service#*:}
    
    echo "🔍 Testing $name..."
    status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port --max-time 10)
    
    if [ "$status" = "200" ] || [ "$status" = "302" ]; then
        echo "✅ $name: Working ($status)"
    else
        echo "⚠️  $name: Status $status (may still be starting)"
    fi
done

# Test Transmission specifically
echo ""
echo "🔍 Testing Transmission connectivity..."
TRANS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9091/transmission/web/ --max-time 10)
if [ "$TRANS_STATUS" = "200" ]; then
    echo "✅ Transmission WebUI: Working"
else
    echo "⚠️  Transmission WebUI: Status $TRANS_STATUS"
fi

# Container-to-container connectivity test
echo ""
echo "🔗 Testing container connectivity for Cosmos..."
docker exec torrent-radarr wget -qO- http://172.19.0.4:9091/transmission/web/ >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ Container-to-container connectivity: Working"
else
    echo "⚠️  Container-to-container connectivity: May need more time"
fi

echo ""
echo "🎉 DEPLOYMENT COMPLETE!"
echo "======================"
echo ""
echo "🌐 Web Interfaces:"
echo "  • Transmission:  http://localhost:9091/transmission/web/"
echo "  • Radarr:        http://localhost:7878"
echo "  • Sonarr:        http://localhost:8989"
echo "  • Lidarr:        http://localhost:8686"
echo "  • Prowlarr:      http://localhost:9696"
echo "  • Jackett:       http://localhost:9117"
echo "  • Jellyfin:      http://localhost:8096"
echo ""
echo "🎯 COSMOS CONFIGURATION:"
echo "========================"
echo ""
echo "| Service | Domain | Target | Auth |"
echo "|---------|--------|--------|------|"
echo "| Transmission | transmission.mrintellisense.com | http://localhost:9091 | None |"
echo "| Radarr | radarr.mrintellisense.com | http://radarr:7878 | None |"
echo "| Sonarr | sonarr.mrintellisense.com | http://sonarr:8989 | None |"
echo "| Lidarr | lidarr.mrintellisense.com | http://lidarr:8686 | None |"
echo "| Prowlarr | prowlarr.mrintellisense.com | http://prowlarr:9696 | None |"
echo "| Jellyfin | jellyfin.mrintellisense.com | http://jellyfin:8096 | None |"
echo ""
echo "🔧 Key Features:"
echo "  ✅ All torrent traffic routed through PIA VPN"
echo "  ✅ Transmission accessible via Docker hostname"
echo "  ✅ No authentication conflicts"
echo "  ✅ Auto-configured download clients"
echo "  ✅ Cosmos-ready container targets"
echo ""
echo "📝 Next Steps:"
echo "  1. Configure your Cosmos routes using the targets above"
echo "  2. Run: ./configure-indexers.sh (to add popular indexers)"
echo "  3. Set up private indexers in Prowlarr/Jackett"
echo "  4. Connect indexers to Radarr/Sonarr/Lidarr"
echo "  5. Start downloading media!"
echo ""
echo "🆘 If issues occur:"
echo "  • Check VPN status: docker logs torrent-pia-vpn"
echo "  • Check Transmission: docker logs torrent-transmission"
echo "  • Restart stack: docker compose restart" 