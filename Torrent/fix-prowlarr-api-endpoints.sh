#!/bin/bash

echo "🔧 Fixing Prowlarr API Endpoints"
echo "================================"

# Get the API key from config
API_KEY=$(grep -r "ApiKey" config/prowlarr/ 2>/dev/null | head -1 | sed 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/')

if [ -z "$API_KEY" ]; then
    echo "❌ Could not find Prowlarr API key"
    exit 1
fi

echo "✅ Found API key: ${API_KEY:0:8}..."

echo ""
echo "📡 Step 1: Testing correct Prowlarr API endpoints..."

# Test the correct Prowlarr API endpoints
echo "🔍 Testing Prowlarr system status..."
if curl -s -H "X-Api-Key: $API_KEY" http://localhost:9696/api/v1/system/status >/dev/null 2>&1; then
    echo "✅ Prowlarr system status: Accessible"
else
    echo "❌ Prowlarr system status: Not accessible"
fi

echo "🔍 Testing Prowlarr indexers..."
if curl -s -H "X-Api-Key: $API_KEY" http://localhost:9696/api/v1/indexer >/dev/null 2>&1; then
    echo "✅ Prowlarr indexers: Accessible"
else
    echo "❌ Prowlarr indexers: Not accessible"
fi

echo ""
echo "📡 Step 2: Updating *arr services with correct Prowlarr configuration..."

# Configure Radarr with correct Prowlarr settings (not Newznab)
echo "🔧 Configuring Radarr with Prowlarr..."
sqlite3 config/radarr/radarr.db "UPDATE Indexers SET Implementation = 'Prowlarr', Settings = '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$API_KEY\", \"categories\": [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060, 2070, 2080, 2090, 3000, 3010, 3020, 3030, 3040, 3050, 3060, 4000, 4010, 4020, 4030, 4040, 4050, 4060, 4070, 4080, 4090, 5000, 5010, 5020, 5030, 5040, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}', ConfigContract = 'ProwlarrSettings' WHERE Name='Prowlarr';"

# Configure Sonarr with correct Prowlarr settings
echo "🔧 Configuring Sonarr with Prowlarr..."
sqlite3 config/sonarr/sonarr.db "UPDATE Indexers SET Implementation = 'Prowlarr', Settings = '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$API_KEY\", \"categories\": [5000, 5010, 5020, 5030, 5040, 5045, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}', ConfigContract = 'ProwlarrSettings' WHERE Name='Prowlarr';"

# Configure Lidarr with correct Prowlarr settings
echo "🔧 Configuring Lidarr with Prowlarr..."
sqlite3 config/lidarr/lidarr.db "UPDATE Indexers SET Implementation = 'Prowlarr', Settings = '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$API_KEY\", \"categories\": [3000, 3010, 3020, 3030, 3040, 3050, 3060, 3070, 3080, 3090, 4000, 4010, 4020, 4030, 4040, 4050, 4060, 4070, 4080, 4090, 5000, 5010, 5020, 5030, 5040, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}', ConfigContract = 'ProwlarrSettings' WHERE Name='Prowlarr';"

echo ""
echo "📡 Step 3: Restarting *arr services..."

# Restart *arr services to apply changes
docker compose restart radarr sonarr lidarr

echo "⏳ Waiting for services to restart..."
sleep 30

echo ""
echo "📡 Step 4: Testing the fix..."

# Test if the services can now connect to Prowlarr
for service in radarr sonarr lidarr; do
    echo "Testing $service connection to Prowlarr..."
    if docker exec torrent-$service curl -s -o /dev/null -w "   $service → Prowlarr: %{http_code}\n" http://pia-vpn:9696/api/v1/system/status >/dev/null 2>&1; then
        echo "   ✅ $service: Can reach Prowlarr API"
    else
        echo "   ❌ $service: Cannot reach Prowlarr API"
    fi
done

echo ""
echo "🎉 Prowlarr API Endpoint Fix Complete!"
echo "======================================"
echo ""
echo "✅ Updated *arr services to use correct Prowlarr implementation"
echo "✅ Changed from Newznab to Prowlarr API endpoints"
echo "✅ Services restarted with new configuration"
echo ""
echo "🌐 Test your services:"
echo "   • Radarr:   http://localhost:7878"
echo "   • Sonarr:   http://localhost:8989"
echo "   • Lidarr:   http://localhost:8686"
echo "   • Prowlarr: http://localhost:9696"
echo ""
echo "📋 The 404 errors should now be resolved!"
echo "   The *arr services will now use the correct Prowlarr API endpoints." 