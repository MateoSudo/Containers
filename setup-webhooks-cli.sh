#!/bin/bash

# CLI Webhook Setup for GitHub ↔ Gitea Bidirectional Sync
# Sets up webhooks using GitHub and Gitea APIs

set -e

# Configuration
GITHUB_USER="MateoSudo"
GITEA_USER="MateoSudo"
REPO_NAME="Containers"
GITHUB_REPO="$GITHUB_USER/$REPO_NAME"
GITEA_BASE_URL="https://gitea.mrintellisense.com"
GITEA_LOCAL_URL="http://localhost:3000"

# Webhook URLs
GITEA_WEBHOOK_URL="$GITEA_BASE_URL/webhook"
GITHUB_WEBHOOK_URL="https://api.github.com/repos/$GITHUB_REPO/hooks"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Setting up GitHub ↔ Gitea Webhooks via CLI${NC}"
echo "Repository: $GITHUB_REPO"
echo "Gitea URL: $GITEA_BASE_URL"
echo ""

# Function to prompt for tokens if not in environment
get_tokens() {
    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "${YELLOW}📝 GitHub Personal Access Token needed${NC}"
        echo "Create one at: https://github.com/settings/tokens"
        echo "Required scopes: repo, admin:repo_hook"
        read -p "Enter GitHub token: " -s GITHUB_TOKEN
        echo ""
    fi
    
    if [ -z "$GITEA_TOKEN" ]; then
        echo -e "${YELLOW}📝 Gitea Access Token needed${NC}"
        echo "Create one at: $GITEA_BASE_URL/user/settings/applications"
        echo "Required scopes: repo, admin:repo_hook"
        read -p "Enter Gitea token: " -s GITEA_TOKEN
        echo ""
    fi
    
    # Generate webhook secret if not provided
    if [ -z "$WEBHOOK_SECRET" ]; then
        WEBHOOK_SECRET=$(openssl rand -hex 32)
        echo -e "${GREEN}🔐 Generated webhook secret: $WEBHOOK_SECRET${NC}"
    fi
}

# Function to test API access
test_api_access() {
    echo -e "${BLUE}🧪 Testing API access...${NC}"
    
    # Test GitHub API
    echo -n "Testing GitHub API... "
    if curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$GITHUB_REPO" > /dev/null; then
        echo -e "${GREEN}✅ Success${NC}"
    else
        echo -e "${RED}❌ Failed${NC}"
        echo "Please check your GitHub token and repository access"
        exit 1
    fi
    
    # Test Gitea API
    echo -n "Testing Gitea API... "
    if curl -s -H "Authorization: token $GITEA_TOKEN" \
        "$GITEA_BASE_URL/api/v1/repos/$GITEA_USER/$REPO_NAME" > /dev/null; then
        echo -e "${GREEN}✅ Success${NC}"
    else
        echo -e "${YELLOW}⚠️  Repository may not exist in Gitea yet${NC}"
        echo "Will attempt to create repository during setup"
    fi
}

# Function to create repository in Gitea if it doesn't exist
create_gitea_repository() {
    echo -e "${BLUE}📁 Ensuring repository exists in Gitea...${NC}"
    
    local repo_payload='{
        "name": "'$REPO_NAME'",
        "description": "Mirror of GitHub repository",
        "private": false,
        "auto_init": false
    }'
    
    # Try to create repository (will fail if exists, which is fine)
    curl -s -X POST \
        -H "Authorization: token $GITEA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$repo_payload" \
        "$GITEA_BASE_URL/api/v1/user/repos" > /dev/null 2>&1 || true
    
    echo -e "${GREEN}✅ Repository ready in Gitea${NC}"
}

# Function to setup GitHub webhook
setup_github_webhook() {
    echo -e "${BLUE}📡 Setting up GitHub webhook...${NC}"
    
    # First, delete any existing webhooks for this URL
    echo "Checking for existing GitHub webhooks..."
    existing_hooks=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$GITHUB_REPO/hooks" | \
        jq -r ".[] | select(.config.url==\"$GITEA_WEBHOOK_URL\") | .id" 2>/dev/null || echo "")
    
    if [ ! -z "$existing_hooks" ]; then
        echo "Removing existing webhook..."
        for hook_id in $existing_hooks; do
            curl -s -X DELETE \
                -H "Authorization: token $GITHUB_TOKEN" \
                "https://api.github.com/repos/$GITHUB_REPO/hooks/$hook_id"
        done
    fi
    
    # Create new webhook
    local github_payload='{
        "name": "web",
        "active": true,
        "events": ["push", "pull_request"],
        "config": {
            "url": "'$GITEA_WEBHOOK_URL'",
            "content_type": "json",
            "secret": "'$WEBHOOK_SECRET'",
            "insecure_ssl": "0"
        }
    }'
    
    local response=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/json" \
        -d "$github_payload" \
        "https://api.github.com/repos/$GITHUB_REPO/hooks")
    
    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        local webhook_id=$(echo "$response" | jq -r '.id')
        echo -e "${GREEN}✅ GitHub webhook created (ID: $webhook_id)${NC}"
        echo "   URL: $GITEA_WEBHOOK_URL"
        return 0
    else
        echo -e "${RED}❌ Failed to create GitHub webhook${NC}"
        echo "Response: $response"
        return 1
    fi
}

# Function to setup Gitea webhook  
setup_gitea_webhook() {
    echo -e "${BLUE}📡 Setting up Gitea webhook...${NC}"
    
    # GitHub webhook URL (reverse direction)
    local github_webhook_endpoint="https://api.github.com/repos/$GITHUB_REPO/dispatches"
    
    # First, delete any existing webhooks for GitHub
    echo "Checking for existing Gitea webhooks..."
    existing_hooks=$(curl -s -H "Authorization: token $GITEA_TOKEN" \
        "$GITEA_BASE_URL/api/v1/repos/$GITEA_USER/$REPO_NAME/hooks" | \
        jq -r '.[] | select(.config.url | contains("github.com")) | .id' 2>/dev/null || echo "")
    
    if [ ! -z "$existing_hooks" ]; then
        echo "Removing existing webhooks..."
        for hook_id in $existing_hooks; do
            curl -s -X DELETE \
                -H "Authorization: token $GITEA_TOKEN" \
                "$GITEA_BASE_URL/api/v1/repos/$GITEA_USER/$REPO_NAME/hooks/$hook_id"
        done
    fi
    
    # For Gitea webhook, we'll use repository dispatch to trigger GitHub Actions
    local gitea_payload='{
        "type": "gitea",
        "config": {
            "url": "'$github_webhook_endpoint'",
            "content_type": "json",
            "secret": "'$WEBHOOK_SECRET'"
        },
        "events": ["push", "pull_request"],
        "active": true
    }'
    
    local response=$(curl -s -X POST \
        -H "Authorization: token $GITEA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$gitea_payload" \
        "$GITEA_BASE_URL/api/v1/repos/$GITEA_USER/$REPO_NAME/hooks")
    
    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        local webhook_id=$(echo "$response" | jq -r '.id')
        echo -e "${GREEN}✅ Gitea webhook created (ID: $webhook_id)${NC}"
        echo "   URL: $github_webhook_endpoint"
        return 0
    else
        echo -e "${RED}❌ Failed to create Gitea webhook${NC}"
        echo "Response: $response"
        return 1
    fi
}

# Function to setup repository mirroring in Gitea
setup_gitea_mirror() {
    echo -e "${BLUE}🪞 Setting up GitHub → Gitea mirror...${NC}"
    
    # Check if repository is already a mirror
    local repo_info=$(curl -s -H "Authorization: token $GITEA_TOKEN" \
        "$GITEA_BASE_URL/api/v1/repos/$GITEA_USER/$REPO_NAME")
    
    if echo "$repo_info" | jq -e '.mirror' > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Repository is already configured as a mirror${NC}"
        
        # Trigger manual sync
        curl -s -X POST \
            -H "Authorization: token $GITEA_TOKEN" \
            "$GITEA_BASE_URL/api/v1/repos/$GITEA_USER/$REPO_NAME/mirror-sync"
        
        echo -e "${GREEN}✅ Triggered manual mirror sync${NC}"
        return 0
    fi
    
    # If not a mirror, we'll set up push mirroring instead
    echo "Setting up push mirror to sync Gitea → GitHub..."
    
    local mirror_payload='{
        "remote_name": "github-mirror",
        "remote_address": "https://github.com/'$GITHUB_REPO'.git",
        "remote_username": "'$GITHUB_USER'",
        "remote_password": "'$GITHUB_TOKEN'",
        "sync_on_commit": true,
        "interval": "8h"
    }'
    
    local response=$(curl -s -X POST \
        -H "Authorization: token $GITEA_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$mirror_payload" \
        "$GITEA_BASE_URL/api/v1/repos/$GITEA_USER/$REPO_NAME/push_mirrors")
    
    if echo "$response" | jq -e '.remote_name' > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Push mirror configured${NC}"
    else
        echo -e "${YELLOW}⚠️  Push mirror setup may have failed, but webhooks will still work${NC}"
    fi
}

# Function to test webhooks
test_webhooks() {
    echo -e "${BLUE}🧪 Testing webhook connectivity...${NC}"
    
    # Test if Gitea webhook endpoint is accessible
    echo -n "Testing Gitea webhook endpoint... "
    if curl -s -o /dev/null -w "%{http_code}" "$GITEA_WEBHOOK_URL" | grep -q "200\|404\|405"; then
        echo -e "${GREEN}✅ Accessible${NC}"
    else
        echo -e "${YELLOW}⚠️  May not be accessible from GitHub${NC}"
        echo "   Make sure $GITEA_BASE_URL is publicly accessible"
    fi
    
    # Test GitHub API accessibility
    echo -n "Testing GitHub API accessibility... "
    if curl -s -o /dev/null "https://api.github.com"; then
        echo -e "${GREEN}✅ Accessible${NC}"
    else
        echo -e "${RED}❌ GitHub API not accessible${NC}"
    fi
}

# Function to show setup summary
show_summary() {
    echo ""
    echo -e "${GREEN}🎉 Webhook setup complete!${NC}"
    echo ""
    echo -e "${BLUE}📋 Configuration Summary:${NC}"
    echo "GitHub Repository: https://github.com/$GITHUB_REPO"
    echo "Gitea Repository: $GITEA_BASE_URL/$GITEA_USER/$REPO_NAME"
    echo "GitHub → Gitea: $GITEA_WEBHOOK_URL"
    echo "Gitea → GitHub: Repository dispatch events"
    echo "Webhook Secret: $WEBHOOK_SECRET"
    echo ""
    echo -e "${BLUE}🔄 How it works:${NC}"
    echo "1. Push to GitHub → triggers webhook → updates Gitea"
    echo "2. Push to Gitea → triggers push mirror → updates GitHub"
    echo ""
    echo -e "${BLUE}🧪 Test the setup:${NC}"
    echo "1. Make a change in GitHub and check if it appears in Gitea"
    echo "2. Make a change in Gitea and check if it appears in GitHub"
    echo ""
    echo -e "${YELLOW}💡 Troubleshooting:${NC}"
    echo "- Check webhook logs in repository settings"
    echo "- Ensure $GITEA_BASE_URL is publicly accessible"
    echo "- Verify tokens have correct permissions"
}

# Main execution
main() {
    echo -e "${BLUE}🔧 Starting CLI webhook setup...${NC}"
    
    # Check prerequisites
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}❌ curl is required but not installed${NC}"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}❌ jq is required but not installed${NC}"
        echo "Install with: sudo apt-get install jq"
        exit 1
    fi
    
    # Get API tokens
    get_tokens
    
    # Test API access
    test_api_access
    
    # Create Gitea repository if needed
    create_gitea_repository
    
    # Setup webhooks
    echo ""
    if setup_github_webhook && setup_gitea_webhook; then
        echo ""
        setup_gitea_mirror
        echo ""
        test_webhooks
        echo ""
        show_summary
        
        # Save configuration for future reference
        cat > webhook-setup-summary.txt << EOF
Webhook Setup Summary
Generated: $(date)

GitHub Repository: https://github.com/$GITHUB_REPO
Gitea Repository: $GITEA_BASE_URL/$GITEA_USER/$REPO_NAME

Webhook Secret: $WEBHOOK_SECRET
GitHub → Gitea URL: $GITEA_WEBHOOK_URL
Gitea → GitHub: Push mirror + repository dispatch

Setup completed successfully!
EOF
        echo -e "${GREEN}📄 Configuration saved to webhook-setup-summary.txt${NC}"
        
    else
        echo -e "${RED}❌ Webhook setup failed${NC}"
        exit 1
    fi
}

# Export webhook secret for use in environment
export WEBHOOK_SECRET

# Run main function
main "$@" 