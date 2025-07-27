#!/usr/bin/env python3
"""
Gitea to GitHub Webhook Handler
Receives webhooks from Gitea and syncs changes to GitHub
"""

import os
import json
import hmac
import hashlib
import requests
import subprocess
import tempfile
import shutil
from flask import Flask, request, jsonify
from dotenv import load_dotenv

# Load environment variables
load_dotenv('../webhook-config.env')

app = Flask(__name__)

# Configuration
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')
GITEA_LOCAL_URL = os.getenv('GITEA_LOCAL_URL')
GITEA_ADMIN_TOKEN = os.getenv('GITEA_ADMIN_TOKEN')
WEBHOOK_SECRET = os.getenv('WEBHOOK_SECRET')
GITHUB_REPO_OWNER = os.getenv('GITHUB_REPO_OWNER')
GITHUB_REPO_NAME = os.getenv('GITHUB_REPO_NAME')
GITEA_REPO_OWNER = os.getenv('GITEA_REPO_OWNER')
GITEA_REPO_NAME = os.getenv('GITEA_REPO_NAME')

def verify_gitea_signature(payload, signature):
    """Verify Gitea webhook signature"""
    if not WEBHOOK_SECRET:
        return True  # Skip verification if no secret set
    
    expected = hmac.new(
        WEBHOOK_SECRET.encode(),
        payload,
        hashlib.sha256
    ).hexdigest()
    
    return hmac.compare_digest(expected, signature)

def sync_to_github(branch_name, commit_info):
    """Sync specific branch to GitHub using git commands"""
    try:
        with tempfile.TemporaryDirectory() as temp_dir:
            # Clone from Gitea
            gitea_url = f"{GITEA_LOCAL_URL}/{GITEA_REPO_OWNER}/{GITEA_REPO_NAME}.git"
            github_url = f"https://{GITHUB_TOKEN}@github.com/{GITHUB_REPO_OWNER}/{GITHUB_REPO_NAME}.git"
            
            # Clone Gitea repository
            subprocess.run([
                'git', 'clone', '--branch', branch_name, 
                gitea_url, temp_dir
            ], check=True, cwd='/tmp')
            
            # Add GitHub remote
            subprocess.run([
                'git', 'remote', 'add', 'github', github_url
            ], check=True, cwd=temp_dir)
            
            # Push to GitHub
            subprocess.run([
                'git', 'push', 'github', branch_name
            ], check=True, cwd=temp_dir)
            
            return True
    except subprocess.CalledProcessError as e:
        print(f"Git sync error: {e}")
        return False
    except Exception as e:
        print(f"Sync error: {e}")
        return False

@app.route('/webhook/gitea', methods=['POST'])
def gitea_webhook():
    """Handle Gitea webhook"""
    try:
        # Verify signature (Gitea uses different header)
        signature = request.headers.get('X-Gitea-Signature', '')
        if not verify_gitea_signature(request.data, signature):
            return jsonify({'error': 'Invalid signature'}), 401
        
        # Parse payload
        payload = request.get_json()
        event_type = request.headers.get('X-Gitea-Event')
        
        # Only sync on push events
        if event_type == 'push':
            ref = payload.get('ref', '')
            branch_name = ref.replace('refs/heads/', '') if ref.startswith('refs/heads/') else ref
            repository = payload.get('repository', {}).get('full_name', '')
            commits = payload.get('commits', [])
            
            print(f"Received push to {repository} on {ref}")
            
            # Trigger sync
            if sync_to_github(branch_name, commits):
                return jsonify({'status': 'synced', 'ref': ref, 'branch': branch_name})
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
    app.run(host='0.0.0.0', port=5001, debug=False) 