#!/bin/bash

echo "🔧 Fixing Prowlarr Proxy Configuration"
echo "======================================"

echo ""
echo "📋 Step 1: Checking current Prowlarr status..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:9696 | grep -q "200\|401\|302"; then
    echo "✅ Prowlarr is accessible"
else
    echo "❌ Prowlarr is not accessible"
    exit 1
fi

echo ""
echo "📋 Step 2: Stopping Prowlarr..."
docker stop torrent-prowlarr

echo ""
echo "📋 Step 3: Creating backup of current database..."
cp config/prowlarr/prowlarr.db config/prowlarr/prowlarr.db.backup.$(date +%Y%m%d_%H%M%S)
echo "✅ Database backed up"

echo ""
echo "📋 Step 4: Checking for proxy configurations..."
echo "Checking Config table for proxy settings..."
sqlite3 config/prowlarr/prowlarr.db "SELECT Key, Value FROM Config WHERE Key LIKE '%proxy%' OR Key LIKE '%Proxy%' OR Value LIKE '%proxy%' OR Value LIKE '%vpn%';"

echo ""
echo "Checking IndexerProxies table..."
sqlite3 config/prowlarr/prowlarr.db "SELECT * FROM IndexerProxies;"

echo ""
echo "📋 Step 5: Removing any proxy configurations..."
# Remove any proxy configurations from the Config table
sqlite3 config/prowlarr/prowlarr.db "DELETE FROM Config WHERE Key LIKE '%proxy%' OR Key LIKE '%Proxy%' OR Value LIKE '%proxy%' OR Value LIKE '%vpn%' OR Value LIKE '%torrent-pia-vpn%';"

# Remove any proxy configurations from IndexerProxies
sqlite3 config/prowlarr/prowlarr.db "DELETE FROM IndexerProxies;"

echo "✅ Proxy configurations removed"

echo ""
echo "📋 Step 6: Starting Prowlarr..."
docker start torrent-prowlarr

echo ""
echo "📋 Step 7: Waiting for Prowlarr to start..."
sleep 10

echo ""
echo "📋 Step 8: Testing Prowlarr access..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:9696 | grep -q "200\|401\|302"; then
    echo "✅ Prowlarr is accessible"
else
    echo "❌ Prowlarr is still not accessible"
    echo "Checking Prowlarr logs..."
    docker logs torrent-prowlarr --tail=10
    exit 1
fi

echo ""
echo "🎉 Prowlarr Proxy Fix Complete!"
echo "==============================="
echo ""
echo "✅ Prowlarr proxy configurations removed"
echo "✅ Prowlarr restarted successfully"
echo "✅ Prowlarr is now accessible"
echo ""
echo "🌐 Access Prowlarr:"
echo "   URL: http://localhost:9696"
echo ""
echo "📝 Next Steps:"
echo "   1. Open http://localhost:9696 in your browser"
echo "   2. Log in with your credentials"
echo "   3. Go to Settings → Indexers"
echo "   4. Configure your indexers (without proxy)"
echo "   5. Test the indexers"
echo ""
echo "⚠️  If you need to use a proxy for specific indexers:"
echo "   • Configure it through the web interface"
echo "   • Use the correct proxy settings (not torrent-pia-vpn)"
echo "   • Test the proxy connection first" 