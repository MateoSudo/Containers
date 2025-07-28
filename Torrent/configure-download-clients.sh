#!/bin/bash

echo "🔧 Configuring Download Clients for *arr Services..."

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Check if services are ready
echo "🔍 Checking service readiness..."
for service in radarr sonarr lidarr; do
    if curl -s http://localhost:$(case $service in radarr) echo 7878;; sonarr) echo 8989;; lidarr) echo 8686;; esac) >/dev/null 2>&1; then
        echo "✅ $service is ready"
    else
        echo "⚠️  $service may still be starting"
    fi
done

echo ""
echo "📡 Configuring Radarr with Transmission..."
sqlite3 config/radarr/radarr.db "INSERT OR REPLACE INTO DownloadClients (Enable, Name, Implementation, Settings, ConfigContract, Priority, RemoveCompletedDownloads, RemoveFailedDownloads) VALUES (1, 'Transmission', 'Transmission', '{\"host\": \"172.19.0.4\", \"port\": 9091, \"username\": \"\", \"password\": \"\", \"category\": \"movies\", \"urlBase\": \"/transmission/\"}', 'TransmissionSettings', 1, 1, 1);"

echo "📡 Configuring Sonarr with Transmission..."
sqlite3 config/sonarr/sonarr.db "INSERT OR REPLACE INTO DownloadClients (Enable, Name, Implementation, Settings, ConfigContract, Priority, RemoveCompletedDownloads, RemoveFailedDownloads) VALUES (1, 'Transmission', 'Transmission', '{\"host\": \"172.19.0.4\", \"port\": 9091, \"username\": \"\", \"password\": \"\", \"category\": \"tv\", \"urlBase\": \"/transmission/\"}', 'TransmissionSettings', 1, 1, 1);"

echo "📡 Configuring Lidarr with Transmission..."
sqlite3 config/lidarr/lidarr.db "INSERT OR REPLACE INTO DownloadClients (Enable, Name, Implementation, Settings, ConfigContract, Priority, RemoveCompletedDownloads, RemoveFailedDownloads) VALUES (1, 'Transmission', 'Transmission', '{\"host\": \"172.19.0.4\", \"port\": 9091, \"username\": \"\", \"password\": \"\", \"category\": \"music\", \"urlBase\": \"/transmission/\"}', 'TransmissionSettings', 1, 1, 1);"

echo ""
echo "✅ Download clients configured successfully!"
echo ""
echo "🌐 Access your services:"
echo "   • Radarr:   http://localhost:7878"
echo "   • Sonarr:   http://localhost:8989"
echo "   • Lidarr:   http://localhost:8686"
echo "   • Transmission: http://localhost:9091/transmission/web/"
echo ""
echo "📋 Next steps:"
echo "   1. Visit each *arr service and verify Transmission is configured"
echo "   2. Test download client connectivity"
echo "   3. Configure indexers in Prowlarr/Jackett"
echo "   4. Start downloading media!" 