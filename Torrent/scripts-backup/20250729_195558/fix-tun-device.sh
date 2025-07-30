#!/bin/bash

# Fix for missing /dev/net/tun device
# This script creates the tun device if it doesn't exist

echo "Checking for /dev/net/tun device..."

# Check if /dev/net/tun exists
if [ ! -e /dev/net/tun ]; then
    echo "Creating /dev/net/tun device..."
    
    # Create /dev/net directory if it doesn't exist
    mkdir -p /dev/net
    
    # Create the tun device
    mknod /dev/net/tun c 10 200
    
    # Set proper permissions
    chmod 600 /dev/net/tun
    
    echo "✓ /dev/net/tun device created successfully"
else
    echo "✓ /dev/net/tun device already exists"
fi

# Verify the device
if [ -e /dev/net/tun ]; then
    echo "✓ Device verification successful"
    ls -la /dev/net/tun
else
    echo "✗ Failed to create /dev/net/tun device"
    exit 1
fi

echo "TUN device fix completed successfully!" 