#!/bin/bash

echo "🚀 Complete qBittorrent and *arr services fix..."

# Stop all containers
echo "🛑 Stopping all containers..."
docker compose down

# Create proper qBittorrent config with admin/adminadmin
echo "🔧 Creating qBittorrent config with admin/adminadmin..."
mkdir -p config/qbittorrent/qBittorrent

cat > config/qbittorrent/qBittorrent/qBittorrent.conf << 'EOF'
[BitTorrent]
Session\AddTorrentStopped=false
Session\DefaultSavePath=/downloads/complete/
Session\FinishedTorrentExportDirectory=
Session\Port=6881
Session\QueueingSystemEnabled=true
Session\SSL\Port=26530
Session\ShareLimitAction=Stop
Session\TempPath=/downloads/incomplete/
Session\TorrentExportDirectory=

[LegalNotice]
Accepted=true

[Meta]
MigrationVersion=8

[Network]
Cookies=@Invalid()
PortForwardingEnabled=false
Proxy\HostnameLookupEnabled=true
Proxy\IP=pia-vpn
Proxy\Password=
Proxy\Port=8388
Proxy\Profiles\BitTorrent=true
Proxy\Profiles\Misc=false
Proxy\Profiles\RSS=false
Proxy\Type=SOCKS5
Proxy\Username=

[Preferences]
Connection\PortRangeMax=6881
Connection\PortRangeMin=6881
Connection\UPnP=false
Connection\UseRandomPort=false
Downloads\FinishedTorrentExportDir=
Downloads\SavePath=/downloads/complete/
Downloads\TempPath=/downloads/incomplete/
Downloads\TorrentExportDir=
General\Locale=en_US
WebUI\Address=*
WebUI\AlternativeUIEnabled=false
WebUI\AuthSubnetWhitelist=0.0.0.0/0
WebUI\AuthSubnetWhitelistEnabled=false
WebUI\BanDuration=3600
WebUI\BypassAuthenticationSubnetWhitelist=
WebUI\BypassLocalAuth=false
WebUI\HTTPS\Enabled=false
WebUI\LocalHostAuth=false
WebUI\MaxAuthenticationFailCount=5
WebUI\Password_PBKDF2="@ByteArray(ARQ77eY1NUgqcbVzFdmTNA==:QWfAe9nVhK3aHSs8kHxCpKy9BX0YVLV0VJ1Y2Y3Q4nk=)"
WebUI\Port=8080
WebUI\ServerDomains=qbittorrent.mrintellisense.com
WebUI\UseUPnP=false
WebUI\Username=admin
EOF

# Set proper permissions
chown -R 1000:1000 config/qbittorrent/
chmod -R 755 config/qbittorrent/

# Clear any existing *arr download client configurations
echo "🗑️ Clearing existing *arr download clients..."
if [ -f config/radarr/radarr.db ]; then
    sqlite3 config/radarr/radarr.db "DELETE FROM DownloadClients WHERE Name='qBittorrent';" 2>/dev/null || true
fi

if [ -f config/sonarr/sonarr.db ]; then
    sqlite3 config/sonarr/sonarr.db "DELETE FROM DownloadClients WHERE Name='qBittorrent';" 2>/dev/null || true
fi

if [ -f config/lidarr/lidarr.db ]; then
    sqlite3 config/lidarr/lidarr.db "DELETE FROM DownloadClients WHERE Name='qBittorrent';" 2>/dev/null || true
fi

# Start the stack
echo "🚀 Starting the stack..."
docker compose up -d

# Wait for qBittorrent to start
echo "⏳ Waiting for qBittorrent to start..."
sleep 60

# Test qBittorrent authentication
echo "🧪 Testing qBittorrent authentication..."
LOGIN_TEST=$(curl -s -d 'username=admin&password=adminadmin' http://localhost:8084/api/v2/auth/login)
if [ "$LOGIN_TEST" = "Ok." ]; then
    echo "✅ qBittorrent authentication working!"
else
    echo "⚠️ qBittorrent authentication test: $LOGIN_TEST"
fi

# Wait for *arr services to start
echo "⏳ Waiting for *arr services to start..."
sleep 30

# Configure *arr services
echo "🔗 Configuring *arr services..."

# Wait for databases to be ready
for service in radarr sonarr lidarr; do
    while [ ! -f config/$service/$service.db ]; do
        echo "Waiting for $service database..."
        sleep 5
    done
    echo "✅ $service database ready"
done

# Add qBittorrent to each service
echo "Adding qBittorrent to Radarr..."
sqlite3 config/radarr/radarr.db "INSERT OR REPLACE INTO DownloadClients (Enable, Name, Implementation, Settings, ConfigContract, Priority, RemoveCompletedDownloads, RemoveFailedDownloads) VALUES (1, 'qBittorrent', 'QBittorrent', '{\"host\": \"qbittorrent\", \"port\": 8080, \"username\": \"admin\", \"password\": \"adminadmin\", \"category\": \"movies\", \"recentMoviePriority\": 0, \"olderMoviePriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false, \"urlBase\": \"\"}', 'QBittorrentSettings', 1, 1, 1);"

echo "Adding qBittorrent to Sonarr..."
sqlite3 config/sonarr/sonarr.db "INSERT OR REPLACE INTO DownloadClients (Enable, Name, Implementation, Settings, ConfigContract, Priority, RemoveCompletedDownloads, RemoveFailedDownloads) VALUES (1, 'qBittorrent', 'QBittorrent', '{\"host\": \"qbittorrent\", \"port\": 8080, \"username\": \"admin\", \"password\": \"adminadmin\", \"category\": \"tv\", \"recentTvPriority\": 0, \"olderTvPriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false, \"urlBase\": \"\"}', 'QBittorrentSettings', 1, 1, 1);"

echo "Adding qBittorrent to Lidarr..."
sqlite3 config/lidarr/lidarr.db "INSERT OR REPLACE INTO DownloadClients (Enable, Name, Implementation, Settings, ConfigContract, Priority, RemoveCompletedDownloads, RemoveFailedDownloads) VALUES (1, 'qBittorrent', 'QBittorrent', '{\"host\": \"qbittorrent\", \"port\": 8080, \"username\": \"admin\", \"password\": \"adminadmin\", \"category\": \"music\", \"recentTvPriority\": 0, \"olderTvPriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false, \"urlBase\": \"\"}', 'QBittorrentSettings', 1, 1, 1);"

echo ""
echo "✅ Setup Complete!"
echo ""
echo "🌐 Access Points:"
echo "   - Cosmos Proxy: https://qbittorrent.mrintellisense.com"
echo "     (Route to: http://torrent-qbittorrent:8080)"
echo "   - Direct: http://localhost:8084"
echo ""
echo "🔐 Credentials:"
echo "   - Username: admin"
echo "   - Password: adminadmin"
echo ""
echo "🚨 IMPORTANT: Update your Cosmos route to point to:"
echo "   http://torrent-qbittorrent:8080 (NOT 8084!)" 