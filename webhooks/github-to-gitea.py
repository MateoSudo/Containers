#!/usr/bin/env python3
"""
GitHub to Gitea Webhook Handler
Receives webhooks from GitHub and syncs changes to Gitea
"""

import os
import json
import hmac
import hashlib
import requests
import subprocess
from flask import Flask, request, jsonify
from dotenv import load_dotenv

# Load environment variables
load_dotenv('../webhook-config.env')

app = Flask(__name__)

# Configuration
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
GITEA_BASE_URL = os.getenv('GITEA_BASE_URL')
GITEA_ADMIN_TOKEN = os.getenv('GITEA_ADMIN_TOKEN')
WEBHOOK_SECRET = os.getenv('WEBHOOK_SECRET')
GITEA_REPO_OWNER = os.getenv('GITEA_REPO_OWNER')
GITEA_REPO_NAME = os.getenv('GITEA_REPO_NAME')

def verify_github_signature(payload, signature):
    """Verify GitHub webhook signature"""
    if not WEBHOOK_SECRET:
        return True  # Skip verification if no secret set
    
    expected = hmac.new(
        WEBHOOK_SECRET.encode(),
        payload,
        hashlib.sha256
    ).hexdigest()
    
    return hmac.compare_digest(f"sha256={expected}", signature)

def sync_repository():
    """Trigger repository sync in Gitea"""
    try:
        # Use Gitea API to trigger mirror sync
        url = f"{GITEA_BASE_URL}/api/v1/repos/{GITEA_REPO_OWNER}/{GITEA_REPO_NAME}/mirror-sync"
        headers = {
            'Authorization': f'token {GITEA_ADMIN_TOKEN}',
            'Content-Type': 'application/json'
        }
        
        response = requests.post(url, headers=headers)
        return response.status_code == 200
    except Exception as e:
        print(f"Sync error: {e}")
        return False

@app.route('/webhook/github', methods=['POST'])
def github_webhook():
    """Handle GitHub webhook"""
    try:
        # Verify signature
        signature = request.headers.get('X-Hub-Signature-256', '')
        if not verify_github_signature(request.data, signature):
            return jsonify({'error': 'Invalid signature'}), 401
        
        # Parse payload
        payload = request.get_json()
        event_type = request.headers.get('X-GitHub-Event')
        
        # Only sync on push events
        if event_type == 'push':
            ref = payload.get('ref', '')
            repository = payload.get('repository', {}).get('full_name', '')
            
            print(f"Received push to {repository} on {ref}")
            
            # Trigger sync
            if sync_repository():
                return jsonify({'status': 'synced', 'ref': ref})
            else:
                return jsonify({'error': 'sync failed'}), 500
        
        return jsonify({'status': 'ignored', 'event': event_type})
    
    except Exception as e:
        print(f"Webhook error: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False) 