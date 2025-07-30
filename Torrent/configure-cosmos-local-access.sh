#!/bin/bash

echo "🔧 Configuring Cosmos for Local Network Access"
echo "============================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if we're running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root"
   exit 1
fi

COSMOS_CONFIG="/var/lib/cosmos/cosmos.config.json"
BACKUP_FILE="/var/lib/cosmos/cosmos.config.json.backup.$(date +%Y%m%d_%H%M%S)"

echo "📋 Step 1: Creating backup of current Cosmos configuration..."
cp "$COSMOS_CONFIG" "$BACKUP_FILE"
echo "✅ Backup created: $BACKUP_FILE"

echo "📋 Step 2: Checking current Cosmos configuration..."
if [ ! -f "$COSMOS_CONFIG" ]; then
    echo "❌ Cosmos configuration file not found"
    exit 1
fi

echo "📋 Step 3: Adding local subnet to Cosmos whitelist..."

# Create a temporary file with the updated configuration
TEMP_CONFIG=$(mktemp)

# Use jq to update the configuration
if command -v jq &> /dev/null; then
    echo "✅ Using jq to update configuration..."
    jq '.AdminWhitelistIPs = ["192.168.1.0/24"]' "$COSMOS_CONFIG" > "$TEMP_CONFIG"
    
    if [ $? -eq 0 ]; then
        mv "$TEMP_CONFIG" "$COSMOS_CONFIG"
        echo "✅ Configuration updated successfully"
    else
        echo "❌ Failed to update configuration with jq"
        rm -f "$TEMP_CONFIG"
        exit 1
    fi
else
    echo "⚠️  jq not available, using sed method..."
    
    # Create a backup of the current config
    cp "$COSMOS_CONFIG" "$COSMOS_CONFIG.temp"
    
    # Use sed to add the whitelist (this is a fallback method)
    sed -i 's/"AdminWhitelistIPs": null/"AdminWhitelistIPs": ["192.168.1.0\/24"]/' "$COSMOS_CONFIG"
    
    # Verify the change was made
    if grep -q "192.168.1.0/24" "$COSMOS_CONFIG"; then
        echo "✅ Configuration updated successfully"
    else
        echo "❌ Failed to update configuration"
        mv "$COSMOS_CONFIG.temp" "$COSMOS_CONFIG"
        exit 1
    fi
fi

echo "📋 Step 4: Restarting Cosmos service..."
systemctl restart cosmos

echo "📋 Step 5: Waiting for Cosmos to restart..."
sleep 5

echo "📋 Step 6: Checking Cosmos service status..."
if systemctl is-active --quiet cosmos; then
    echo "✅ Cosmos is running"
else
    echo "❌ Cosmos failed to start"
    echo "📋 Checking logs..."
    journalctl -u cosmos --no-pager -n 10
    exit 1
fi

echo ""
echo "🎉 Cosmos Local Network Access Configuration Complete!"
echo "===================================================="
echo ""
echo "📋 What was configured:"
echo "======================="
echo "✅ Added 192.168.1.0/24 to AdminWhitelistIPs"
echo "✅ Restarted Cosmos service"
echo "✅ Local network access enabled"
echo ""
echo "📋 Access Information:"
echo "======================"
echo "• Local network devices (192.168.1.x) can access services without authentication"
echo "• External devices still require authentication"
echo "• TVs and devices on your local network will work without login"
echo ""
echo "📋 Test URLs for Local Network:"
echo "==============================="
echo "• Jellyfin: https://jellyfin.mrintellisense.com (no login from 192.168.1.x)"
echo "• Sonarr: https://sonarr.mrintellisense.com (no login from 192.168.1.x)"
echo "• Radarr: https://radarr.mrintellisense.com (no login from 192.168.1.x)"
echo "• Prowlarr: https://prowlarr.mrintellisense.com (no login from 192.168.1.x)"
echo "• Lidarr: https://lidarr.mrintellisense.com (no login from 192.168.1.x)"
echo "• Jackett: https://jackett.mrintellisense.com (no login from 192.168.1.x)"
echo ""
echo "🌐 For TVs and Devices:"
echo "======================"
echo "• Smart TVs on 192.168.1.x network: No authentication required"
echo "• Mobile devices on 192.168.1.x network: No authentication required"
echo "• External devices: Still require authentication"
echo "• Direct access still works: http://your-server-ip:8096"
echo ""
echo "✅ Configuration complete! Your local network devices can now access services without login." 