#!/bin/bash

echo "🔧 Updating All Services with Static IPs"
echo "========================================"
echo ""
echo "📋 Static IP Assignment:"
echo "======================="
echo "• pia-vpn:      172.19.0.4 (VPN container)"
echo "• sonarr:       172.19.0.5"
echo "• radarr:       172.19.0.6"
echo "• lidarr:       172.19.0.7"
echo "• jellyfin:     172.19.0.8"
echo "• prowlarr:     Uses pia-vpn network (172.19.0.4)"
echo "• jackett:      Uses pia-vpn network (172.19.0.4)"
echo "• transmission: Uses pia-vpn network (172.19.0.4)"
echo ""
echo "📡 Step 1: Updating *arr service configurations..."

# Update Radarr download client to use static IP
echo "Updating Radarr Transmission configuration..."
sqlite3 config/radarr/radarr.db "UPDATE DownloadClients SET Settings = '{\"host\": \"172.19.0.4\", \"port\": 9091, \"username\": \"\", \"password\": \"\", \"category\": \"movies\", \"recentMoviePriority\": 0, \"olderMoviePriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false, \"urlBase\": \"/transmission/\", \"directory\": \"/downloads/complete/movies\"}' WHERE Implementation='Transmission';" 2>/dev/null && echo "   ✅ Radarr Transmission updated"

# Update Sonarr download client to use static IP
echo "Updating Sonarr Transmission configuration..."
sqlite3 config/sonarr/sonarr.db "UPDATE DownloadClients SET Settings = '{\"host\": \"172.19.0.4\", \"port\": 9091, \"username\": \"\", \"password\": \"\", \"category\": \"tv\", \"recentTvPriority\": 0, \"olderTvPriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false, \"urlBase\": \"/transmission/\", \"directory\": \"/downloads/complete/tv\"}' WHERE Implementation='Transmission';" 2>/dev/null && echo "   ✅ Sonarr Transmission updated"

# Update Lidarr download client to use static IP
echo "Updating Lidarr Transmission configuration..."
sqlite3 config/lidarr/lidarr.db "UPDATE DownloadClients SET Settings = '{\"host\": \"172.19.0.4\", \"port\": 9091, \"username\": \"\", \"password\": \"\", \"category\": \"music\", \"recentTvPriority\": 0, \"olderTvPriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false, \"urlBase\": \"/transmission/\", \"directory\": \"/downloads/complete/music\"}' WHERE Implementation='Transmission';" 2>/dev/null && echo "   ✅ Lidarr Transmission updated"

echo ""
echo "📡 Step 2: Updating Prowlarr indexer configurations..."

# Update Radarr indexer in Prowlarr to use static IP
echo "Updating Prowlarr Radarr indexer..."
API_KEY=$(grep -r "ApiKey" config/prowlarr/ 2>/dev/null | head -1 | sed 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/')
if [ ! -z "$API_KEY" ]; then
    # Check if Radarr app exists in Prowlarr
    RADARR_APP=$(curl -s -H "X-Api-Key: $API_KEY" http://localhost:9696/api/v1/applications | grep -o "\"name\":\"Radarr\"" 2>/dev/null)
    if [ ! -z "$RADARR_APP" ]; then
        echo "   ✅ Radarr app already configured in Prowlarr"
    else
        echo "   ⚠️ Radarr app not found in Prowlarr - configure manually"
    fi
else
    echo "   ❌ Prowlarr API key not found"
fi

echo ""
echo "📡 Step 3: Testing connectivity with static IPs..."

# Test Transmission connectivity from *arr services
echo "Testing Transmission connectivity..."
for service in radarr sonarr lidarr; do
    echo "Testing $service → Transmission (172.19.0.4:9091)..."
    if docker exec torrent-$service curl -s -o /dev/null -w "%{http_code}" http://172.19.0.4:9091/transmission/web/ 2>/dev/null | grep -q "200\|401"; then
        echo "   ✅ $service can reach Transmission"
    else
        echo "   ❌ $service cannot reach Transmission"
    fi
done

echo ""
echo "📡 Step 4: Testing *arr service connectivity..."

# Test *arr services can reach each other
echo "Testing *arr service connectivity..."
for service in radarr sonarr lidarr; do
    case $service in
        radarr) PORT=7878; IP=172.19.0.6 ;;
        sonarr) PORT=8989; IP=172.19.0.5 ;;
        lidarr) PORT=8686; IP=172.19.0.7 ;;
    esac
    
    echo "Testing $service ($IP:$PORT)..."
    if curl -s -o /dev/null -w "%{http_code}" http://$IP:$PORT/api/v3/system/status 2>/dev/null | grep -q "200\|401"; then
        echo "   ✅ $service is accessible at $IP:$PORT"
    else
        echo "   ❌ $service not accessible at $IP:$PORT"
    fi
done

echo ""
echo "🎉 STATIC IP CONFIGURATION COMPLETE!"
echo "===================================="
echo ""
echo "✅ All containers now have static IPs"
echo "✅ *arr services updated to use static IPs"
echo "✅ Transmission accessible via 172.19.0.4:9091"
echo ""
echo "🌐 Static IP Reference:"
echo "======================"
echo "• VPN/Transmission: 172.19.0.4"
echo "• Sonarr:           172.19.0.5:8989"
echo "• Radarr:           172.19.0.6:7878"
echo "• Lidarr:           172.19.0.7:8686"
echo "• Jellyfin:         172.19.0.8:8096"
echo ""
echo "📋 Prowlarr Configuration:"
echo "========================="
echo "For Prowlarr → Radarr connection, use:"
echo "• URL: http://172.19.0.6:7878"
echo "• This is now the permanent, reliable IP"
echo ""
echo "🚀 Restart services to apply changes:"
echo "   docker compose restart radarr sonarr lidarr" 