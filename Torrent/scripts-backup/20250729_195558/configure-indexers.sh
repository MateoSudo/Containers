#!/bin/bash

echo "🔍 Configuring Popular Indexers in Prowlarr..."

# Wait for Prowlarr to be ready
echo "⏳ Waiting for Prowlarr to start..."
until curl -s http://localhost:9696/api/v1/system/status >/dev/null 2>&1; do
    echo "Waiting for Prowlarr..."
    sleep 10
done

echo "✅ Prowlarr is ready!"

# Function to add indexer to Prowlarr
add_indexer() {
    local name="$1"
    local protocol="$2"
    local url="$3"
    local categories="$4"
    
    echo "📡 Adding $name indexer..."
    
    # Create indexer configuration
    cat > /tmp/indexer_$name.json << EOF
{
    "name": "$name",
    "protocol": "$protocol",
    "supportsRss": true,
    "supportsSearch": true,
    "supportedCategories": $categories,
    "baseUrl": "$url",
    "apiPath": "/api",
    "apiKey": "",
    "minimumSeeders": 1,
    "requiredFlags": [],
    "configContract": "NewznabSettings",
    "implementation": "Newznab",
    "implementationName": "Newznab",
    "infoLink": "$url",
    "tags": []
}
EOF

            # Add indexer via Prowlarr API (now through VPN)
        curl -s -X POST \
            -H "Content-Type: application/json" \
            -d @/tmp/indexer_$name.json \
            http://localhost:9696/api/v1/indexer
    
    rm -f /tmp/indexer_$name.json
    echo "✅ Added $name"
}

# Add popular indexers
echo "🚀 Adding popular indexers..."

# NZBGeek (requires API key - user will need to add manually)
echo "ℹ️  NZBGeek requires manual API key setup"
echo "   Visit: https://nzbgeek.info/"

# 1337x (public tracker)
add_indexer "1337x" "torrent" "https://1337x.to" '["movies", "tv", "music"]'

# RARBG (public tracker) 
add_indexer "RARBG" "torrent" "https://rarbg.to" '["movies", "tv", "music"]'

# The Pirate Bay (public tracker)
add_indexer "ThePirateBay" "torrent" "https://thepiratebay.org" '["movies", "tv", "music"]'

# YTS (movies)
add_indexer "YTS" "torrent" "https://yts.mx" '["movies"]'

# EZTV (TV shows)
add_indexer "EZTV" "torrent" "https://eztv.re" '["tv"]'

echo ""
echo "🎉 Indexer Configuration Complete!"
echo ""
echo "📋 Manual Setup Required:"
echo "   1. Visit http://localhost:9696 (Prowlarr)"
echo "   2. Add your preferred private trackers"
echo "   3. Configure API keys for private indexers"
echo "   4. Test indexers in Prowlarr"
echo ""
echo "🔗 Alternative Indexer:"
echo "   Jackett: http://localhost:9117"
echo ""
echo "✅ Public indexers added automatically!" 