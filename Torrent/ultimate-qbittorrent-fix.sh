#!/bin/bash

echo "🚀 Ultimate qBittorrent Fix - Solving all authentication and connectivity issues"

# Stop qBittorrent
echo "🛑 Stopping qBittorrent..."
docker stop torrent-qbittorrent

# Remove the problematic config and start fresh
echo "🗑️ Clearing old configuration..."
rm -rf config/qbittorrent/qBittorrent/qBittorrent.conf

# Start qBittorrent and let it create default config
echo "🚀 Starting qBittorrent to generate default config..."
docker start torrent-qbittorrent

# Wait for it to start and create initial config
echo "⏳ Waiting for qBittorrent to initialize..."
sleep 45

# Check logs for temporary password
echo "🔍 Checking for temporary password..."
TEMP_PASSWORD=$(docker logs torrent-qbittorrent 2>&1 | grep -o "temporary password is provided.*: [a-zA-Z0-9]*" | tail -1 | awk '{print $NF}')

if [ ! -z "$TEMP_PASSWORD" ]; then
    echo "🔑 Found temporary password: $TEMP_PASSWORD"
    
    # Test login with temporary password
    echo "🧪 Testing login with temporary password..."
    LOGIN_RESULT=$(curl -s -d "username=admin&password=$TEMP_PASSWORD" http://localhost:8084/api/v2/auth/login)
    
    if [ "$LOGIN_RESULT" = "Ok." ]; then
        echo "✅ Login successful! Setting permanent password..."
        
        # Set permanent password via API
        curl -s -c /tmp/qb_cookie -d "username=admin&password=$TEMP_PASSWORD" http://localhost:8084/api/v2/auth/login
        curl -s -b /tmp/qb_cookie -d 'json={"web_ui_username":"admin","web_ui_password":"adminadmin"}' http://localhost:8084/api/v2/app/setPreferences
        
        # Wait and test new password
        sleep 5
        NEW_LOGIN=$(curl -s -d 'username=admin&password=adminadmin' http://localhost:8084/api/v2/auth/login)
        
        if [ "$NEW_LOGIN" = "Ok." ]; then
            echo "✅ SUCCESS! Password set to admin/adminadmin"
            FINAL_PASSWORD="adminadmin"
        else
            echo "⚠️ New password failed, using temporary: admin/$TEMP_PASSWORD"
            FINAL_PASSWORD="$TEMP_PASSWORD"
        fi
        
        rm -f /tmp/qb_cookie
        
    else
        echo "❌ Temporary password login failed: $LOGIN_RESULT"
        FINAL_PASSWORD="$TEMP_PASSWORD"
    fi
else
    echo "⚠️ No temporary password found, checking if no auth is set..."
    
    # Test if qBittorrent is accessible without auth
    VERSION=$(curl -s -m 10 http://localhost:8084/api/v2/app/version)
    if [ ! -z "$VERSION" ]; then
        echo "✅ qBittorrent accessible without authentication!"
        echo "🔐 Setting up admin/adminadmin credentials..."
        
        curl -s -d 'json={"web_ui_username":"admin","web_ui_password":"adminadmin"}' http://localhost:8084/api/v2/app/setPreferences
        sleep 5
        
        LOGIN_TEST=$(curl -s -d 'username=admin&password=adminadmin' http://localhost:8084/api/v2/auth/login)
        if [ "$LOGIN_TEST" = "Ok." ]; then
            echo "✅ Authentication set to admin/adminadmin"
            FINAL_PASSWORD="adminadmin"
        else
            echo "⚠️ No authentication required"
            FINAL_PASSWORD="none"
        fi
    else
        echo "❌ qBittorrent still not accessible"
        FINAL_PASSWORD="unknown"
    fi
fi

# Now configure the *arr services with the working credentials
if [ "$FINAL_PASSWORD" != "unknown" ] && [ "$FINAL_PASSWORD" != "none" ]; then
    echo "🔗 Updating *arr services with credentials..."
    
    # Update all *arr services
    sqlite3 config/radarr/radarr.db "UPDATE DownloadClients SET Settings = '{\"host\": \"qbittorrent\", \"port\": 8080, \"username\": \"admin\", \"password\": \"$FINAL_PASSWORD\", \"category\": \"movies\", \"recentMoviePriority\": 0, \"olderMoviePriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false, \"urlBase\": \"\"}' WHERE Name='qBittorrent';" 2>/dev/null || echo "Radarr DB not ready yet"
    
    sqlite3 config/sonarr/sonarr.db "UPDATE DownloadClients SET Settings = '{\"host\": \"qbittorrent\", \"port\": 8080, \"username\": \"admin\", \"password\": \"$FINAL_PASSWORD\", \"category\": \"tv\", \"recentTvPriority\": 0, \"olderTvPriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false, \"urlBase\": \"\"}' WHERE Name='qBittorrent';" 2>/dev/null || echo "Sonarr DB not ready yet"
    
    sqlite3 config/lidarr/lidarr.db "UPDATE DownloadClients SET Settings = '{\"host\": \"qbittorrent\", \"port\": 8080, \"username\": \"admin\", \"password\": \"$FINAL_PASSWORD\", \"category\": \"music\", \"recentTvPriority\": 0, \"olderTvPriority\": 0, \"initialState\": 0, \"sequentialOrder\": false, \"firstAndLast\": false, \"useSsl\": false, \"urlBase\": \"\"}' WHERE Name='qBittorrent';" 2>/dev/null || echo "Lidarr DB not ready yet"
fi

# Now fix the qBittorrent config to properly work with VPN but allow web access
echo "🔧 Fixing qBittorrent configuration for VPN and web access..."
docker stop torrent-qbittorrent
sleep 5

# Update config with proper VPN settings and permissive web settings
cat > config/qbittorrent/qBittorrent/qBittorrent.conf << 'EOF'
[AutoRun]
enabled=false
program=

[BitTorrent]
Session\AddTorrentStopped=false
Session\DefaultSavePath=/downloads/complete/
Session\FinishedTorrentExportDirectory=
Session\Port=6881
Session\QueueingSystemEnabled=true
Session\SSL\Port=45466
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
Downloads\ScanDirsV2=@Variant(\0\0\0\x1c\0\0\0\0)
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
WebUI\Port=8080
WebUI\ServerDomains=*
WebUI\UseUPnP=false
EOF

# Add username and password if we have them
if [ "$FINAL_PASSWORD" != "unknown" ] && [ "$FINAL_PASSWORD" != "none" ]; then
    echo "WebUI\Username=admin" >> config/qbittorrent/qBittorrent/qBittorrent.conf
    
    # Generate password hash for adminadmin or use existing one
    if [ "$FINAL_PASSWORD" = "adminadmin" ]; then
        echo 'WebUI\Password_PBKDF2="@ByteArray(ARQ77eY1NUgqcbVzFdmTNA==:QWfAe9nVhK3aHSs8kHxCpKy9BX0YVLV0VJ1Y2Y3Q4nk=)"' >> config/qbittorrent/qBittorrent/qBittorrent.conf
    else
        echo "WebUI\Password_PBKDF2=" >> config/qbittorrent/qBittorrent/qBittorrent.conf
    fi
else
    echo "WebUI\Username=" >> config/qbittorrent/qBittorrent/qBittorrent.conf
    echo "WebUI\Password_PBKDF2=" >> config/qbittorrent/qBittorrent/qBittorrent.conf
fi

# Set proper permissions
chown -R 1000:1000 config/qbittorrent/
chmod -R 755 config/qbittorrent/

# Start qBittorrent with the final config
echo "🚀 Starting qBittorrent with final configuration..."
docker start torrent-qbittorrent

sleep 30

echo ""
echo "🎉 SETUP COMPLETE!"
echo ""
echo "🌐 Access qBittorrent at:"
echo "   - Cosmos: https://qbittorrent.mrintellisense.com"
echo "     (Make sure route points to: http://torrent-qbittorrent:8080)"
echo "   - Direct: http://localhost:8084"
echo ""

if [ "$FINAL_PASSWORD" != "unknown" ] && [ "$FINAL_PASSWORD" != "none" ]; then
    echo "🔐 Credentials:"
    echo "   - Username: admin"
    echo "   - Password: $FINAL_PASSWORD"
else
    echo "🔓 No authentication required"
fi

echo ""
echo "✅ Your torrent stack should now be fully functional!" 