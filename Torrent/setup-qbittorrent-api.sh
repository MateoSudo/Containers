#!/bin/bash

echo "🔧 Setting up qBittorrent authentication via API..."

# Wait for qBittorrent to be ready
echo "Waiting for qBittorrent to start..."
sleep 30

# Test if we can access without authentication
VERSION=$(curl -s http://localhost:8084/api/v2/app/version)
if [ -z "$VERSION" ] || [ "$VERSION" = "Unauthorized" ]; then
    echo "❌ Cannot access qBittorrent API"
    exit 1
fi

echo "✅ qBittorrent accessible, version: $VERSION"

# Set up authentication via API
echo "🔐 Setting up admin/adminadmin credentials..."
RESULT=$(curl -s -d 'json={"web_ui_username":"admin","web_ui_password":"adminadmin","bypass_local_auth":false,"bypass_auth_subnet_whitelist_enabled":false}' http://localhost:8084/api/v2/app/setPreferences)

if [ "$RESULT" = "Ok." ] || [ -z "$RESULT" ]; then
    echo "✅ Authentication configured successfully!"
else
    echo "❌ Failed to set authentication: $RESULT"
    exit 1
fi

# Test authentication
echo "🧪 Testing authentication..."
sleep 5

# Test login
LOGIN_RESULT=$(curl -s -d 'username=admin&password=adminadmin' http://localhost:8084/api/v2/auth/login)
if [ "$LOGIN_RESULT" = "Ok." ]; then
    echo "✅ Authentication test successful!"
    
    # Now run the arr services fix
    echo "🔗 Running *arr services configuration..."
    chmod +x fix-arr-connections.sh
    ./fix-arr-connections.sh
    
else
    echo "❌ Authentication test failed: $LOGIN_RESULT"
    exit 1
fi

echo ""
echo "🌐 Cosmos should route to: http://torrent-qbittorrent:8080"
echo "🏠 Local access: http://localhost:8084"
echo "👤 Username: admin"
echo "🔐 Password: adminadmin" 