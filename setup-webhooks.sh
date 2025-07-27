#!/bin/bash

# Webhook Setup Script for GitHub ↔ Gitea Bidirectional Sync
# This script configures webhooks in both GitHub and Gitea

set -e

# Load configuration
if [ -f "webhook-config.env" ]; then
    source webhook-config.env
else
    echo "❌ webhook-config.env not found! Please copy from webhook-config.env.template and configure."
    exit 1
fi

echo "🔄 Setting up bidirectional webhooks for GitHub ↔ Gitea sync..."

# Function to generate a secure webhook secret if not provided
generate_webhook_secret() {
    if [ -z "$WEBHOOK_SECRET" ] || [ "$WEBHOOK_SECRET" = "your_webhook_secret_here" ]; then
        echo "🔐 Generating secure webhook secret..."
        WEBHOOK_SECRET=$(openssl rand -hex 32)
        # Update the env file
        sed -i "s/WEBHOOK_SECRET=.*/WEBHOOK_SECRET=$WEBHOOK_SECRET/" webhook-config.env
        echo "✅ Generated webhook secret: $WEBHOOK_SECRET"
    fi
}

# Function to setup GitHub webhook
setup_github_webhook() {
    echo "📡 Setting up GitHub webhook..."
    
    local webhook_url="https://github-webhook.mrintellisense.com/webhook/github"
    local payload='{
        "name": "web",
        "active": true,
        "events": ["push", "pull_request"],
        "config": {
            "url": "'$webhook_url'",
            "content_type": "json",
            "secret": "'$WEBHOOK_SECRET'",
            "insecure_ssl": "0"
        }
    }'
    
    curl -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "$payload" \
        "https://api.github.com/repos/$GITHUB_REPO_OWNER/$GITHUB_REPO_NAME/hooks"
    
    echo "✅ GitHub webhook configured"
}

# Function to setup Gitea webhook
setup_gitea_webhook() {
    echo "📡 Setting up Gitea webhook..."
    
    local webhook_url="https://gitea-webhook.mrintellisense.com/webhook/gitea"
    local payload='{
        "type": "gitea",
        "config": {
            "url": "'$webhook_url'",
            "content_type": "json",
            "secret": "'$WEBHOOK_SECRET'"
        },
        "events": ["push", "pull_request"],
        "active": true
    }'
    
    curl -X POST \
        -H "Authorization: token $GITEA_ADMIN_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$payload" \
        "$GITEA_BASE_URL/api/v1/repos/$GITEA_REPO_OWNER/$GITEA_REPO_NAME/hooks"
    
    echo "✅ Gitea webhook configured"
}

# Function to setup repository mirroring
setup_repository_mirror() {
    echo "🪞 Setting up repository mirroring in Gitea..."
    
    # Create pull mirror (GitHub → Gitea)
    local mirror_payload='{
        "repo_name": "'$GITEA_REPO_NAME'",
        "clone_addr": "https://github.com/'$GITHUB_REPO_OWNER'/$GITHUB_REPO_NAME.git",
        "auth_username": "'$GITHUB_REPO_OWNER'",
        "auth_password": "'$GITHUB_TOKEN'",
        "mirror": true,
        "mirror_interval": "8h",
        "private": false
    }'
    
    curl -X POST \
        -H "Authorization: token $GITEA_ADMIN_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$mirror_payload" \
        "$GITEA_BASE_URL/api/v1/repos/migrate"
    
    echo "✅ Repository mirror configured"
}

# Function to start webhook services
start_webhook_services() {
    echo "🚀 Starting webhook services..."
    
    # Create webhook logs directory
    sudo mkdir -p /var/log/webhooks
    sudo chmod 755 /var/log/webhooks
    
    # Start webhook services
    docker-compose -f docker-compose.webhooks.yml up -d --build
    
    echo "✅ Webhook services started"
    echo "   GitHub → Gitea webhook: http://localhost:5000"
    echo "   Gitea → GitHub webhook: http://localhost:5001"
}

# Function to test webhook connectivity
test_webhooks() {
    echo "🧪 Testing webhook connectivity..."
    
    # Test GitHub webhook handler
    echo "Testing GitHub webhook handler..."
    curl -f http://localhost:5000/health && echo " ✅ GitHub webhook handler healthy" || echo " ❌ GitHub webhook handler failed"
    
    # Test Gitea webhook handler
    echo "Testing Gitea webhook handler..."
    curl -f http://localhost:5001/health && echo " ✅ Gitea webhook handler healthy" || echo " ❌ Gitea webhook handler failed"
}

# Main execution
main() {
    echo "🔧 Starting webhook setup..."
    
    # Check prerequisites
    if ! command -v curl &> /dev/null; then
        echo "❌ curl is required but not installed"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo "❌ docker-compose is required but not installed"
        exit 1
    fi
    
    # Generate webhook secret if needed
    generate_webhook_secret
    
    # Start webhook services first
    start_webhook_services
    
    # Wait for services to be ready
    sleep 10
    
    # Test webhook services
    test_webhooks
    
    # Setup webhooks (uncomment when ready)
    echo "⚠️  Manual webhook setup required:"
    echo "   1. GitHub: Repository Settings → Webhooks → Add webhook"
    echo "      URL: https://github-webhook.mrintellisense.com/webhook/github"
    echo "      Secret: $WEBHOOK_SECRET"
    echo "   2. Gitea: Repository Settings → Webhooks → Add webhook"
    echo "      URL: https://gitea-webhook.mrintellisense.com/webhook/gitea"
    echo "      Secret: $WEBHOOK_SECRET"
    
    # Uncomment these lines when you're ready to auto-configure
    # setup_github_webhook
    # setup_gitea_webhook
    # setup_repository_mirror
    
    echo ""
    echo "🎉 Webhook setup complete!"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Configure DNS for webhook domains"
    echo "   2. Set up SSL certificates"
    echo "   3. Configure webhooks manually (URLs shown above)"
    echo "   4. Test sync by pushing to either repository"
}

# Run main function
main "$@" 