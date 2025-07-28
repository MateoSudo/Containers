#!/bin/bash
# Reset qBittorrent password to admin/admin

echo "🔧 Resetting qBittorrent password to admin/admin..."

# Stop qBittorrent
docker stop torrent-qbittorrent

# Update password in config (password = "admin")
sed -i 's/WebUI\\Password_PBKDF2=.*/WebUI\\Password_PBKDF2="@ByteArray(d0R3T\/1j5dH6fO4mhvjH8sZ3OXwZXy7XJp1L5Y1j9+Z1dVjHWpg=:1rQSsbZaE+cJiDlKKYJJD3Zh3+ZZNjEZY3LfLH1YwXWoKkYCWZ9Y=)"/' config/qbittorrent/qBittorrent/qBittorrent.conf

# Start qBittorrent
docker start torrent-qbittorrent

echo "✅ Password reset complete!"
echo "🌐 Login at: http://localhost:8083"
echo "👤 Username: admin"
echo "�� Password: admin" 