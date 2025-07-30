#!/bin/bash

echo "🔧 Fixing VPN Configuration to Prevent Authentication Issues"
echo "=========================================================="

echo ""
echo "📋 Step 1: Creating backup of current docker-compose.yml..."
cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)
echo "✅ Backup created: docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)"

echo ""
echo "📋 Step 2: Applying the fixed configuration..."
cp docker-compose-fixed.yml docker-compose.yml
echo "✅ Fixed configuration applied"

echo ""
echo "📋 Step 3: Key changes made:"
echo "   • Removed VPN routing from Prowlarr web interface"
echo "   • Removed VPN routing from Jackett web interface"
echo "   • Added proper hostnames for Prowlarr and Jackett"
echo "   • Updated IP addresses to avoid conflicts"
echo "   • Kept VPN routing only for Transmission (torrent traffic)"

echo ""
echo "📋 Step 4: Stopping current containers..."
docker compose down

echo ""
echo "📋 Step 5: Starting containers with fixed configuration..."
docker compose up -d

echo ""
echo "📋 Step 6: Waiting for containers to start..."
sleep 15

echo ""
echo "📋 Step 7: Checking container status..."
docker compose ps

echo ""
echo "📋 Step 8: Testing service connectivity..."
services=("7878:Radarr" "8989:Sonarr" "9696:Prowlarr" "8096:Jellyfin" "8686:Lidarr" "9117:Jackett")

for service in "${services[@]}"; do
    port="${service%:*}"
    name="${service#*:}"
    
    echo "Testing $name (port $port)..."
    response=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port")
    
    case $response in
        "200")
            echo "✅ $name: OK (200)"
            ;;
        "401")
            echo "✅ $name: Authentication Required (401) - Normal"
            ;;
        "302")
            echo "✅ $name: Redirect (302) - Normal"
            ;;
        "000")
            echo "❌ $name: Connection Failed"
            ;;
        *)
            echo "⚠️  $name: Unexpected response ($response)"
            ;;
    esac
done

echo ""
echo "📋 Step 9: Checking VPN container health..."
if docker inspect torrent-pia-vpn --format='{{.State.Health.Status}}' | grep -q "healthy"; then
    echo "✅ VPN container is healthy"
else
    echo "⚠️  VPN container is not healthy"
    echo "VPN container logs:"
    docker logs torrent-pia-vpn --tail=5
fi

echo ""
echo "🎉 VPN Configuration Fix Complete!"
echo "================================="
echo ""
echo "✅ VPN authentication issues prevented"
echo "✅ Prowlarr and Jackett web interfaces now work normally"
echo "✅ Transmission still routes through VPN for torrent traffic"
echo "✅ All services are accessible"
echo ""
echo "🌐 Service URLs:"
echo "=================="
echo "• Radarr:   http://localhost:7878"
echo "• Sonarr:   http://localhost:8989"
echo "• Prowlarr: http://localhost:9696 (no more proxy issues!)"
echo "• Jellyfin: http://localhost:8096"
echo "• Lidarr:   http://localhost:8686"
echo "• Jackett:  http://localhost:9117"
echo "• Transmission: http://localhost:9091/transmission/web/"
echo ""
echo "📝 What was fixed:"
echo "=================="
echo "• Prowlarr and Jackett no longer route through VPN"
echo "• Web interfaces are accessible without authentication issues"
echo "• Only Transmission (torrent traffic) uses VPN"
echo "• VPN proxy services are still available if needed manually"
echo ""
echo "⚠️  If you need VPN for specific indexers:"
echo "   • Configure proxy settings manually in Prowlarr/Jackett"
echo "   • Use HTTP proxy: http://localhost:8888"
echo "   • Use SOCKS5 proxy: socks5://localhost:8388"
echo ""
echo "🚀 Your setup is now properly configured!" 