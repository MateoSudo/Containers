#!/bin/bash
# Script to disable qBittorrent authentication via API

echo "🔧 Attempting to disable qBittorrent authentication via API..."

# Wait for qBittorrent to start
sleep 30

# Try to access without auth first
echo "Testing direct API access..."
VERSION=$(curl -s http://localhost:8084/api/v2/app/version)

if [ "$VERSION" != "Unauthorized" ] && [ ! -z "$VERSION" ]; then
    echo "✅ qBittorrent accessible without authentication!"
    echo "Version: $VERSION"
    exit 0
fi

# Try with default credentials
echo "Trying with default credentials..."
COOKIE=$(curl -s -c /tmp/qb_cookie -d 'username=admin&password=adminadmin' http://localhost:8084/api/v2/auth/login)

if [ "$COOKIE" = "Ok." ]; then
    echo "✅ Logged in successfully with admin/adminadmin"
    
    # Disable authentication
    echo "Disabling authentication..."
    curl -s -b /tmp/qb_cookie -d 'json={"web_ui_username":"","web_ui_password":"","bypass_local_auth":true,"bypass_auth_subnet_whitelist_enabled":true,"bypass_auth_subnet_whitelist":"0.0.0.0/0"}' http://localhost:8084/api/v2/app/setPreferences
    
    echo "✅ Authentication disabled!"
    
    # Test access without auth
    sleep 5
    NEW_VERSION=$(curl -s http://localhost:8084/api/v2/app/version)
    if [ "$NEW_VERSION" != "Unauthorized" ]; then
        echo "✅ SUCCESS: qBittorrent now accessible without authentication!"
    else
        echo "⚠️ Authentication may still be required"
    fi
else
    echo "❌ Could not login with default credentials"
    echo "Response: $COOKIE"
fi

rm -f /tmp/qb_cookie 