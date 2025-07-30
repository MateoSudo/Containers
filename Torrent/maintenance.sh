#!/bin/bash

echo "🔧 Media Stack Maintenance & Fixes"
echo "================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root"
    exit 1
fi

# Get the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "📋 Available maintenance options:"
echo "1. Fix TUN device issues"
echo "2. Fix VPN configuration"
echo "3. Fix Prowlarr proxy issues"
echo "4. Fix all *arr service issues"
echo "5. Fix indexer connectivity"
echo "6. Fix health issues"
echo "7. Reset Prowlarr login"
echo "8. Reset Jellyfin database"
echo "9. Run all fixes"
echo "10. Exit"
echo ""

read -p "Select an option (1-10): " choice

case $choice in
    1)
        echo "🔧 Fixing TUN device..."
        if [ -f "$SCRIPT_DIR/fix-tun-device.sh" ]; then
            bash "$SCRIPT_DIR/fix-tun-device.sh"
        else
            echo "Creating /dev/net/tun device..."
            if [ ! -e /dev/net/tun ]; then
                mkdir -p /dev/net
                mknod /dev/net/tun c 10 200
                chmod 600 /dev/net/tun
                echo "✅ TUN device created"
            else
                echo "✅ TUN device already exists"
            fi
        fi
        ;;
    2)
        echo "🔧 Fixing VPN configuration..."
        if [ -f "$SCRIPT_DIR/fix-vpn-configuration.sh" ]; then
            bash "$SCRIPT_DIR/fix-vpn-configuration.sh"
        else
            echo "⚠️  fix-vpn-configuration.sh not found"
        fi
        ;;
    3)
        echo "🔧 Fixing Prowlarr proxy issues..."
        if [ -f "$SCRIPT_DIR/fix-prowlarr-proxy.sh" ]; then
            bash "$SCRIPT_DIR/fix-prowlarr-proxy.sh"
        else
            echo "⚠️  fix-prowlarr-proxy.sh not found"
        fi
        ;;
    4)
        echo "🔧 Fixing all *arr service issues..."
        if [ -f "$SCRIPT_DIR/fix-all-issues.sh" ]; then
            bash "$SCRIPT_DIR/fix-all-issues.sh"
        else
            echo "⚠️  fix-all-issues.sh not found"
        fi
        ;;
    5)
        echo "🔧 Fixing indexer connectivity..."
        if [ -f "$SCRIPT_DIR/fix-indexers.sh" ]; then
            bash "$SCRIPT_DIR/fix-indexers.sh"
        else
            echo "⚠️  fix-indexers.sh not found"
        fi
        ;;
    6)
        echo "🔧 Fixing health issues..."
        if [ -f "$SCRIPT_DIR/fix-health-issues.sh" ]; then
            bash "$SCRIPT_DIR/fix-health-issues.sh"
        else
            echo "⚠️  fix-health-issues.sh not found"
        fi
        ;;
    7)
        echo "🔧 Resetting Prowlarr login..."
        if [ -f "$SCRIPT_DIR/reset-prowlarr-login.sh" ]; then
            bash "$SCRIPT_DIR/reset-prowlarr-login.sh"
        else
            echo "⚠️  reset-prowlarr-login.sh not found"
        fi
        ;;
    8)
        echo "🔧 Resetting Jellyfin database..."
        echo "Stopping Jellyfin..."
        docker stop torrent-jellyfin
        echo "Deleting Jellyfin database..."
        rm -f config/jellyfin/data/data/jellyfin.db
        echo "Starting Jellyfin..."
        docker start torrent-jellyfin
        echo "✅ Jellyfin database reset complete"
        ;;
    9)
        echo "🔧 Running all fixes..."
        
        # Fix TUN device
        echo "1. Fixing TUN device..."
        if [ ! -e /dev/net/tun ]; then
            mkdir -p /dev/net
            mknod /dev/net/tun c 10 200
            chmod 600 /dev/net/tun
            echo "✅ TUN device created"
        else
            echo "✅ TUN device already exists"
        fi
        
        # Fix VPN configuration
        echo "2. Fixing VPN configuration..."
        if [ -f "$SCRIPT_DIR/fix-vpn-configuration.sh" ]; then
            bash "$SCRIPT_DIR/fix-vpn-configuration.sh"
        fi
        
        # Fix Prowlarr proxy
        echo "3. Fixing Prowlarr proxy..."
        if [ -f "$SCRIPT_DIR/fix-prowlarr-proxy.sh" ]; then
            bash "$SCRIPT_DIR/fix-prowlarr-proxy.sh"
        fi
        
        # Fix all issues
        echo "4. Fixing all *arr issues..."
        if [ -f "$SCRIPT_DIR/fix-all-issues.sh" ]; then
            bash "$SCRIPT_DIR/fix-all-issues.sh"
        fi
        
        echo "✅ All fixes completed"
        ;;
    10)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "🎉 Maintenance complete!"
echo "======================="
echo ""
echo "🌐 Service URLs:"
echo "=================="
echo "• Radarr:   http://localhost:7878"
echo "• Sonarr:   http://localhost:8989"
echo "• Prowlarr: http://localhost:9696"
echo "• Jellyfin: http://localhost:8096"
echo "• Lidarr:   http://localhost:8686"
echo "• Jackett:  http://localhost:9117"
echo "• Transmission: http://localhost:9091/transmission/web/" 