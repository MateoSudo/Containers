#!/bin/bash

# Helper script to get Gitea token and setup webhooks
# This guides you through the token creation process

set -e

# Configuration
GITHUB_USER="MateoSudo"
GITEA_USER="MateoSudo"
REPO_NAME="Containers"
GITHUB_REPO="$GITHUB_USER/$REPO_NAME"
GITEA_BASE_URL="https://gitea.mrintellisense.com"
GITEA_LOCAL_URL="http://localhost:3000"

# GitHub OAuth credentials
GITHUB_CLIENT_ID="Ov23lizUjUk7HUJi1tTi"
GITHUB_CLIENT_SECRET="71486232bfd63c596e669667f525ee797d6147fa"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔐 Gitea Token Setup Guide${NC}"
echo "=================================="
echo ""

# Function to check if Gitea is accessible
check_gitea_access() {
    echo -e "${BLUE}🧪 Checking Gitea accessibility...${NC}"
    
    # Test local access
    if curl -s -o /dev/null -w "%{http_code}" "$GITEA_LOCAL_URL" | grep -q "200"; then
        echo -e "${GREEN}✅ Gitea accessible at $GITEA_LOCAL_URL${NC}"
        GITEA_ACCESS_URL="$GITEA_LOCAL_URL"
    elif curl -s -o /dev/null -w "%{http_code}" "$GITEA_BASE_URL" | grep -q "200"; then
        echo -e "${GREEN}✅ Gitea accessible at $GITEA_BASE_URL${NC}"
        GITEA_ACCESS_URL="$GITEA_BASE_URL"
    else
        echo -e "${RED}❌ Gitea not accessible${NC}"
        echo "Please ensure Gitea is running: docker compose up -d"
        exit 1
    fi
}

# Function to create Gitea token via web interface guidance
create_gitea_token_guide() {
    echo -e "${YELLOW}📝 Creating Gitea Access Token${NC}"
    echo ""
    echo "Follow these steps to create your Gitea token:"
    echo ""
    echo "1. Open your browser and go to:"
    echo -e "   ${BLUE}$GITEA_ACCESS_URL${NC}"
    echo ""
    echo "2. Sign in to Gitea (create account if needed)"
    echo ""
    echo "3. Go to User Settings:"
    echo "   • Click your profile picture (top right)"
    echo "   • Select 'Settings'"
    echo ""
    echo "4. Navigate to Applications:"
    echo "   • In the left sidebar, click 'Applications'"
    echo ""
    echo "5. Generate New Token:"
    echo "   • Scroll to 'Manage Access Tokens'"
    echo "   • Enter token name: 'Webhook Setup'"
    echo "   • Select scopes: ✅ repo, ✅ admin:repo_hook"
    echo "   • Click 'Generate Token'"
    echo ""
    echo "6. Copy the generated token (it will only be shown once!)"
    echo ""
    
    read -p "Press Enter when you have the token ready..."
    echo ""
    
    read -p "Enter your Gitea token: " -s GITEA_TOKEN
    echo ""
    
    if [ -z "$GITEA_TOKEN" ]; then
        echo -e "${RED}❌ No token provided${NC}"
        exit 1
    fi
    
    # Test the token
    echo -e "${BLUE}🧪 Testing Gitea token...${NC}"
    if curl -s -H "Authorization: token $GITEA_TOKEN" \
        "$GITEA_ACCESS_URL/api/v1/user" | jq -e '.login' > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Token is valid!${NC}"
        return 0
    else
        echo -e "${RED}❌ Token is invalid${NC}"
        echo "Please check the token and try again"
        exit 1
    fi
}

# Function to setup GitHub webhook
setup_github_webhook() {
    echo -e "${BLUE}📡 Setting up GitHub webhook...${NC}"
    
    local github_token="${GITHUB_TOKEN:-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}"
    local webhook_secret=$(openssl rand -hex 32)
    local gitea_webhook_url="$GITEA_BASE_URL/webhook"
    
    # Create GitHub webhook
    local payload='{
        "name": "web",
        "active": true,
        "events": ["push", "pull_request"],
        "config": {
            "url": "'$gitea_webhook_url'",
            "content_type": "json",
            "secret": "'$webhook_secret'",
            "insecure_ssl": "0"
        }
    }'
    
    local response=$(curl -s -X POST \
        -H "Authorization: token $github_token" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "https://api.github.com/repos/$GITHUB_REPO/hooks")
    
    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        local webhook_id=$(echo "$response" | jq -r '.id')
        echo -e "${GREEN}✅ GitHub webhook created (ID: $webhook_id)${NC}"
        echo "   URL: $gitea_webhook_url"
        WEBHOOK_SECRET="$webhook_secret"
        return 0
    else
        echo -e "${RED}❌ Failed to create GitHub webhook${NC}"
        echo "Response: $response"
        return 1
    fi
}

# Function to setup Gitea repository (create or ensure exists)
setup_gitea_repository() {
    echo -e "${BLUE}📁 Setting up Gitea repository...${NC}"
    
    # Check if repository exists
    local repo_check=$(curl -s -H "Authorization: token $GITEA_TOKEN" \
        "$GITEA_ACCESS_URL/api/v1/repos/$GITEA_USER/$REPO_NAME")
    
    if echo "$repo_check" | jq -e '.name' > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Repository already exists${NC}"
        return 0
    fi
    
    # Create repository
    local repo_payload='{
        "name": "'$REPO_NAME'",
        "description": "Container configurations and setup",
        "private": false,
        "auto_init": false
    }'
    
    local response=$(curl -s -X POST \
        -H "Authorization: token $GITEA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$repo_payload" \
        "$GITEA_ACCESS_URL/api/v1/user/repos")
    
    if echo "$response" | jq -e '.name' > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Repository created in Gitea${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Repository creation may have failed, but continuing...${NC}"
        return 0
    fi
}

# Function to setup GitHub → Gitea mirroring
setup_mirror_sync() {
    echo -e "${BLUE}🪞 Setting up repository mirroring...${NC}"
    
    # Set up Gitea to mirror from GitHub
    local mirror_payload='{
        "repo_name": "'$REPO_NAME'",
        "clone_addr": "https://github.com/'$GITHUB_REPO'.git",
        "auth_username": "'$GITHUB_USER'",
        "auth_password": "'${GITHUB_TOKEN:-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}'",
        "mirror": true,
        "mirror_interval": "8h",
        "private": false,
        "description": "Mirror of GitHub repository"
    }'
    
    # Try to create mirror repository
    local response=$(curl -s -X POST \
        -H "Authorization: token $GITEA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$mirror_payload" \
        "$GITEA_ACCESS_URL/api/v1/repos/migrate")
    
    if echo "$response" | jq -e '.name' > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Mirror repository created${NC}"
        
        # Trigger initial sync
        curl -s -X POST \
            -H "Authorization: token $GITEA_TOKEN" \
            "$GITEA_ACCESS_URL/api/v1/repos/$GITEA_USER/$REPO_NAME/mirror-sync"
        
        echo -e "${GREEN}✅ Initial sync triggered${NC}"
    else
        echo -e "${YELLOW}⚠️  Mirror setup may have failed (repository might already exist)${NC}"
        echo "Continuing with webhook setup..."
    fi
}

# Function to configure OAuth in Gitea (guidance)
setup_oauth_guide() {
    echo -e "${BLUE}🔗 GitHub OAuth Setup Guide${NC}"
    echo ""
    echo "To enable GitHub OAuth login in Gitea:"
    echo ""
    echo "1. Go to Gitea Admin Panel:"
    echo -e "   ${BLUE}$GITEA_ACCESS_URL/admin${NC}"
    echo ""
    echo "2. Navigate to Authentication Sources:"
    echo "   • Click 'Authentication Sources' in the sidebar"
    echo ""
    echo "3. Add GitHub OAuth:"
    echo "   • Click 'Add Authentication Source'"
    echo "   • Type: OAuth2"
    echo "   • Name: GitHub"
    echo "   • Provider: GitHub"
    echo ""
    echo "4. Configure OAuth settings:"
    echo -e "   • Client ID: ${YELLOW}$GITHUB_CLIENT_ID${NC}"
    echo -e "   • Client Secret: ${YELLOW}$GITHUB_CLIENT_SECRET${NC}"
    echo ""
    echo "5. Save the configuration"
    echo ""
    echo "After setup, users can sign in with GitHub accounts!"
    echo ""
}

# Function to show final summary
show_summary() {
    echo ""
    echo -e "${GREEN}🎉 Setup Complete!${NC}"
    echo "==================="
    echo ""
    echo -e "${BLUE}📋 Configuration Summary:${NC}"
    echo "• GitHub Repository: https://github.com/$GITHUB_REPO"
    echo "• Gitea Repository: $GITEA_ACCESS_URL/$GITEA_USER/$REPO_NAME"
    echo "• GitHub Webhook: $GITEA_BASE_URL/webhook"
    echo "• Webhook Secret: ${WEBHOOK_SECRET:-auto-generated}"
    echo ""
    echo -e "${BLUE}🔗 OAuth Credentials:${NC}"
    echo "• Client ID: $GITHUB_CLIENT_ID"
    echo "• Client Secret: $GITHUB_CLIENT_SECRET"
    echo ""
    echo -e "${BLUE}🧪 Testing:${NC}"
    echo "1. Push to GitHub → Check if it appears in Gitea"
    echo "2. Configure OAuth in Gitea admin panel"
    echo "3. Test GitHub login on Gitea"
    echo ""
    echo -e "${GREEN}✅ Your GitHub ↔ Gitea sync is ready!${NC}"
}

# Main execution
main() {
    echo "Starting Gitea token setup and webhook configuration..."
    echo ""
    
    # Check prerequisites
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}❌ curl is required${NC}"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}❌ jq is required${NC}"
        echo "Install with: sudo apt-get install jq"
        exit 1
    fi
    
    # Check Gitea access
    check_gitea_access
    echo ""
    
    # Guide user through token creation
    create_gitea_token_guide
    echo ""
    
    # Setup repository
    setup_gitea_repository
    echo ""
    
    # Setup mirroring
    setup_mirror_sync
    echo ""
    
    # Setup GitHub webhook
    setup_github_webhook
    echo ""
    
    # Show OAuth setup guide
    setup_oauth_guide
    
    # Show summary
    show_summary
    
    # Save configuration
    cat > webhook-config.txt << EOF
Gitea Webhook Configuration
Generated: $(date)

GitHub Repository: https://github.com/$GITHUB_REPO
Gitea Repository: $GITEA_ACCESS_URL/$GITEA_USER/$REPO_NAME

GitHub OAuth:
- Client ID: $GITHUB_CLIENT_ID
- Client Secret: $GITHUB_CLIENT_SECRET

Webhook Secret: ${WEBHOOK_SECRET:-check-gitea-admin}
GitHub → Gitea URL: $GITEA_BASE_URL/webhook

Gitea Token: $GITEA_TOKEN
EOF
    
    echo -e "${GREEN}📄 Configuration saved to webhook-config.txt${NC}"
}

# Run main function
main "$@" 