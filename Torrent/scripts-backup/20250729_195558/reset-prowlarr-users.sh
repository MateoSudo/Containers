#!/bin/bash

echo "🔧 Prowlarr User Database Reset"
echo "================================"
echo ""

echo "📋 Current Status:"
echo "   ✅ User 'matthew' has been deleted from database"
echo "   ✅ Prowlarr has been restarted"
echo "   ✅ Prowlarr is running and ready for new user setup"
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

echo "🔍 Alternative methods if setup wizard doesn't appear:"
echo ""
echo "Method 1: Clear entire database (nuclear option)"
echo "   sqlite3 config/prowlarr/prowlarr.db 'DELETE FROM Users;'"
echo "   docker restart torrent-prowlarr"
echo ""

echo "Method 2: Delete and recreate database"
echo "   rm config/prowlarr/prowlarr.db"
echo "   docker restart torrent-prowlarr"
echo ""

echo "Method 3: Reset via API (if you know current password)"
echo "   curl -X POST http://localhost:9696/api/v1/user/reset"
echo ""

echo "✅ Your Prowlarr is ready for new user creation!"
echo "   Visit: http://localhost:9696" 