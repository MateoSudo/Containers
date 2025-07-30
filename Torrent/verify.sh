#!/bin/bash

echo "🔍 Media Stack Verification & Testing"
echo "===================================="

# Get the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "📋 Available verification options:"
echo "1. Check container status"
echo "2. Test service connectivity"
echo "3. Test indexer connectivity"
echo "4. Test API connectivity"
echo "5. Test reboot automation"
echo "6. Check health status"
echo "7. Run all verifications"
echo "8. Exit"
echo ""

read -p "Select an option (1-8): " choice

case $choice in
    1)
        echo "📋 Checking container status..."
        docker compose ps
        ;;
    2)
        echo "📋 Testing service connectivity..."
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
        ;;
    3)
        echo "📋 Testing indexer connectivity..."
        if [ -f "$SCRIPT_DIR/test-indexer-connectivity.sh" ]; then
            bash "$SCRIPT_DIR/test-indexer-connectivity.sh"
        else
            echo "⚠️  test-indexer-connectivity.sh not found"
        fi
        ;;
    4)
        echo "📋 Testing API connectivity..."
        if [ -f "$SCRIPT_DIR/verify-api-fix.sh" ]; then
            bash "$SCRIPT_DIR/verify-api-fix.sh"
        else
            echo "⚠️  verify-api-fix.sh not found"
        fi
        ;;
    5)
        echo "📋 Testing reboot automation..."
        if [ -f "$SCRIPT_DIR/test-reboot-automation.sh" ]; then
            bash "$SCRIPT_DIR/test-reboot-automation.sh"
        else
            echo "⚠️  test-reboot-automation.sh not found"
        fi
        ;;
    6)
        echo "📋 Checking health status..."
        echo "Container health status:"
        docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}"
        
        echo ""
        echo "VPN container health:"
        if docker inspect torrent-pia-vpn --format='{{.State.Health.Status}}' | grep -q "healthy"; then
            echo "✅ VPN container is healthy"
        else
            echo "⚠️  VPN container is not healthy"
            echo "VPN container logs:"
            docker logs torrent-pia-vpn --tail=5
        fi
        ;;
    7)
        echo "📋 Running all verifications..."
        
        echo "1. Container status:"
        docker compose ps
        
        echo ""
        echo "2. Service connectivity:"
        services=("7878:Radarr" "8989:Sonarr" "9696:Prowlarr" "8096:Jellyfin" "8686:Lidarr" "9117:Jackett")
        
        for service in "${services[@]}"; do
            port="${service%:*}"
            name="${service#*:}"
            
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
        echo "3. VPN container health:"
        if docker inspect torrent-pia-vpn --format='{{.State.Health.Status}}' | grep -q "healthy"; then
            echo "✅ VPN container is healthy"
        else
            echo "⚠️  VPN container is not healthy"
        fi
        
        echo ""
        echo "4. TUN device:"
        if [ -e /dev/net/tun ]; then
            echo "✅ TUN device exists"
            ls -la /dev/net/tun
        else
            echo "❌ TUN device missing"
        fi
        
        echo ""
        echo "✅ All verifications completed"
        ;;
    8)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "🎉 Verification complete!"
echo "======================="
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