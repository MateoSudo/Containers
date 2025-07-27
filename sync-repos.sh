#!/bin/bash

# GitHub to Gitea Sync Script
echo "🔄 Syncing repositories..."

# Current repository sync
echo "📁 Syncing current repository (Containers)..."
git push gitea --all 2>/dev/null && echo "✅ Branches synced to Gitea" || echo "❌ Failed to sync branches"
git push gitea --tags 2>/dev/null && echo "✅ Tags synced to Gitea" || echo "❌ Failed to sync tags"

# Sync from GitHub to Gitea
echo "📥 Pull latest from GitHub..."
git fetch origin
git merge origin/$(git branch --show-current) --ff-only 2>/dev/null || echo "⚠️  Manual merge may be needed"

echo "📤 Push to Gitea..."
git push gitea $(git branch --show-current) 2>/dev/null && echo "✅ Current branch synced" || echo "❌ Failed to sync current branch"

echo "🎉 Sync complete!"
