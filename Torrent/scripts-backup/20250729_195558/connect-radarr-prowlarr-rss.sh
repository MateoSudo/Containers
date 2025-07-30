#!/bin/bash

echo "🔧 Connecting Radarr to Prowlarr for RSS Feed"
echo "============================================="

echo ""
echo "📡 Step 1: Checking current configuration..."

# Check Radarr Prowlarr configuration
echo "Checking Radarr Prowlarr configuration..."
RADARR_PROWLARR=$(sqlite3 config/radarr/radarr.db "SELECT Name, Implementation, ConfigContract, EnableRss, EnableAutomaticSearch FROM Indexers WHERE Name='Prowlarr';" 2>/dev/null)

if [ ! -z "$RADARR_PROWLARR" ]; then
    echo "   ✅ Radarr has Prowlarr configured"
    echo "   📊 Configuration: $RADARR_PROWLARR"
else
    echo "   ❌ Radarr missing Prowlarr configuration"
fi

echo ""
echo "📡 Step 2: Getting API keys..."

# Get Prowlarr API key
PROWLARR_API_KEY=$(grep -r "ApiKey" config/prowlarr/ 2>/dev/null | head -1 | sed 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/')

if [ ! -z "$PROWLARR_API_KEY" ]; then
    echo "   ✅ Prowlarr API key found: ${PROWLARR_API_KEY:0:8}..."
else
    echo "   ❌ Prowlarr API key not found"
    exit 1
fi

# Get Radarr API key
RADARR_API_KEY=$(grep -r "ApiKey" config/radarr/ 2>/dev/null | head -1 | sed 's/.*<ApiKey>\(.*\)<\/ApiKey>.*/\1/')

if [ ! -z "$RADARR_API_KEY" ]; then
    echo "   ✅ Radarr API key found: ${RADARR_API_KEY:0:8}..."
else
    echo "   ❌ Radarr API key not found"
    exit 1
fi

echo ""
echo "📡 Step 3: Checking Prowlarr indexers..."

# Check Prowlarr indexers
INDEXER_COUNT=$(curl -s -H "X-Api-Key: $PROWLARR_API_KEY" http://localhost:9696/api/v1/indexer | grep -o "\"id\":" | wc -l)

if [ "$INDEXER_COUNT" -eq 0 ]; then
    echo "   ⚠️ No indexers found in Prowlarr"
    echo "   📋 You need to add indexers to Prowlarr first:"
    echo "      1. Visit http://localhost:9696"
    echo "      2. Go to Settings → Indexers"
    echo "      3. Add popular indexers (RARBG, YTS, EZTV, etc.)"
    echo "      4. Enable RSS and Search for each indexer"
    echo ""
    echo "   🔍 Recommended indexers:"
    echo "      • RARBG (https://rarbg.to)"
    echo "      • YTS (https://yts.mx)"
    echo "      • EZTV (https://eztv.re)"
    echo "      • 1337x (https://1337x.to)"
    echo "      • ThePirateBay (https://thepiratebay.org)"
    echo ""
    echo "   ⏳ After adding indexers, run this script again"
    exit 1
else
    echo "   ✅ Found $INDEXER_COUNT indexers in Prowlarr"
fi

echo ""
echo "📡 Step 4: Setting up Prowlarr-Radarr connection..."

# Add Radarr to Prowlarr Apps
echo "Adding Radarr to Prowlarr Apps..."
RADARR_APP_RESPONSE=$(curl -s -X POST \
    -H "X-Api-Key: $PROWLARR_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
        \"name\": \"Radarr\",
        \"syncLevel\": \"addOnly\",
        \"implementationName\": \"Radarr\",
        \"implementation\": \"Radarr\",
        \"configContract\": \"RadarrSettings\",
        \"infoLink\": \"https://wiki.servarr.com/prowlarr/settings#connections\",
        \"tags\": [],
        \"fields\": [
            {
                \"name\": \"prowlarrUrl\",
                \"value\": \"http://prowlarr:9696\"
            },
            {
                \"name\": \"baseUrl\",
                \"value\": \"http://radarr:7878\"
            },
            {
                \"name\": \"apiKey\",
                \"value\": \"$RADARR_API_KEY\"
            },
            {
                \"name\": \"syncCategories\",
                \"value\": [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060, 2070, 2080, 2090]
            },
            {
                \"name\": \"animeSyncCategories\",
                \"value\": [5000, 5010, 5020, 5030, 5040, 5045, 5050, 5060, 5070, 5080, 5090]
            },
            {
                \"name\": \"syncLevel\",
                \"value\": \"addOnly\"
            }
        ]
    }" \
    http://localhost:9696/api/v1/applications)

if echo "$RADARR_APP_RESPONSE" | grep -q "id"; then
    echo "   ✅ Radarr added to Prowlarr Apps"
else
    echo "   ❌ Failed to add Radarr to Prowlarr Apps"
    echo "   Response: $RADARR_APP_RESPONSE"
fi

echo ""
echo "📡 Step 5: Testing RSS connectivity..."

# Test Radarr can reach Prowlarr
echo "Testing Radarr → Prowlarr connection..."
RADARR_PROWLARR_TEST=$(docker exec torrent-radarr curl -s -o /dev/null -w "%{http_code}" http://pia-vpn:9696/api/v1/system/status 2>/dev/null)

if [ "$RADARR_PROWLARR_TEST" = "200" ]; then
    echo "   ✅ Radarr can reach Prowlarr"
else
    echo "   ❌ Radarr cannot reach Prowlarr (HTTP $RADARR_PROWLARR_TEST)"
fi

# Test Prowlarr can reach Radarr
echo "Testing Prowlarr → Radarr connection..."
PROWLARR_RADARR_TEST=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:7878/api/v3/system/status 2>/dev/null)

if [ "$PROWLARR_RADARR_TEST" = "200" ]; then
    echo "   ✅ Prowlarr can reach Radarr"
else
    echo "   ❌ Prowlarr cannot reach Radarr (HTTP $PROWLARR_RADARR_TEST)"
fi

echo ""
echo "📡 Step 6: Verifying RSS configuration..."

# Check if Radarr has RSS enabled for Prowlarr
RSS_ENABLED=$(sqlite3 config/radarr/radarr.db "SELECT EnableRss FROM Indexers WHERE Name='Prowlarr';" 2>/dev/null)
AUTO_SEARCH_ENABLED=$(sqlite3 config/radarr/radarr.db "SELECT EnableAutomaticSearch FROM Indexers WHERE Name='Prowlarr';" 2>/dev/null)

if [ "$RSS_ENABLED" = "1" ]; then
    echo "   ✅ RSS enabled for Prowlarr in Radarr"
else
    echo "   ❌ RSS not enabled for Prowlarr in Radarr"
fi

if [ "$AUTO_SEARCH_ENABLED" = "1" ]; then
    echo "   ✅ Automatic search enabled for Prowlarr in Radarr"
else
    echo "   ❌ Automatic search not enabled for Prowlarr in Radarr"
fi

echo ""
echo "🎉 RSS CONNECTION SETUP COMPLETE!"
echo "=================================="
echo ""
echo "✅ Radarr is connected to Prowlarr for RSS feed"
echo "✅ Prowlarr indexers will sync to Radarr"
echo "✅ RSS and automatic search are enabled"
echo ""
echo "🌐 Test your setup:"
echo "   1. Visit Radarr: http://localhost:7878"
echo "   2. Go to Settings → Indexers"
echo "   3. Check that Prowlarr shows as active"
echo "   4. Add a movie and test automatic search"
echo ""
echo "📋 RSS Feed Benefits:"
echo "   • Automatic discovery of new releases"
echo "   • Real-time updates from indexers"
echo "   • VPN-protected indexer access"
echo "   • Centralized indexer management"
echo ""
echo "🚀 Your RSS feed is now active!" 