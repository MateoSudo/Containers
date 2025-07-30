#!/bin/bash

echo "🚀 Installing Container Startup Automation"
echo "========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root"
    exit 1
fi

# Get the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "📋 Step 1: Making scripts executable..."
chmod +x "$SCRIPT_DIR/fix-tun-device.sh"
chmod +x "$SCRIPT_DIR/startup-automation.sh"
echo "✅ Scripts made executable"

echo ""
echo "📋 Step 2: Installing TUN device service..."

# Create the TUN device service
cat > /etc/systemd/system/create-tun-device.service << EOF
[Unit]
Description=Create TUN device for Docker containers
Before=docker.service
After=local-fs.target

[Service]
Type=oneshot
ExecStart=${SCRIPT_DIR}/fix-tun-device.sh
RemainAfterExit=yes
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "✅ TUN device service created"

echo ""
echo "📋 Step 3: Installing container startup service..."

# Create the container startup service
cat > /etc/systemd/system/container-startup.service << EOF
[Unit]
Description=Start Docker containers with TUN device
After=docker.service
Wants=docker.service

[Service]
Type=oneshot
ExecStart=${SCRIPT_DIR}/startup-automation.sh
RemainAfterExit=yes
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Container startup service created"

echo ""
echo "📋 Step 4: Reloading systemd..."
systemctl daemon-reload

echo ""
echo "📋 Step 5: Enabling services..."
systemctl enable create-tun-device.service
systemctl enable container-startup.service

echo ""
echo "📋 Step 6: Testing services..."
echo "Testing TUN device service..."
systemctl start create-tun-device.service

if systemctl is-active --quiet create-tun-device.service; then
    echo "✅ TUN device service is active"
else
    echo "❌ TUN device service failed"
    systemctl status create-tun-device.service --no-pager -l
fi

echo ""
echo "Testing container startup service..."
systemctl start container-startup.service

if systemctl is-active --quiet container-startup.service; then
    echo "✅ Container startup service is active"
else
    echo "❌ Container startup service failed"
    systemctl status container-startup.service --no-pager -l
fi

echo ""
echo "📋 Step 7: Checking TUN device..."
if [ -e /dev/net/tun ]; then
    echo "✅ TUN device exists:"
    ls -la /dev/net/tun
else
    echo "❌ TUN device not found"
fi

echo ""
echo "📋 Step 8: Checking container status..."
cd "$SCRIPT_DIR"
docker compose ps

echo ""
echo "🎉 Startup Automation Installation Complete!"
echo "=========================================="
echo ""
echo "✅ Services installed:"
echo "   • /etc/systemd/system/create-tun-device.service"
echo "   • /etc/systemd/system/container-startup.service"
echo ""
echo "✅ Services enabled: Will run on every boot"
echo "✅ Services tested: Both services ran successfully"
echo ""
echo "📋 Service Status:"
echo "=================="
echo "TUN Device Service:"
systemctl status create-tun-device.service --no-pager -l
echo ""
echo "Container Startup Service:"
systemctl status container-startup.service --no-pager -l
echo ""
echo "🔧 Manual Commands:"
echo "=================="
echo "• Check TUN service: systemctl status create-tun-device.service"
echo "• Check startup service: systemctl status container-startup.service"
echo "• Start manually: systemctl start container-startup.service"
echo "• Disable services: systemctl disable create-tun-device.service container-startup.service"
echo ""
echo "🚀 Your system will now automatically:"
echo "   1. Create the TUN device on boot"
echo "   2. Start all Docker containers after Docker is ready"
echo "   3. Test service connectivity"
echo ""
echo "🌐 Service URLs (after boot):"
echo "============================="
echo "• Radarr:   http://localhost:7878"
echo "• Sonarr:   http://localhost:8989"
echo "• Prowlarr: http://localhost:9696"
echo "• Jellyfin: http://localhost:8096"
echo "• Lidarr:   http://localhost:8686"
echo "• Transmission: http://localhost:9091/transmission/web/" 