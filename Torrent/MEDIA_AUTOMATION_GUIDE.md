# Media Stack Automation Configuration Guide

## Directory Structure
Your stack is configured with this simplified structure:
```
/mnt/truenas/
├── downloads/           # QBittorrent downloads (temporary)
└── media/
    ├── tv/             # Final TV shows location
    ├── movies/         # Final movies location
    └── music/          # Final music location
```

## Automated File Management Setup

### 1. QBittorrent Configuration
Access QBittorrent at: `https://your-cosmos-domain/qbittorrent` (via Cosmos Cloud proxy)

**Settings > Downloads:**
- Default Save Path: `/downloads`
- Keep incomplete torrents in: `/downloads/incomplete` (optional)
- Copy .torrent files to: (leave empty - not needed)
- Automatically delete .torrent files: `Yes`

**Settings > Connection:**
- Use UPnP/NAT-PMP: `No` (we're using VPN)

### 2. Sonarr Configuration (TV Shows)
Access Sonarr at: `https://your-cosmos-domain/sonarr`

**Settings > Media Management:**
- Rename episodes: `Yes`
- Replace illegal characters: `Yes`
- Use Hardlinks instead of Copy: `Yes` (saves disk space)
- Import Extra Files: `Yes` (for subtitles, etc.)
- Delete empty folders: `Yes`

**Settings > Download Clients:**
- Add QBittorrent:
  - Host: `pia-vpn` (Docker hostname)
  - Port: `8083`
  - Category: `tv-sonarr`
  - Remove Completed: `Yes`
  - Remove Failed: `Yes`

**Series > Add Series:**
- Root Folder: `/tv`

### 3. Radarr Configuration (Movies)
Access Radarr at: `https://your-cosmos-domain/radarr`

**Settings > Media Management:**
- Rename Movies: `Yes`
- Replace illegal characters: `Yes`
- Use Hardlinks instead of Copy: `Yes`
- Import Extra Files: `Yes`
- Delete empty folders: `Yes`

**Settings > Download Clients:**
- Add QBittorrent:
  - Host: `pia-vpn`
  - Port: `8083`
  - Category: `movies-radarr`
  - Remove Completed: `Yes`
  - Remove Failed: `Yes`

**Movies > Add Movies:**
- Root Folder: `/movies`

### 4. Lidarr Configuration (Music)
Access Lidarr at: `https://your-cosmos-domain/lidarr`

**Settings > Media Management:**
- Rename Tracks: `Yes`
- Replace illegal characters: `Yes`
- Use Hardlinks instead of Copy: `Yes`
- Import Extra Files: `Yes`
- Delete empty folders: `Yes`

**Settings > Download Clients:**
- Add QBittorrent:
  - Host: `pia-vpn`
  - Port: `8083`
  - Category: `music-lidarr`
  - Remove Completed: `Yes`
  - Remove Failed: `Yes`

**Artists > Add Artist:**
- Root Folder: `/music`

### 5. Prowlarr Configuration (Indexer Management)
Access Prowlarr at: `https://your-cosmos-domain/prowlarr`

**Settings > Apps:**
- Add Sonarr:
  - Server: `http://sonarr:8989`
  - API Key: (from Sonarr settings)
- Add Radarr:
  - Server: `http://radarr:7878`
  - API Key: (from Radarr settings)
- Add Lidarr:
  - Server: `http://lidarr:8686`
  - API Key: (from Lidarr settings)

## How the Automation Works

1. **Search & Download:**
   - You search for content in Sonarr/Radarr/Lidarr
   - They search indexers (via Prowlarr) and send downloads to QBittorrent
   - QBittorrent downloads files to `/downloads`

2. **Automatic Processing:**
   - *arr apps monitor downloads folder
   - When download completes, they:
     - Move files to correct media folder (`/tv`, `/movies`, `/music`)
     - Rename according to your naming scheme
     - Delete files from downloads folder
     - Update their databases

3. **Result:**
   - Clean `/downloads` folder (automatically emptied)
   - Properly organized media in `/media/tv`, `/media/movies`, `/media/music`
   - Ready for streaming via Jellyfin

## QBittorrent Categories (Optional but Recommended)

In QBittorrent, create these categories:
- `tv-sonarr` → Save path: `/downloads/tv`
- `movies-radarr` → Save path: `/downloads/movies`
- `music-lidarr` → Save path: `/downloads/music`

This helps organize downloads before the *arr apps process them.

## Troubleshooting

If files aren't moving automatically:
1. Check that all services can access the `/downloads` folder
2. Verify QBittorrent download client settings in *arr apps
3. Check *arr app logs for permission errors
4. Ensure PUID/PGID (1000) has read/write access to all folders

## Benefits of This Setup

- **Single downloads folder** - clean and simple
- **Automatic organization** - no manual file moving
- **Proper naming** - consistent, media center friendly
- **Space efficient** - hardlinks save disk space
- **Clean torrents** - automatic cleanup after processing
