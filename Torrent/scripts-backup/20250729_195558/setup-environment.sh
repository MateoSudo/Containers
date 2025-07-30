#!/bin/bash

echo "🔧 Environment Setup for Transmission Media Stack"
echo "==============================================="

# Load existing .env file if it exists
if [ -f ".env" ]; then
    echo "📁 Found existing .env file, loading credentials..."
    set -a  # automatically export all variables
    source .env
    set +a
fi

# Check if credentials are already set
if [ ! -z "$PIA_USER" ] && [ ! -z "$PIA_PASS" ]; then
    echo "✅ PIA VPN credentials already configured!"
    echo "   User: $PIA_USER"
    echo "   Location: ${LOC:-netherlands}"
    echo "   Source: ${ENV_SOURCE:-.env file}"
    echo ""
    
    read -p "Do you want to update these credentials? (y/N): " update_creds
    if [[ ! "$update_creds" =~ ^[Yy]$ ]]; then
        echo "✅ Using existing credentials"
        echo "Ready to deploy! Run: ./deploy-transmission-stack.sh"
        exit 0
    fi
fi

echo ""
echo "Please enter your PIA VPN credentials:"
echo ""

# Get PIA username
read -p "PIA Username: " pia_user
if [ -z "$pia_user" ]; then
    echo "❌ Username cannot be empty"
    exit 1
fi

# Get PIA password
read -s -p "PIA Password: " pia_pass
echo ""
if [ -z "$pia_pass" ]; then
    echo "❌ Password cannot be empty"
    exit 1
fi

# Get VPN location (optional)
echo ""
echo "Available regions: netherlands, swiss, sweden, norway, denmark, etc."
read -p "VPN Location (default: netherlands): " vpn_loc
vpn_loc=${vpn_loc:-netherlands}

# Export to current session
export PIA_USER="$pia_user"
export PIA_PASS="$pia_pass"
export LOC="$vpn_loc"

echo ""
echo "✅ Environment configured!"
echo "   User: $PIA_USER"
echo "   Location: $LOC"
echo ""

# Create a .env file for persistent storage
cat > .env << EOF
PIA_USER="$PIA_USER"
PIA_PASS="$PIA_PASS"
LOC="$LOC"
TZ="America/Chicago"
EOF

# Also create a local environment file for immediate use
cat > .env.local << EOF
export PIA_USER="$PIA_USER"
export PIA_PASS="$PIA_PASS"
export LOC="$LOC"
export TZ="America/Chicago"
EOF

echo "📝 Credentials saved to:"
echo "   • .env (for docker-compose and scripts)"
echo "   • .env.local (for manual sourcing)"
echo "   To reload in future sessions: source .env.local"
echo ""
echo "🚀 Ready to deploy! Run: ./deploy-transmission-stack.sh" 