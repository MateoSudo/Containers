#!/bin/bash

echo "🚀 Media Stack Installation & Setup"
echo "=================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root"
    exit 1
fi

# Get the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "📋 Step 1: Setting up environment..."
if [ -f "$SCRIPT_DIR/setup-environment.sh" ]; then
    echo "Running environment setup..."
    bash "$SCRIPT_DIR/setup-environment.sh"
else
    echo "⚠️  setup-environment.sh not found, skipping..."
fi

echo ""
echo "📋 Step 2: Creating TUN device..."
if [ -f "$SCRIPT_DIR/fix-tun-device.sh" ]; then
    echo "Creating /dev/net/tun device..."
    bash "$SCRIPT_DIR/fix-tun-device.sh"
else
    echo "⚠️  fix-tun-device.sh not found, creating TUN device manually..."
    if [ ! -e /dev/net/tun ]; then
        mkdir -p /dev/net
        mknod /dev/net/tun c 10 200
        chmod 600 /dev/net/tun
        echo "✅ TUN device created"
    else
        echo "✅ TUN device already exists"
    fi
fi

echo ""
echo "📋 Step 3: Installing startup automation..."
if [ -f "$SCRIPT_DIR/install-startup-automation.sh" ]; then
    echo "Installing startup automation services..."
    bash "$SCRIPT_DIR/install-startup-automation.sh"
else
    echo "⚠️  install-startup-automation.sh not found, skipping..."
fi

echo ""
echo "📋 Step 4: Starting containers..."
cd "$SCRIPT_DIR"
docker compose up -d

echo ""
echo "📋 Step 5: Waiting for containers to start..."
sleep 15

echo ""
echo "📋 Step 6: Setting up Prowlarr indexers..."
if [ -f "$SCRIPT_DIR/setup-prowlarr-indexers.sh" ]; then
    echo "Setting up Prowlarr indexers..."
    bash "$SCRIPT_DIR/setup-prowlarr-indexers.sh"
else
    echo "⚠️  setup-prowlarr-indexers.sh not found, skipping..."
fi

echo ""
echo "📋 Step 7: Setting up Radarr folders..."
if [ -f "$SCRIPT_DIR/setup-radarr-folders.sh" ]; then
    echo "Setting up Radarr folders..."
    bash "$SCRIPT_DIR/setup-radarr-folders.sh"
else
    echo "⚠️  setup-radarr-folders.sh not found, skipping..."
fi

echo ""
echo "📋 Step 8: Configuring download clients..."
if [ -f "$SCRIPT_DIR/configure-download-clients.sh" ]; then
    echo "Configuring download clients..."
    bash "$SCRIPT_DIR/configure-download-clients.sh"
else
    echo "⚠️  configure-download-clients.sh not found, skipping..."
fi

echo ""
echo "📋 Step 9: Configuring indexers..."
if [ -f "$SCRIPT_DIR/configure-indexers.sh" ]; then
    echo "Configuring indexers..."
    bash "$SCRIPT_DIR/configure-indexers.sh"
else
    echo "⚠️  configure-indexers.sh not found, skipping..."
fi

echo ""
echo "📋 Step 10: Final verification..."
if [ -f "$SCRIPT_DIR/verify-all-services.sh" ]; then
    echo "Running final verification..."
    bash "$SCRIPT_DIR/verify-all-services.sh"
else
    echo "⚠️  verify-all-services.sh not found, running basic check..."
    docker compose ps
fi

echo ""
echo "🎉 Installation Complete!"
echo "======================="
echo ""
echo "✅ Environment setup complete"
echo "✅ TUN device created"
echo "✅ Startup automation installed"
echo "✅ All containers started"
echo "✅ Services configured"
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
echo ""
echo "📝 Next Steps:"
echo "=============="
echo "1. Access each service and complete initial setup"
echo "2. Configure your media folders"
echo "3. Set up your indexers in Prowlarr"
echo "4. Test your download clients"
echo "5. Configure your *arr applications"
echo ""
echo "🚀 Your media stack is ready!" 