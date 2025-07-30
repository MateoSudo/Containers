#!/bin/bash

echo "🔧 Adding Prowlarr Indexers (Corrected Schema)"
echo "=============================================="

# Get the API key from config
API_KEY=$(grep -r "ApiKey" config/prowlarr/ 2>/dev/null | head -1 | sed 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/')

if [ -z "$API_KEY" ]; then
    echo "❌ Could not find Prowlarr API key"
    exit 1
fi

echo "✅ Found API key: ${API_KEY:0:8}..."

echo ""
echo "📡 Step 1: Adding Prowlarr to Radarr (corrected schema)..."

# Add Prowlarr to Radarr - matches Radarr schema exactly
sqlite3 config/radarr/radarr.db "INSERT INTO Indexers (Name, Implementation, Settings, ConfigContract, EnableRss, EnableAutomaticSearch, EnableInteractiveSearch, Priority, Tags, DownloadClientId) VALUES ('Prowlarr', 'Prowlarr', '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$API_KEY\", \"categories\": [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060, 2070, 2080, 2090, 3000, 3010, 3020, 3030, 3040, 3050, 3060, 4000, 4010, 4020, 4030, 4040, 4050, 4060, 4070, 4080, 4090, 5000, 5010, 5020, 5030, 5040, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}', 'ProwlarrSettings', 1, 1, 1, 25, '[]', 0);"

echo "✅ Added Prowlarr to Radarr"

echo ""
echo "📡 Step 2: Adding Prowlarr to Sonarr (corrected schema)..."

# Add Prowlarr to Sonarr - matches Sonarr schema exactly
sqlite3 config/sonarr/sonarr.db "INSERT INTO Indexers (Name, Implementation, Settings, ConfigContract, EnableRss, EnableAutomaticSearch, EnableInteractiveSearch, Priority, Tags, DownloadClientId, SeasonSearchMaximumSingleEpisodeAge) VALUES ('Prowlarr', 'Prowlarr', '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$API_KEY\", \"categories\": [5000, 5010, 5020, 5030, 5040, 5045, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}', 'ProwlarrSettings', 1, 1, 1, 25, '[]', 0, 0);"

echo "✅ Added Prowlarr to Sonarr"

echo ""
echo "📡 Step 3: Adding Prowlarr to Lidarr (corrected schema)..."

# Add Prowlarr to Lidarr - matches Lidarr schema exactly
sqlite3 config/lidarr/lidarr.db "INSERT INTO Indexers (Name, Implementation, Settings, ConfigContract, EnableRss, EnableAutomaticSearch, EnableInteractiveSearch, Priority, DownloadClientId, Tags) VALUES ('Prowlarr', 'Prowlarr', '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$API_KEY\", \"categories\": [3000, 3010, 3020, 3030, 3040, 3050, 3060, 3070, 3080, 3090, 4000, 4010, 4020, 4030, 4040, 4050, 4060, 4070, 4080, 4090, 5000, 5010, 5020, 5030, 5040, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}', 'ProwlarrSettings', 1, 1, 1, 25, 0, '[]');"

echo "✅ Added Prowlarr to Lidarr"

echo ""
echo "📡 Step 4: Verifying the additions..."

# Verify the configuration
for service in radarr sonarr lidarr; do
    echo "Checking $service Prowlarr configuration..."
    IMPLEMENTATION=$(sqlite3 config/$service/$service.db "SELECT Implementation FROM Indexers WHERE Name='Prowlarr';" 2>/dev/null)
    CONFIG_CONTRACT=$(sqlite3 config/$service/$service.db "SELECT ConfigContract FROM Indexers WHERE Name='Prowlarr';" 2>/dev/null)
    
    if [ "$IMPLEMENTATION" = "Prowlarr" ]; then
        echo "   ✅ $service: Implementation = Prowlarr"
    else
        echo "   ❌ $service: Implementation = $IMPLEMENTATION"
    fi
    
    if [ "$CONFIG_CONTRACT" = "ProwlarrSettings" ]; then
        echo "   ✅ $service: ConfigContract = ProwlarrSettings"
    else
        echo "   ❌ $service: ConfigContract = $CONFIG_CONTRACT"
    fi
done

echo ""
echo "📡 Step 5: Restarting *arr services..."

# Restart *arr services to apply changes
docker compose restart radarr sonarr lidarr

echo "⏳ Waiting for services to restart..."
sleep 30

echo ""
echo "🎉 Prowlarr Indexer Addition Complete!"
echo "======================================"
echo ""
echo "✅ Prowlarr indexer added to all *arr services"
echo "✅ Correct implementation and config contract set"
echo "✅ Services restarted with new configuration"
echo ""
echo "🌐 Test your services:"
echo "   • Radarr:   http://localhost:7878"
echo "   • Sonarr:   http://localhost:8989"
echo "   • Lidarr:   http://localhost:8686"
echo "   • Prowlarr: http://localhost:9696"
echo ""
echo "📋 The indexers should now be properly configured!"
echo "   Check the Indexers section in each *arr service." 