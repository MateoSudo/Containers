#!/bin/bash

echo "🧪 Testing Reboot Automation"
echo "============================"

echo ""
echo "📋 Step 1: Checking systemd services..."
echo "TUN Device Service:"
systemctl is-enabled create-tun-device.service
systemctl is-active create-tun-device.service

echo ""
echo "Container Startup Service:"
systemctl is-enabled container-startup.service
systemctl is-active container-startup.service

echo ""
echo "📋 Step 2: Checking TUN device..."
if [ -e /dev/net/tun ]; then
    echo "✅ TUN device exists:"
    ls -la /dev/net/tun
else
    echo "❌ TUN device missing"
fi

echo ""
echo "📋 Step 3: Checking Docker containers..."
cd "$(dirname "${BASH_SOURCE[0]}")"
docker compose ps

echo ""
echo "📋 Step 4: Testing service connectivity..."
services=("7878:Radarr" "8989:Sonarr" "9696:Prowlarr" "8096:Jellyfin" "8686:Lidarr")

for service in "${services[@]}"; do
    port="${service%:*}"
    name="${service#*:}"
    
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$port" | grep -q "200\|401\|302"; then
        echo "✅ $name (port $port): Accessible"
    else
        echo "❌ $name (port $port): Not accessible"
    fi
done

echo ""
echo "📋 Step 5: Checking service logs..."
echo "TUN Device Service Logs:"
journalctl -u create-tun-device.service --no-pager -n 5

echo ""
echo "Container Startup Service Logs:"
journalctl -u container-startup.service --no-pager -n 5

echo ""
echo "🎉 Test Complete!"
echo "================"
echo ""
echo "✅ If all services show 'enabled' and 'active', automation is ready"
echo "✅ If all containers are 'Up', they will start automatically on boot"
echo "✅ If all services are accessible, everything is working correctly"
echo ""
echo "🚀 To test the full automation:"
echo "   sudo reboot"
echo ""
echo "📋 After reboot, check:"
echo "   • systemctl status create-tun-device.service"
echo "   • systemctl status container-startup.service"
echo "   • docker compose ps"
echo "   • curl -s http://localhost:7878 (should return 401 or 200)" 