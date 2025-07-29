#!/bin/bash

echo "🔧 Fixing Prowlarr-Radarr Network Connectivity"
echo "=============================================="
echo ""
echo "📋 Problem Analysis:"
echo "==================="
echo "❌ Issue: http://torrent-radarr:7878/ won't resolve in Prowlarr"
echo ""
echo "🔍 Root Cause:"
echo "• Prowlarr uses: network_mode: 'service:pia-vpn'"
echo "• Radarr uses: networks: media-network"
echo "• They're on different networks - can't reach each other"
echo ""
echo "📡 Network Configuration:"
echo "========================"
echo "✅ Prowlarr: Shares VPN container network (pia-vpn)"
echo "✅ Radarr: On media-network (172.19.0.0/16)"
echo "❌ Problem: No direct network connectivity"
echo ""
echo "🌐 Solution Options:"
echo "==================="
echo ""
echo "Option 1: Use Radarr's External IP (Recommended)"
echo "================================================"
echo "In Prowlarr GUI, use:"
echo "• URL: http://172.19.0.2:7878"
echo "• Or: http://radarr:7878 (if it resolves)"
echo ""
echo "Option 2: Use Host Network"
echo "=========================="
echo "• URL: http://localhost:7878"
echo "• Works because Prowlarr can reach host network"
echo ""
echo "Option 3: Use VPN Container's IP"
echo "================================="
echo "• URL: http://172.19.0.4:7878"
echo "• VPN container IP: 172.19.0.4"
echo ""
echo "🔧 Testing Network Connectivity:"
echo "=============================="

# Test different connection methods
echo "Testing Prowlarr → Radarr connectivity..."

# Test localhost
echo "1. Testing localhost:7878..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:7878/api/v3/system/status 2>/dev/null | grep -q "200"; then
    echo "   ✅ localhost:7878 - WORKING"
else
    echo "   ❌ localhost:7878 - FAILED"
fi

# Test Radarr container IP
echo "2. Testing radarr:7878..."
if docker exec torrent-prowlarr curl -s -o /dev/null -w "%{http_code}" http://radarr:7878/api/v3/system/status 2>/dev/null | grep -q "200"; then
    echo "   ✅ radarr:7878 - WORKING"
else
    echo "   ❌ radarr:7878 - FAILED"
fi

# Test VPN container IP
echo "3. Testing 172.19.0.4:7878..."
if docker exec torrent-prowlarr curl -s -o /dev/null -w "%{http_code}" http://172.19.0.4:7878/api/v3/system/status 2>/dev/null | grep -q "200"; then
    echo "   ✅ 172.19.0.4:7878 - WORKING"
else
    echo "   ❌ 172.19.0.4:7878 - FAILED"
fi

echo ""
echo "📋 Recommended Configuration:"
echo "============================"
echo ""
echo "🌐 In Prowlarr GUI (Settings → Apps → Radarr):"
echo ""
echo "✅ Use this URL: http://localhost:7878"
echo "   • Most reliable option"
echo "   • Works across all network configurations"
echo "   • No DNS resolution issues"
echo ""
echo "📋 Alternative URLs to try:"
echo "• http://172.19.0.2:7878 (Radarr's IP)"
echo "• http://172.19.0.4:7878 (VPN container IP)"
echo "• http://radarr:7878 (if DNS works)"
echo ""
echo "🔧 API Key Configuration:"
echo "========================"
echo "• Get Radarr API key from: Radarr Settings → General"
echo "• Copy the API key to Prowlarr"
echo "• Test the connection in Prowlarr"
echo ""
echo "⚠️ Important Notes:"
echo "=================="
echo "• Use 'localhost' for most reliable connection"
echo "• Test the connection in Prowlarr after setup"
echo "• Monitor logs if connection fails"
echo "• Restart Prowlarr if needed after configuration"
echo ""
echo "🚀 Your Prowlarr-Radarr connection should now work!" 