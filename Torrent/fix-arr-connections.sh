#!/bin/bash

echo "🔧 Fixing *arr service connections to qBittorrent..."

# Stop all containers
echo "Stopping containers..."
docker stop torrent-radarr torrent-sonarr torrent-lidarr torrent-prowlarr 2>/dev/null

# Wait a moment
sleep 5

# Clear existing download clients from all *arr services
echo "🗑️ Clearing existing download clients..."

# Clear Radarr download clients
if [ -f config/radarr/radarr.db ]; then
    echo "Clearing Radarr download clients..."
    sqlite3 config/radarr/radarr.db "DELETE FROM DownloadClients WHERE Name='qBittorrent';"
fi

# Clear Sonarr download clients  
if [ -f config/sonarr/sonarr.db ]; then
    echo "Clearing Sonarr download clients..."
    sqlite3 config/sonarr/sonarr.db "DELETE FROM DownloadClients WHERE Name='qBittorrent';"
fi

# Clear Lidarr download clients
if [ -f config/lidarr/lidarr.db ]; then
    echo "Clearing Lidarr download clients..."
    sqlite3 config/lidarr/lidarr.db "DELETE FROM DownloadClients WHERE Name='qBittorrent';"
fi

echo "✅ Download clients cleared!"

# Start containers back up
echo "🚀 Starting containers..."
docker start torrent-radarr torrent-sonarr torrent-lidarr torrent-prowlarr

# Wait for services to start
echo "Waiting for services to initialize..."
sleep 30

# Add qBittorrent download client to each service
echo "🔗 Adding qBittorrent download clients..."

# Add to Radarr
echo "Adding to Radarr..."
sqlite3 config/radarr/radarr.db "INSERT INTO DownloadClients (Enable, Name, Implementation, Settings, ConfigContract, Priority, RemoveCompletedDownloads, RemoveFailedDownloads) VALUES (1, 'qBittorrent', 'QBittorrent', '{\"host\": \"qbittorrent\", \"port\": 8080, \"username\": \"admin\", \"password\": \"adminadmin\", \"category\": \"movies\", \"recentMoviePriority\": 0, \"olderMoviePriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false, \"urlBase\": \"\"}', 'QBittorrentSettings', 1, 1, 1);"

# Add to Sonarr  
echo "Adding to Sonarr..."
sqlite3 config/sonarr/sonarr.db "INSERT INTO DownloadClients (Enable, Name, Implementation, Settings, ConfigContract, Priority, RemoveCompletedDownloads, RemoveFailedDownloads) VALUES (1, 'qBittorrent', 'QBittorrent', '{\"host\": \"qbittorrent\", \"port\": 8080, \"username\": \"admin\", \"password\": \"adminadmin\", \"category\": \"tv\", \"recentTvPriority\": 0, \"olderTvPriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false, \"urlBase\": \"\"}', 'QBittorrentSettings', 1, 1, 1);"

# Add to Lidarr
echo "Adding to Lidarr..."  
sqlite3 config/lidarr/lidarr.db "INSERT INTO DownloadClients (Enable, Name, Implementation, Settings, ConfigContract, Priority, RemoveCompletedDownloads, RemoveFailedDownloads) VALUES (1, 'qBittorrent', 'QBittorrent', '{\"host\": \"qbittorrent\", \"port\": 8080, \"username\": \"admin\", \"password\": \"adminadmin\", \"category\": \"music\", \"recentTvPriority\": 0, \"olderTvPriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false, \"urlBase\": \"\"}', 'QBittorrentSettings', 1, 1, 1);"

echo "✅ All download clients configured!"
echo ""
echo "🌐 Cosmos should route to: http://torrent-qbittorrent:8080"
echo "🏠 Local access: http://localhost:8084"
echo "👤 Username: admin"
echo "🔐 Password: adminadmin" 