#!/bin/bash

echo "🔒 Deploying Stack with VPN-Enabled Indexers"
echo "============================================="

# Load environment variables
if [ -f .env ]; then
    echo "📄 Loading .env file..."
    source .env
elif [ -f .env.local ]; then
    echo "📄 Loading .env.local file..."
    source .env.local
else
    echo "⚠️  No .env file found. Please run setup-environment.sh first."
    exit 1
fi

# Verify PIA credentials
if [ -z "$PIA_USER" ] || [ -z "$PIA_PASS" ]; then
    echo "❌ PIA credentials not found in environment variables"
    echo "Please run: ./setup-environment.sh"
    exit 1
fi

echo "✅ PIA credentials loaded: $PIA_USER"

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker compose down

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p config/{transmission,radarr,sonarr,lidarr,prowlarr,jackett,jellyfin}
mkdir -p /mnt/truenas/downloads/{complete/{movies,tv,music},incomplete}
mkdir -p /mnt/truenas/media/{movies,tv,music}

# Set permissions
echo "🔐 Setting permissions..."
chown -R 1000:1000 config/
chown -R 1000:1000 /mnt/truenas/downloads/
chown -R 1000:1000 /mnt/truenas/media/

# Start the stack
echo "🚀 Starting stack with VPN-enabled indexers..."
docker compose up -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 30

# Health checks
echo "🔍 Performing health checks..."

# Check VPN container
echo "🔒 Checking PIA VPN..."
if docker exec torrent-pia-vpn wget -q -O - http://localhost:8000/v1/openvpn/status >/dev/null 2>&1; then
    echo "✅ PIA VPN: Connected and healthy"
else
    echo "❌ PIA VPN: Not responding"
fi

# Check Transmission
echo "⬇️  Checking Transmission..."
if curl -s http://localhost:9091/transmission/web/ >/dev/null 2>&1; then
    echo "✅ Transmission: WebUI accessible"
else
    echo "❌ Transmission: WebUI not accessible"
fi

# Check Prowlarr (now through VPN)
echo "🔍 Checking Prowlarr (VPN-enabled)..."
if curl -s http://localhost:9696 >/dev/null 2>&1; then
    echo "✅ Prowlarr: WebUI accessible through VPN"
else
    echo "❌ Prowlarr: WebUI not accessible"
fi

# Check Jackett (now through VPN)
echo "🔍 Checking Jackett (VPN-enabled)..."
if curl -s http://localhost:9117 >/dev/null 2>&1; then
    echo "✅ Jackett: WebUI accessible through VPN"
else
    echo "❌ Jackett: WebUI not accessible"
fi

# Check *arr services
for service in radarr sonarr lidarr; do
    port=$(case $service in radarr) echo 7878;; sonarr) echo 8989;; lidarr) echo 8686;; esac)
    if curl -s http://localhost:$port >/dev/null 2>&1; then
        echo "✅ $service: WebUI accessible"
    else
        echo "❌ $service: WebUI not accessible"
    fi
done

echo ""
echo "🎉 VPN-Enabled Indexer Deployment Complete!"
echo "=========================================="
echo ""
echo "🌐 Access your services:"
echo "   • Radarr:   http://localhost:7878"
echo "   • Sonarr:   http://localhost:8989"
echo "   • Lidarr:   http://localhost:8686"
echo "   • Prowlarr: http://localhost:9696 (VPN-enabled)"
echo "   • Jackett:  http://localhost:9117 (VPN-enabled)"
echo "   • Transmission: http://localhost:9091/transmission/web/"
echo ""
echo "🔒 VPN Benefits:"
echo "   • Prowlarr bypasses Cloudflare DNS blocks"
echo "   • Jackett bypasses Cloudflare DNS blocks"
echo "   • All indexer traffic routed through PIA VPN"
echo "   • Enhanced privacy and access to blocked sites"
echo ""
echo "📋 Next Steps:"
echo "   1. Configure indexers in Prowlarr/Jackett"
echo "   2. Add root folders in *arr services"
echo "   3. Test search functionality"
echo "   4. Start downloading media!"
echo ""
echo "🔧 Configuration Scripts:"
echo "   • ./configure-indexers.sh - Add popular indexers"
echo "   • ./fix-arr-services.sh - Configure download clients"
echo "   • ./setup-radarr-folders.sh - Set up root folders" 