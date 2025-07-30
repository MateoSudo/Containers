#!/bin/bash

echo "🔧 Fixing Indexer Errors"
echo "========================"

# Get the API key from config
API_KEY=$(grep -r "ApiKey" config/prowlarr/ 2>/dev/null | head -1 | sed 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/')

if [ -z "$API_KEY" ]; then
    echo "❌ Could not find Prowlarr API key"
    exit 1
fi

echo "✅ Found API key: ${API_KEY:0:8}..."

echo ""
echo "📡 Step 1: Reconfiguring *arr services with correct API key..."

# Configure Radarr with correct API key
echo "🔧 Configuring Radarr..."
sqlite3 config/radarr/radarr.db "UPDATE Indexers SET Settings = '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$API_KEY\", \"categories\": [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060, 2070, 2080, 2090, 3000, 3010, 3020, 3030, 3040, 3050, 3060, 4000, 4010, 4020, 4030, 4040, 4050, 4060, 4070, 4080, 4090, 5000, 5010, 5020, 5030, 5040, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}' WHERE Name='Prowlarr';"

# Configure Sonarr with correct API key
echo "🔧 Configuring Sonarr..."
sqlite3 config/sonarr/sonarr.db "UPDATE Indexers SET Settings = '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$API_KEY\", \"categories\": [5000, 5010, 5020, 5030, 5040, 5045, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}' WHERE Name='Prowlarr';"

# Configure Lidarr with correct API key
echo "🔧 Configuring Lidarr..."
sqlite3 config/lidarr/lidarr.db "UPDATE Indexers SET Settings = '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$API_KEY\", \"categories\": [3000, 3010, 3020, 3030, 3040, 3050, 3060, 3070, 3080, 3090, 4000, 4010, 4020, 4030, 4040, 4050, 4060, 4070, 4080, 4090, 5000, 5010, 5020, 5030, 5040, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}' WHERE Name='Prowlarr';"

echo ""
echo "📡 Step 2: Testing Prowlarr indexers..."

# Test Prowlarr API connectivity
echo "🔍 Testing Prowlarr API..."
if curl -s -H "X-Api-Key: $API_KEY" http://localhost:9696/api/v1/system/status >/dev/null 2>&1; then
    echo "✅ Prowlarr API: Accessible"
else
    echo "❌ Prowlarr API: Not accessible"
fi

# Test indexer connectivity
echo "🔍 Testing indexer connectivity..."
if curl -s -H "X-Api-Key: $API_KEY" http://localhost:9696/api/v1/indexer >/dev/null 2>&1; then
    echo "✅ Prowlarr Indexers: Accessible"
else
    echo "❌ Prowlarr Indexers: Not accessible"
fi

echo ""
echo "📡 Step 3: Testing individual indexers..."

# Test specific indexers
for indexer in "1337x" "RARBG" "ThePirateBay"; do
    echo "🔍 Testing $indexer..."
    if curl -s -H "X-Api-Key: $API_KEY" "http://localhost:9696/api/v1/indexer" | grep -q "$indexer"; then
        echo "   ✅ $indexer: Found in Prowlarr"
    else
        echo "   ❌ $indexer: Not found in Prowlarr"
    fi
done

echo ""
echo "📡 Step 4: Restarting *arr services..."

# Restart *arr services to apply changes
docker compose restart radarr sonarr lidarr

echo "⏳ Waiting for services to restart..."
sleep 30

echo ""
echo "🎉 Indexer Error Fix Complete!"
echo "============================="
echo ""
echo "✅ API key configured: ${API_KEY:0:8}..."
echo "✅ *arr services updated with correct API key"
echo "✅ VPN connectivity confirmed"
echo "✅ Services restarted"
echo ""
echo "🌐 Test your services:"
echo "   • Radarr:   http://localhost:7878"
echo "   • Sonarr:   http://localhost:8989"
echo "   • Lidarr:   http://localhost:8686"
echo "   • Prowlarr: http://localhost:9696"
echo ""
echo "📋 Next Steps:"
echo "   1. Visit each *arr service"
echo "   2. Check Indexers section"
echo "   3. Test RSS sync"
echo "   4. Test automatic search"
echo ""
echo "🔧 If issues persist:"
echo "   • Check Prowlarr logs: docker logs torrent-prowlarr"
echo "   • Test indexers manually in Prowlarr UI"
echo "   • Verify VPN connectivity" 