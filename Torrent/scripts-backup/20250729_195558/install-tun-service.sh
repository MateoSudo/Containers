#!/bin/bash

echo "🔧 Installing TUN Device Service"
echo "================================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root"
    exit 1
fi

# Get the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "📋 Step 1: Creating systemd service file..."

# Create the service file
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

echo "✅ Service file created at /etc/systemd/system/create-tun-device.service"

echo ""
echo "📋 Step 2: Reloading systemd..."
systemctl daemon-reload

echo ""
echo "📋 Step 3: Enabling service..."
systemctl enable create-tun-device.service

echo ""
echo "📋 Step 4: Testing service..."
systemctl start create-tun-device.service

# Check if service ran successfully
if systemctl is-active --quiet create-tun-device.service; then
    echo "✅ Service is active"
else
    echo "❌ Service failed to start"
    systemctl status create-tun-device.service
    exit 1
fi

echo ""
echo "📋 Step 5: Checking TUN device..."
if [ -e /dev/net/tun ]; then
    echo "✅ TUN device exists:"
    ls -la /dev/net/tun
else
    echo "❌ TUN device not found"
    exit 1
fi

echo ""
echo "🎉 TUN Device Service Installation Complete!"
echo "=========================================="
echo ""
echo "✅ Service installed: /etc/systemd/system/create-tun-device.service"
echo "✅ Service enabled: Will run on every boot"
echo "✅ Service tested: TUN device created successfully"
echo ""
echo "📋 Service Status:"
echo "=================="
systemctl status create-tun-device.service --no-pager -l
echo ""
echo "🔧 Manual Commands:"
echo "=================="
echo "• Check service status: systemctl status create-tun-device.service"
echo "• Start service manually: systemctl start create-tun-device.service"
echo "• Stop service: systemctl stop create-tun-device.service"
echo "• Disable service: systemctl disable create-tun-device.service"
echo ""
echo "🚀 Your system will now automatically create the TUN device on every boot!"
echo "   This ensures your Docker containers start properly after reboots." 