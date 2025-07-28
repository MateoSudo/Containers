# 📺 Transmission Media Stack with PIA VPN

A complete media automation stack using **Transmission** + **PIA VPN** with full **Cosmos proxy support**.

## 🎯 What's Included

- **🔒 PIA VPN** - All torrent traffic routed through VPN
- **⬇️ Transmission** - Torrent client (replaces qBittorrent)
- **🎬 Radarr** - Movie management
- **📺 Sonarr** - TV show management  
- **🎵 Lidarr** - Music management
- **🔍 Prowlarr** - Indexer management
- **🎭 Jellyfin** - Media server

## ✅ Key Advantages

- **No authentication conflicts** (unlike qBittorrent)
- **Cosmos-ready** container targets
- **VPN-routed downloads** for privacy
- **Auto-configured** download clients
- **Clean, minimal setup**

## 🚀 Quick Start

### 1. Setup Environment

**Option A: Use .env file (Recommended)**
```bash
# Copy the template and edit with your credentials
cp .env.example .env
nano .env  # Edit with your PIA username/password

# Deploy directly - credentials auto-loaded
./deploy-transmission-stack.sh
```

**Option B: Interactive setup**
```bash
# Run interactive setup script
./setup-environment.sh

# Deploy
./deploy-transmission-stack.sh
```

**Option C: Manual export**
```bash
export PIA_USER="your_username"
export PIA_PASS="your_password"
export LOC="netherlands"  # optional

./deploy-transmission-stack.sh
```

### 2. Configure Cosmos
Use these container targets in your Cosmos routes:

| Service | Domain | Target | Auth |
|---------|--------|--------|------|
| **Transmission** | `transmission.mrintellisense.com` | `http://localhost:9091` | None |
| **Radarr** | `radarr.mrintellisense.com` | `http://radarr:7878` | None |
| **Sonarr** | `sonarr.mrintellisense.com` | `http://sonarr:8989` | None |
| **Lidarr** | `lidarr.mrintellisense.com` | `http://lidarr:8686` | None |
| **Prowlarr** | `prowlarr.mrintellisense.com` | `http://localhost:9696` | None |
| **Jackett** | `jackett.mrintellisense.com` | `http://localhost:9117` | None |
| **Jellyfin** | `jellyfin.mrintellisense.com` | `http://jellyfin:8096` | None |

## 🌐 Direct Access (without Cosmos)

- **Transmission:** http://localhost:9091/transmission/web/
- **Radarr:** http://localhost:7878
- **Sonarr:** http://localhost:8989
- **Lidarr:** http://localhost:8686
- **Prowlarr:** http://localhost:9696
- **Jellyfin:** http://localhost:8096

## 🔧 Architecture

### VPN Routing
- **Transmission** uses `network_mode: "service:pia-vpn"`
- All torrent traffic routed through VPN
- WebUI accessible via VPN container port mapping
- *arr services connect to Transmission via Docker networking

### Download Flow
```
Prowlarr → Radarr/Sonarr/Lidarr → Transmission → PIA VPN → Internet
```

### File Structure
```
/mnt/truenas/
├── downloads/
│   ├── complete/
│   │   ├── movies/
│   │   ├── tv/
│   │   └── music/
│   └── incomplete/
├── media/
│   ├── movies/
│   ├── tv/
│   └── music/
└── torrents/  # watch folder
```

## 🛠️ Management Commands

```bash
# View logs
docker logs torrent-transmission
docker logs torrent-pia-vpn
docker logs torrent-radarr

# Restart services
docker compose restart transmission
docker compose restart

# Stop everything
docker compose down

# Update containers
docker compose pull
docker compose up -d
```

## 🔍 Troubleshooting

### VPN Issues
```bash
# Check VPN connection
docker logs torrent-pia-vpn

# Check external IP (should be VPN IP)
docker exec torrent-pia-vpn wget -qO- http://ipinfo.io/ip
```

### Transmission Issues
```bash
# Check Transmission logs
docker logs torrent-transmission

# Test WebUI
curl http://localhost:9091/transmission/web/

# Test from container  
docker exec torrent-radarr wget -qO- http://172.19.0.4:9091/transmission/web/
```

### *arr Service Issues
```bash
# Check if download client is configured
docker exec torrent-radarr wget -qO- http://172.19.0.4:9091/transmission/rpc

# View service logs
docker logs torrent-radarr
docker logs torrent-sonarr
docker logs torrent-lidarr
```

## 📁 Configuration Files

- **docker-compose.yml** - Main stack definition
- **config/transmission/settings.json** - Transmission settings
- **config/{radarr,sonarr,lidarr}/config.xml** - *arr service configs
- **.env** - Environment variables (create from .env.example)
- **.env.local** - Manual sourcing file (auto-generated)

## 🔒 Security Features

- ✅ All torrent traffic through VPN
- ✅ No port conflicts
- ✅ No authentication bypasses
- ✅ Isolated network stack
- ✅ Automatic VPN killswitch

## 🎉 Advantages over qBittorrent Setup

1. **No DryIoc errors** - Clean .NET services
2. **No authentication conflicts** - Simple setup
3. **Better VPN integration** - Native network routing
4. **Cosmos-friendly** - No proxy authentication issues
5. **Reliable startup** - No dependency chain failures

---

## 📝 Next Steps After Deployment

1. **Configure Prowlarr indexers**
2. **Connect Prowlarr to *arr services**
3. **Set up Cosmos routes**
4. **Configure Jellyfin libraries**
5. **Start adding media!**

---

**🚀 Enjoy your simplified, reliable media automation stack!** 