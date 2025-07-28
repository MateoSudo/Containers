#!/bin/bash

echo "🔧 Fixing JSON Tags Field in Databases"
echo "======================================"

echo ""
echo "📡 Step 1: Fixing Radarr database..."

# Fix Tags field in Radarr
sqlite3 config/radarr/radarr.db "UPDATE Indexers SET Tags = '[]' WHERE Tags = '' OR Tags IS NULL;"

echo "✅ Radarr Tags field fixed"

echo ""
echo "📡 Step 2: Fixing Sonarr database..."

# Fix Tags field in Sonarr
sqlite3 config/sonarr/sonarr.db "UPDATE Indexers SET Tags = '[]' WHERE Tags = '' OR Tags IS NULL;"

echo "✅ Sonarr Tags field fixed"

echo ""
echo "📡 Step 3: Fixing Lidarr database..."

# Fix Tags field in Lidarr
sqlite3 config/lidarr/lidarr.db "UPDATE Indexers SET Tags = '[]' WHERE Tags = '' OR Tags IS NULL;"

echo "✅ Lidarr Tags field fixed"

echo ""
echo "🎉 JSON Tags Fix Complete!"
echo "========================="
echo ""
echo "✅ All databases updated with proper JSON Tags field"
echo "✅ Empty strings replaced with '[]'"
echo "✅ NULL values replaced with '[]'"
echo ""
echo "🌐 Restart your services to apply the fix:"
echo "   docker compose restart radarr sonarr lidarr"
echo ""
echo "📋 The JSON parsing error should now be resolved!" 