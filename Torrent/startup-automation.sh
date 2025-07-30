#!/bin/bash

echo "🚀 Container Startup Automation"
echo "=============================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root"
    exit 1
fi

# Get the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "📋 Step 1: Creating TUN device..."
if [ ! -e /dev/net/tun ]; then
    echo "Creating /dev/net/tun device..."
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
    echo "✅ TUN device created"
else
    echo "✅ TUN device already exists"
fi

echo ""
echo "📋 Step 2: Waiting for Docker to be ready..."
# Wait for Docker daemon to be ready
timeout=60
counter=0
while ! docker info >/dev/null 2>&1 && [ $counter -lt $timeout ]; do
    echo "   Waiting for Docker... ($counter/$timeout)"
    sleep 1
    counter=$((counter + 1))
done

if [ $counter -eq $timeout ]; then
    echo "❌ Docker daemon not ready after $timeout seconds"
    exit 1
fi

echo "✅ Docker is ready"

echo ""
echo "📋 Step 3: Starting containers..."
cd "$SCRIPT_DIR"
docker compose up -d

echo ""
echo "📋 Step 4: Waiting for containers to start..."
sleep 10

echo ""
echo "📋 Step 5: Checking container status..."
docker compose ps

echo ""
echo "📋 Step 6: Testing service connectivity..."
services=("7878:Radarr" "8989:Sonarr" "9696:Prowlarr" "8096:Jellyfin" "8686:Lidarr" "9117:Jackett")

for service in "${services[@]}"; do
    port="${service%:*}"
    name="${service#*:}"
    
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port" | grep -q "200\|401"; then
        echo "✅ $name (port $port): Accessible"
    else
        echo "❌ $name (port $port): Not accessible"
    fi
done

echo ""
echo "🎉 Startup Automation Complete!"
echo "=============================="
echo ""
echo "✅ TUN device created"
echo "✅ Docker containers started"
echo "✅ Services tested"
echo ""
echo "🌐 Service URLs:"
echo "=================="
echo "• Radarr:   http://localhost:7878"
echo "• Sonarr:   http://localhost:8989"
echo "• Prowlarr: http://localhost:9696"
echo "• Jellyfin: http://localhost:8096"
echo "• Lidarr:   http://localhost:8686"
echo "• Jackett:  http://localhost:9117"
echo "• Transmission: http://localhost:9091/transmission/web/"
echo ""
echo "📋 Container Status:"
echo "==================="
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 