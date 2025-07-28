#!/bin/bash

echo "🔧 Configuring qBittorrent authentication (admin/adminadmin)..."

# Stop qBittorrent container
docker stop torrent-qbittorrent 2>/dev/null || true

# Ensure config directory exists
mkdir -p config/qbittorrent/qBittorrent

# Update qBittorrent configuration with proper credentials
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
WebUI\Password_PBKDF2="@ByteArray(fZe2rPDhHrr8LpVkXMLHdg==:oAhbIVaK7bvC3m4O6H8XfJ1DLKL1ER4UdyGPrOAkRzI=)"
WebUI\Port=8080
WebUI\ServerDomains=qbittorrent.mrintellisense.com
WebUI\UseUPnP=false
WebUI\Username=admin
EOF

# Set proper permissions
chown -R 1000:1000 config/qbittorrent/
chmod -R 755 config/qbittorrent/

echo "✅ qBittorrent authentication configured!"
echo "👤 Username: admin"
echo "🔐 Password: adminadmin"
echo ""
echo "🔄 Restart your stack with: ./start-stack.sh" 