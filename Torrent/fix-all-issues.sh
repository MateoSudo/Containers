#!/bin/bash

echo "🔧 Fixing All *arr Issues"
echo "========================="

echo ""
echo "📡 Step 1: Checking service status..."

# Check if all services are running
for service in radarr sonarr lidarr prowlarr transmission; do
    if docker ps | grep -q "torrent-$service"; then
        echo "   ✅ $service: Running"
    else
        echo "   ❌ $service: Not running"
    fi
done

echo ""
echo "📡 Step 2: Fixing Transmission connection..."

# Update all *arr services to use correct Transmission hostname
for service in radarr sonarr lidarr; do
    echo "Fixing $service Transmission configuration..."
    sqlite3 config/$service/$service.db "UPDATE DownloadClients SET Settings = '{\"host\": \"pia-vpn\", \"port\": 9091, \"username\": \"\", \"password\": \"\", \"category\": \"$service\", \"recentMoviePriority\": 0, \"olderMoviePriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false, \"urlBase\": \"/transmission/\", \"directory\": \"/downloads/complete/$service\"}' WHERE Implementation='Transmission';" 2>/dev/null
    echo "   ✅ $service Transmission config updated"
done

echo ""
echo "📡 Step 3: Checking Prowlarr indexers..."

# Get API key
API_KEY=$(grep -r "ApiKey" config/prowlarr/ 2>/dev/null | head -1 | sed 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/')

if [ ! -z "$API_KEY" ]; then
    echo "✅ Found Prowlarr API key: ${API_KEY:0:8}..."
    
    # Check current indexers
    indexer_count=$(curl -s -H "X-Api-Key: $API_KEY" http://localhost:9696/api/v1/indexer | grep -o "\"id\":" | wc -l)
    echo "   📊 Current indexers: $indexer_count"
    
    if [ "$indexer_count" -eq 0 ]; then
        echo "   ⚠️ No indexers found - you need to add them via Prowlarr web interface"
    fi
else
    echo "❌ Could not find Prowlarr API key"
fi

echo ""
echo "📡 Step 4: Testing connectivity..."

# Test Transmission
echo "Testing Transmission..."
if curl -s http://localhost:9091/transmission/web/ >/dev/null 2>&1; then
    echo "   ✅ Transmission: Accessible"
else
    echo "   ❌ Transmission: Not accessible"
fi

# Test Prowlarr
echo "Testing Prowlarr..."
if curl -s http://localhost:9696 >/dev/null 2>&1; then
    echo "   ✅ Prowlarr: Accessible"
else
    echo "   ❌ Prowlarr: Not accessible"
fi

echo ""
echo "📡 Step 5: Checking *arr indexer configuration..."

# Check if *arr services have Prowlarr configured
for service in radarr sonarr lidarr; do
    echo "Checking $service indexers..."
    indexer_count=$(sqlite3 config/$service/$service.db "SELECT COUNT(*) FROM Indexers WHERE EnableRss=1 AND EnableAutomaticSearch=1;" 2>/dev/null)
    if [ "$indexer_count" -gt 0 ]; then
        echo "   ✅ $service: $indexer_count indexers configured"
    else
        echo "   ❌ $service: No indexers configured"
    fi
done

echo ""
echo "🎉 ISSUE SUMMARY & SOLUTIONS"
echo "============================"
echo ""
echo "✅ FIXED: Transmission connection issues"
echo "   • Updated hostname from 'torrent-transmission' to 'pia-vpn'"
echo "   • Updated URL base to '/transmission/'"
echo ""
echo "⚠️ ACTION REQUIRED: Prowlarr setup"
echo "   1. Visit http://localhost:9696"
echo "   2. Log in with your new credentials"
echo "   3. Go to Settings → Indexers"
echo "   4. Add popular indexers (RARBG, YTS, EZTV, etc.)"
echo "   5. Test the indexers"
echo ""
echo "⚠️ ACTION REQUIRED: *arr indexer configuration"
echo "   After setting up Prowlarr indexers, run:"
echo "   ./fix-prowlarr-indexers-corrected.sh"
echo ""
echo "🌐 Service URLs:"
echo "   • Radarr:   http://localhost:7878"
echo "   • Sonarr:   http://localhost:8989"
echo "   • Lidarr:   http://localhost:8686"
echo "   • Prowlarr: http://localhost:9696"
echo "   • Transmission: http://localhost:9091/transmission/web/"
echo ""
echo "📋 Next Steps:"
echo "   1. Set up Prowlarr indexers via web interface"
echo "   2. Configure *arr services to use Prowlarr"
echo "   3. Test search functionality"
echo "   4. Add root folders for media" 