# Media Stack Scripts

## Main Scripts

### 🚀 `install.sh` - Complete Installation
- Sets up environment
- Creates TUN device
- Installs startup automation
- Starts all containers
- Configures services
- Runs final verification

### 🔧 `maintenance.sh` - Maintenance & Fixes
- Fix TUN device issues
- Fix VPN configuration
- Fix Prowlarr proxy issues
- Fix all *arr service issues
- Fix indexer connectivity
- Fix health issues
- Reset Prowlarr login
- Reset Jellyfin database
- Run all fixes

### 🔍 `verify.sh` - Verification & Testing
- Check container status
- Test service connectivity
- Test indexer connectivity
- Test API connectivity
- Test reboot automation
- Check health status
- Run all verifications

### 🚀 `startup-automation.sh` - Startup Automation
- Creates TUN device
- Waits for Docker
- Starts all containers
- Tests connectivity
- Used by systemd services

## Service URLs & Static IPs

| Service | URL | Static IP | Container Name |
|---------|-----|-----------|----------------|
| **Radarr** | http://localhost:7878 | 172.19.0.6 | torrent-radarr |
| **Sonarr** | http://localhost:8989 | 172.19.0.5 | torrent-sonarr |
| **Prowlarr** | http://localhost:9696 | 172.19.0.9 | torrent-prowlarr |
| **Jellyfin** | http://localhost:8096 | 172.19.0.8 | torrent-jellyfin |
| **Lidarr** | http://localhost:8686 | 172.19.0.7 | torrent-lidarr |
| **Jackett** | http://localhost:9117 | 172.19.0.10 | torrent-jackett |
| **Transmission** | http://localhost:9091/transmission/web/ | VPN Network | torrent-transmission |
| **PIA VPN** | Proxy Services | 172.19.0.4 | torrent-pia-vpn |

### Network Configuration
- **Network Name**: media_network
- **Subnet**: 172.19.0.0/16
- **Transmission**: Routes through VPN container (no static IP)

## Usage

```bash
# Complete installation
sudo ./install.sh

# Maintenance and fixes
sudo ./maintenance.sh

# Verification and testing
./verify.sh

# Manual startup
sudo ./startup-automation.sh
```

## Startup Automation

The system automatically handles startup between reboots:

### Systemd Services
- **`create-tun-device.service`**: Creates `/dev/net/tun` on boot
- **`container-startup.service`**: Starts all containers after Docker is ready

### Startup Sequence
1. **Boot**: System starts
2. **TUN Device**: `create-tun-device.service` creates `/dev/net/tun`
3. **Docker**: Docker daemon starts
4. **Containers**: `container-startup.service` starts all containers
5. **Testing**: Services are tested for connectivity

### Manual Commands
```bash
# Check service status
systemctl status create-tun-device.service
systemctl status container-startup.service

# Manual start
systemctl start container-startup.service

# View logs
journalctl -u create-tun-device.service
journalctl -u container-startup.service
```

## Backup

Old scripts have been moved to `scripts-backup/[timestamp]/` for reference.
