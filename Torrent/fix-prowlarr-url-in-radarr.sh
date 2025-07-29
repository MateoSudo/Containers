#!/bin/bash

echo "🔧 Fixing Prowlarr URL in Radarr Configuration"
echo "=============================================="
echo ""
echo "❌ Problem: http://127.0.0.4:9696 is invalid"
echo "✅ Solution: Use correct IP address"
echo ""

# Test which URL works best
echo "🔍 Testing connectivity options..."
LOCALHOST_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:9696 2>/dev/null)
STATIC_IP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://172.19.0.4:9696 2>/dev/null)

echo "localhost (127.0.0.1): $LOCALHOST_STATUS"
echo "static IP (172.19.0.4): $STATIC_IP_STATUS"
echo ""

# Choose the best URL
if [ "$LOCALHOST_STATUS" = "401" ]; then
    PROWLARR_URL="http://127.0.0.1:9696"
    echo "✅ Using localhost: $PROWLARR_URL"
elif [ "$STATIC_IP_STATUS" = "401" ]; then
    PROWLARR_URL="http://172.19.0.4:9696"
    echo "✅ Using static IP: $PROWLARR_URL"
else
    PROWLARR_URL="http://127.0.0.1:9696"
    echo "⚠️ Using localhost as fallback: $PROWLARR_URL"
fi

echo ""
echo "🔧 Updating Radarr configuration..."

# Update Radarr's Prowlarr indexer configuration
sqlite3 config/radarr/radarr.db "UPDATE Indexers SET Settings = '{\"baseUrl\": \"$PROWLARR_URL\", \"apiKey\": \"\", \"categories\": [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060, 2070, 2080, 2090], \"animeCategories\": [5000, 5010, 5020, 5030, 5040, 5045, 5050, 5060, 5070, 5080, 5090], \"additionalParameters\": \"\", \"minimumSeeders\": 1, \"requiredFlags\": [], \"multiLanguages\": []}' WHERE Implementation='Prowlarr';" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Radarr Prowlarr indexer updated"
else
    echo "❌ Failed to update Radarr indexer"
fi

echo ""
echo "📋 Manual Configuration Steps:"
echo "============================="
echo ""
echo "1. 🌐 Open Radarr: http://localhost:7878"
echo "2. ⚙️ Go to: Settings → Indexers"
echo "3. 🔍 Find the Prowlarr indexer"
echo "4. ✏️ Edit the Prowlarr indexer"
echo "5. 🔧 Update the URL to: $PROWLARR_URL"
echo "6. 💾 Save the configuration"
echo "7. 🧪 Test the connection"
echo ""
echo "📋 Alternative URLs to try:"
echo "=========================="
echo "• http://127.0.0.1:9696 (localhost)"
echo "• http://172.19.0.4:9696 (static IP)"
echo "• http://prowlarr:9696 (container name - may not work)"
echo ""
echo "⚠️ Important Notes:"
echo "=================="
echo "• HTTP 401 response is normal (authentication required)"
echo "• The URL must be accessible from Radarr's network"
echo "• Test the connection in Radarr after updating"
echo "• Make sure Prowlarr has indexers configured"
echo ""
echo "🔧 Verification:"
echo "==============="
echo "• Prowlarr should show as 'Active' in Radarr"
echo "• Test search should return results"
echo "• RSS sync should work automatically"
echo ""
echo "🚀 Your Prowlarr-Radarr connection should now work!" 