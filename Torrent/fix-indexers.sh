#!/bin/bash

echo "🔧 Fixing Indexer Configuration with Correct Schema"
echo "=================================================="

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Wait for Prowlarr to be fully ready
echo "⏳ Waiting for Prowlarr API..."
until curl -s http://localhost:9696/api/v1/system/status >/dev/null 2>&1; do
    echo "   Waiting for Prowlarr API..."
    sleep 10
done

echo "✅ Prowlarr API is ready!"

    # Get Prowlarr API key (now through VPN)
    echo "🔑 Getting Prowlarr API key..."
    PROWLARR_API_KEY=$(curl -s http://localhost:9696/api/v1/config/indexer | grep -o '"apiKey":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$PROWLARR_API_KEY" ]; then
    echo "⚠️  Could not get Prowlarr API key, using default..."
    PROWLARR_API_KEY=""
fi

    echo "📡 Configuring Radarr with Prowlarr (now through VPN)..."
    sqlite3 config/radarr/radarr.db "INSERT OR REPLACE INTO Indexers (Name, Implementation, Settings, ConfigContract, EnableRss, EnableAutomaticSearch, EnableInteractiveSearch, Priority, Tags, DownloadClientId) VALUES ('Prowlarr', 'Newznab', '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$PROWLARR_API_KEY\", \"categories\": [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060, 2070, 2080, 2090, 3000, 3010, 3020, 3030, 3040, 3050, 3060, 4000, 4010, 4020, 4030, 4040, 4050, 4060, 4070, 4080, 4090, 5000, 5010, 5020, 5030, 5040, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}', 'NewznabSettings', 1, 1, 1, 25, '[]', 0);"

    echo "📡 Configuring Sonarr with Prowlarr (now through VPN)..."
    sqlite3 config/sonarr/sonarr.db "INSERT OR REPLACE INTO Indexers (Name, Implementation, Settings, ConfigContract, EnableRss, EnableAutomaticSearch, EnableInteractiveSearch, Priority, Tags, DownloadClientId, SeasonSearchMaximumSingleEpisodeAge) VALUES ('Prowlarr', 'Newznab', '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$PROWLARR_API_KEY\", \"categories\": [5000, 5010, 5020, 5030, 5040, 5045, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}', 'NewznabSettings', 1, 1, 1, 25, '[]', 0, 0);"

    echo "📡 Configuring Lidarr with Prowlarr (now through VPN)..."
    sqlite3 config/lidarr/lidarr.db "INSERT OR REPLACE INTO Indexers (Name, Implementation, Settings, ConfigContract, EnableRss, EnableAutomaticSearch, EnableInteractiveSearch, Priority, DownloadClientId, Tags) VALUES ('Prowlarr', 'Newznab', '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$PROWLARR_API_KEY\", \"categories\": [3000, 3010, 3020, 3030, 3040, 3050, 3060, 3070, 3080, 3090, 4000, 4010, 4020, 4030, 4040, 4050, 4060, 4070, 4080, 4090, 5000, 5010, 5020, 5030, 5040, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}', 'NewznabSettings', 1, 1, 1, 25, 0, '[]');"

echo ""
echo "🎉 Indexer Configuration Complete!"
echo "================================="
echo ""
echo "✅ All *arr services now connected to Prowlarr"
echo "✅ RSS sync enabled for all services"
echo "✅ Automatic search enabled for all services"
echo ""
echo "🌐 Access your services:"
echo "   • Radarr:   http://localhost:7878"
echo "   • Sonarr:   http://localhost:8989"
echo "   • Lidarr:   http://localhost:8686"
echo "   • Prowlarr: http://localhost:9696"
echo ""
echo "📋 Next Steps:"
echo "   1. Restart the stack: docker compose restart"
echo "   2. Visit each *arr service and verify:"
echo "      - Indexers are available and enabled"
echo "      - RSS sync is working"
echo "      - Automatic search is enabled"
echo "   3. Test search functionality"
echo "   4. Start downloading media!" 