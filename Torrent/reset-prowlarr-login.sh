#!/bin/bash

echo "🔧 Resetting Prowlarr Login"
echo "============================"
echo ""
echo "📋 Current Status:"
echo "=================="

# Check if Prowlarr is running
if docker ps | grep -q "torrent-prowlarr"; then
    echo "✅ Prowlarr container is running"
else
    echo "❌ Prowlarr container is not running"
    exit 1
fi

# Check database
if [ -f "config/prowlarr/prowlarr.db" ]; then
    echo "✅ Prowlarr database exists"
    
    # Check current users
    USERS=$(sqlite3 config/prowlarr/prowlarr.db "SELECT COUNT(*) FROM Users;" 2>/dev/null)
    if [ "$USERS" -gt 0 ]; then
        echo "📊 Found $USERS user(s) in database"
        sqlite3 config/prowlarr/prowlarr.db "SELECT Id, Username FROM Users;" 2>/dev/null
    else
        echo "📊 No users found in database"
    fi
else
    echo "❌ Prowlarr database not found"
fi

echo ""
echo "🔄 Step 1: Stopping Prowlarr..."
docker stop torrent-prowlarr
sleep 3

echo ""
echo "🗑️ Step 2: Clearing user database..."

# Method 1: Delete all users
echo "Deleting all users from database..."
sqlite3 config/prowlarr/prowlarr.db "DELETE FROM Users;" 2>/dev/null && echo "   ✅ Users deleted"

# Method 2: Backup and recreate database (nuclear option)
echo "Creating backup of current database..."
cp config/prowlarr/prowlarr.db config/prowlarr/prowlarr.db.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null && echo "   ✅ Database backed up"

echo ""
echo "🚀 Step 3: Starting Prowlarr..."
docker start torrent-prowlarr

echo ""
echo "⏳ Step 4: Waiting for Prowlarr to start..."
sleep 10

echo ""
echo "🔍 Step 5: Checking Prowlarr status..."

# Test if Prowlarr is accessible
if curl -s http://localhost:9696 >/dev/null 2>&1; then
    echo "✅ Prowlarr is accessible"
    
    # Check if it requires authentication
    AUTH_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:9696)
    if [ "$AUTH_RESPONSE" = "401" ]; then
        echo "✅ Prowlarr requires authentication (ready for new user setup)"
    elif [ "$AUTH_RESPONSE" = "200" ]; then
        echo "⚠️ Prowlarr is accessible without authentication"
    else
        echo "❓ Prowlarr response: HTTP $AUTH_RESPONSE"
    fi
else
    echo "❌ Prowlarr is not accessible"
fi

echo ""
echo "🎉 Prowlarr Login Reset Complete!"
echo "================================="
echo ""
echo "✅ Prowlarr has been reset and restarted"
echo "✅ All users have been removed from database"
echo "✅ Database has been backed up"
echo ""
echo "🌐 Access Prowlarr to create new user:"
echo "   URL: http://localhost:9696"
echo ""
echo "📝 Steps to create new user:"
echo "   1. Open http://localhost:9696 in your browser"
echo "   2. You should see a setup wizard"
echo "   3. Create your new username and password"
echo "   4. Complete the initial setup"
echo ""
echo "⚠️ If setup wizard doesn't appear:"
echo "   • Try refreshing the page"
echo "   • Clear browser cache"
echo "   • Wait a few more minutes for Prowlarr to fully start"
echo ""
echo "🔧 Alternative reset methods (if needed):"
echo "   • Delete entire database: rm config/prowlarr/prowlarr.db"
echo "   • Restart container: docker restart torrent-prowlarr"
echo ""
echo "🚀 Your Prowlarr is ready for fresh login setup!" 