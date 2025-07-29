#!/bin/bash

# Comprehensive status check for the torrent stack
echo "=== Torrent Stack Status Check ==="
echo

# Check if tun device exists
echo "1. Checking TUN device..."
if [ -e /dev/net/tun ]; then
    echo "✓ /dev/net/tun device exists"
else
    echo "✗ /dev/net/tun device missing - run ./fix-tun-device.sh"
fi
echo

# Check Docker containers
echo "2. Checking Docker containers..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep torrent
echo

# Check VPN status
echo "3. Checking VPN status..."
if curl -s http://localhost:8000/v1/openvpn/status > /dev/null 2>&1; then
    echo "✓ VPN container is responding"
    curl -s http://localhost:8000/v1/openvpn/status | jq '.status' 2>/dev/null || echo "VPN status: Connected"
else
    echo "✗ VPN container not responding"
fi
echo

# Check Sonarr
echo "4. Checking Sonarr..."
if curl -s -H "X-Api-Key: ef1ed0f9777046838e704befbeb23e19" http://localhost:8989/api/v3/system/status > /dev/null 2>&1; then
    echo "✓ Sonarr is running"
    INDEXER_COUNT=$(curl -s -H "X-Api-Key: ef1ed0f9777046838e704befbeb23e19" http://localhost:8989/api/v3/indexer | jq 'length' 2>/dev/null || echo "0")
    echo "  - Indexers configured: $INDEXER_COUNT"
else
    echo "✗ Sonarr not responding"
fi
echo

# Check Prowlarr
echo "5. Checking Prowlarr..."
if curl -s -H "X-Api-Key: f8253575617641e7a1f595e97f3ea399" http://localhost:9696/api/v1/system/status > /dev/null 2>&1; then
    echo "✓ Prowlarr is running"
    INDEXER_COUNT=$(curl -s -H "X-Api-Key: f8253575617641e7a1f595e97f3ea399" http://localhost:9696/api/v1/indexer | jq 'length' 2>/dev/null || echo "0")
    echo "  - Indexers configured: $INDEXER_COUNT"
else
    echo "✗ Prowlarr not responding"
fi
echo

# Check Transmission
echo "6. Checking Transmission..."
if curl -s http://localhost:9091/transmission/rpc/ > /dev/null 2>&1; then
    echo "✓ Transmission is running"
else
    echo "✗ Transmission not responding"
fi
echo

# Check other services
echo "7. Checking other services..."
services=("radarr:7878" "lidarr:8686" "jellyfin:8096")
for service in "${services[@]}"; do
    name=$(echo $service | cut -d: -f1)
    port=$(echo $service | cut -d: -f2)
    if curl -s http://localhost:$port > /dev/null 2>&1; then
        echo "✓ $name is running (port $port)"
    else
        echo "✗ $name not responding (port $port)"
    fi
done
echo

echo "=== Status Check Complete ==="
echo "If any services show ✗, check the logs with: docker logs torrent-[service-name]" 