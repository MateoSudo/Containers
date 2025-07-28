#!/bin/bash

echo "🔧 Fixing *arr Services - Comprehensive Solution"
echo "================================================"

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Function to check if service is ready
check_service() {
    local service=$1
    local port=$2
    local max_attempts=30
    local attempt=1
    
    echo "🔍 Checking $service..."
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:$port >/dev/null 2>&1; then
            echo "✅ $service is ready"
            return 0
        fi
        echo "   Attempt $attempt/$max_attempts..."
        sleep 10
        ((attempt++))
    done
    echo "⚠️  $service may still be starting"
    return 1
}

# Check all services
check_service "Radarr" 7878
check_service "Sonarr" 8989
check_service "Lidarr" 8686
check_service "Prowlarr" 9696

echo ""
echo "📡 Step 1: Configuring Download Clients with correct paths..."

# Configure Radarr with correct paths
echo "🔧 Configuring Radarr..."
sqlite3 config/radarr/radarr.db "INSERT OR REPLACE INTO DownloadClients (Enable, Name, Implementation, Settings, ConfigContract, Priority, RemoveCompletedDownloads, RemoveFailedDownloads) VALUES (1, 'Transmission', 'Transmission', '{\"host\": \"172.19.0.4\", \"port\": 9091, \"username\": \"\", \"password\": \"\", \"category\": \"movies\", \"urlBase\": \"/transmission/\", \"recentMoviePriority\": 0, \"olderMoviePriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false}', 'TransmissionSettings', 1, 1, 1);"

# Configure Sonarr with correct paths
echo "🔧 Configuring Sonarr..."
sqlite3 config/sonarr/sonarr.db "INSERT OR REPLACE INTO DownloadClients (Enable, Name, Implementation, Settings, ConfigContract, Priority, RemoveCompletedDownloads, RemoveFailedDownloads) VALUES (1, 'Transmission', 'Transmission', '{\"host\": \"172.19.0.4\", \"port\": 9091, \"username\": \"\", \"password\": \"\", \"category\": \"tv\", \"urlBase\": \"/transmission/\", \"recentTvPriority\": 0, \"olderTvPriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false}', 'TransmissionSettings', 1, 1, 1);"

# Configure Lidarr with correct paths
echo "🔧 Configuring Lidarr..."
sqlite3 config/lidarr/lidarr.db "INSERT OR REPLACE INTO DownloadClients (Enable, Name, Implementation, Settings, ConfigContract, Priority, RemoveCompletedDownloads, RemoveFailedDownloads) VALUES (1, 'Transmission', 'Transmission', '{\"host\": \"172.19.0.4\", \"port\": 9091, \"username\": \"\", \"password\": \"\", \"category\": \"music\", \"urlBase\": \"/transmission/\", \"recentTvPriority\": 0, \"olderTvPriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false}', 'TransmissionSettings', 1, 1, 1);"

echo ""
echo "📡 Step 2: Configuring Indexers..."

# Wait for Prowlarr to be fully ready
echo "⏳ Waiting for Prowlarr API..."
until curl -s http://localhost:9696/api/v1/system/status >/dev/null 2>&1; do
    echo "   Waiting for Prowlarr API..."
    sleep 10
done

echo "✅ Prowlarr API is ready!"

# Add indexers to Prowlarr if not already added
echo "🔍 Adding popular indexers to Prowlarr..."

# Function to add indexer to Prowlarr
add_indexer() {
    local name="$1"
    local protocol="$2"
    local url="$3"
    local categories="$4"
    
    echo "📡 Adding $name indexer..."
    
    # Create indexer configuration
    cat > /tmp/indexer_$name.json << EOF
{
    "name": "$name",
    "protocol": "$protocol",
    "supportsRss": true,
    "supportsSearch": true,
    "supportedCategories": $categories,
    "baseUrl": "$url",
    "apiPath": "/api",
    "apiKey": "",
    "minimumSeeders": 1,
    "requiredFlags": [],
    "configContract": "NewznabSettings",
    "implementation": "Newznab",
    "implementationName": "Newznab",
    "infoLink": "$url",
    "tags": []
}
EOF

    # Add indexer via Prowlarr API
    curl -s -X POST \
        -H "Content-Type: application/json" \
        -d @/tmp/indexer_$name.json \
        http://localhost:9696/api/v1/indexer
    
    rm -f /tmp/indexer_$name.json
    echo "✅ Added $name"
}

# Add popular indexers
add_indexer "1337x" "torrent" "https://1337x.to" '["movies", "tv", "music"]'
add_indexer "RARBG" "torrent" "https://rarbg.to" '["movies", "tv", "music"]'
add_indexer "ThePirateBay" "torrent" "https://thepiratebay.org" '["movies", "tv", "music"]'
add_indexer "YTS" "torrent" "https://yts.mx" '["movies"]'
add_indexer "EZTV" "torrent" "https://eztv.re" '["tv"]'

echo ""
echo "📡 Step 3: Connecting Prowlarr to *arr services..."

    # Get Prowlarr API key (now through VPN)
    echo "🔑 Getting Prowlarr API key..."
    PROWLARR_API_KEY=$(curl -s http://localhost:9696/api/v1/config/indexer | grep -o '"apiKey":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$PROWLARR_API_KEY" ]; then
    echo "⚠️  Could not get Prowlarr API key, using default..."
    PROWLARR_API_KEY=""
fi

    # Configure Radarr to use Prowlarr (now through VPN)
    echo "🔧 Connecting Radarr to Prowlarr..."
    sqlite3 config/radarr/radarr.db "INSERT OR REPLACE INTO Indexers (Enable, Name, Implementation, Settings, ConfigContract, Priority) VALUES (1, 'Prowlarr', 'Newznab', '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$PROWLARR_API_KEY\", \"categories\": [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060, 2070, 2080, 2090, 3000, 3010, 3020, 3030, 3040, 3050, 3060, 4000, 4010, 4020, 4030, 4040, 4050, 4060, 4070, 4080, 4090, 5000, 5010, 5020, 5030, 5040, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}', 'NewznabSettings', 1);"

    # Configure Sonarr to use Prowlarr (now through VPN)
    echo "🔧 Connecting Sonarr to Prowlarr..."
    sqlite3 config/sonarr/sonarr.db "INSERT OR REPLACE INTO Indexers (Enable, Name, Implementation, Settings, ConfigContract, Priority) VALUES (1, 'Prowlarr', 'Newznab', '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$PROWLARR_API_KEY\", \"categories\": [5000, 5010, 5020, 5030, 5040, 5045, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}', 'NewznabSettings', 1);"

    # Configure Lidarr to use Prowlarr (now through VPN)
    echo "🔧 Connecting Lidarr to Prowlarr..."
    sqlite3 config/lidarr/lidarr.db "INSERT OR REPLACE INTO Indexers (Enable, Name, Implementation, Settings, ConfigContract, Priority) VALUES (1, 'Prowlarr', 'Newznab', '{\"baseUrl\": \"http://pia-vpn:9696\", \"apiPath\": \"/api/v1\", \"apiKey\": \"$PROWLARR_API_KEY\", \"categories\": [3000, 3010, 3020, 3030, 3040, 3050, 3060, 3070, 3080, 3090, 4000, 4010, 4020, 4030, 4040, 4050, 4060, 4070, 4080, 4090, 5000, 5010, 5020, 5030, 5040, 5050, 5060, 5070, 5080, 5090, 6000, 6010, 6020, 6030, 6040, 6050, 6060, 6070, 6080, 6090, 7000, 7010, 7020, 7030, 7040, 7050, 7060, 7070, 7080, 7090, 8000, 8010, 8020, 8030, 8040, 8050, 8060, 8070, 8080, 8090], \"supportsRss\": true, \"supportsSearch\": true}', 'NewznabSettings', 1);"

echo ""
echo "📡 Step 4: Creating download directories..."

# Create download directories with proper permissions
mkdir -p /mnt/truenas/downloads/complete/{movies,tv,music}
mkdir -p /mnt/truenas/downloads/incomplete
chown -R 1000:1000 /mnt/truenas/downloads

echo ""
echo "📡 Step 5: Updating Transmission settings..."

# Update Transmission settings to use correct paths
cat > config/transmission/settings.json << 'EOF'
{
    "alt-speed-down": 50,
    "alt-speed-enabled": false,
    "alt-speed-time-begin": 540,
    "alt-speed-time-day": 127,
    "alt-speed-time-enabled": false,
    "alt-speed-time-end": 1020,
    "alt-speed-up": 50,
    "bind-address-ipv4": "0.0.0.0",
    "bind-address-ipv6": "::",
    "blocklist-enabled": false,
    "blocklist-url": "http://www.example.com/blocklist",
    "cache-size-mb": 4,
    "dht-enabled": true,
    "download-dir": "/downloads/complete",
    "download-queue-enabled": true,
    "download-queue-size": 5,
    "encryption": 1,
    "idle-seeding-limit": 30,
    "idle-seeding-limit-enabled": false,
    "incomplete-dir": "/downloads/incomplete",
    "incomplete-dir-enabled": true,
    "lpd-enabled": false,
    "message-level": 2,
    "peer-congestion-algorithm": "",
    "peer-id-ttl-hours": 6,
    "peer-limit-global": 200,
    "peer-limit-per-torrent": 50,
    "peer-port": 51413,
    "peer-port-random-high": 65535,
    "peer-port-random-low": 49152,
    "peer-port-random-on-start": false,
    "peer-socket-tos": "default",
    "pex-enabled": true,
    "port-forwarding-enabled": true,
    "preallocation": 1,
    "prefetch-enabled": true,
    "queue-stalled-enabled": true,
    "queue-stalled-minutes": 30,
    "ratio-limit": 2,
    "ratio-limit-enabled": false,
    "rename-partial-files": true,
    "rpc-authentication-required": false,
    "rpc-bind-address": "0.0.0.0",
    "rpc-enabled": true,
    "rpc-host-whitelist": "*",
    "rpc-host-whitelist-enabled": false,
    "rpc-password": "",
    "rpc-port": 9091,
    "rpc-url": "/transmission/",
    "rpc-username": "",
    "rpc-whitelist": "*",
    "rpc-whitelist-enabled": false,
    "scrape-paused-torrents-enabled": true,
    "script-torrent-done-enabled": false,
    "script-torrent-done-filename": "",
    "seed-queue-enabled": false,
    "seed-queue-size": 10,
    "speed-limit-down": 100,
    "speed-limit-down-enabled": false,
    "speed-limit-up": 100,
    "speed-limit-up-enabled": false,
    "start-added-torrents": true,
    "trash-original-torrent-files": false,
    "umask": 2,
    "upload-slots-per-torrent": 14,
    "utp-enabled": true,
    "watch-dir": "/watch",
    "watch-dir-enabled": true
}
EOF

echo ""
echo "🎉 COMPREHENSIVE FIX COMPLETE!"
echo "==============================="
echo ""
echo "✅ Issues Fixed:"
echo "   • Download clients configured with correct paths"
echo "   • Popular indexers added to Prowlarr"
echo "   • *arr services connected to Prowlarr"
echo "   • Download directories created"
echo "   • Transmission settings updated"
echo ""
echo "🌐 Access your services:"
echo "   • Radarr:   http://localhost:7878"
echo "   • Sonarr:   http://localhost:8989"
echo "   • Lidarr:   http://localhost:8686"
echo "   • Prowlarr: http://localhost:9696"
echo "   • Transmission: http://localhost:9091/transmission/web/"
echo ""
echo "📋 Next Steps:"
echo "   1. Restart the stack: docker compose restart"
echo "   2. Visit each *arr service and verify:"
echo "      - Download client is connected"
echo "      - Indexers are available"
echo "      - RSS sync is enabled"
echo "   3. Test automatic search functionality"
echo "   4. Start downloading media!" 