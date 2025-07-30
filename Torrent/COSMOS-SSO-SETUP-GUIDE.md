# Cosmos SSO Setup Guide for Media Stack

This guide explains how to configure Cosmos Single Sign-On (SSO) for your media stack, including special considerations for TVs and devices.

## 🎯 Overview

Your media stack is now configured with:
- **Direct port access** for all services
- **Cosmos SSO** for web interfaces
- **No authentication** for TVs and devices
- **SSL termination** handled by Cosmos

## 📋 Current Configuration

| Service | Port | Direct Access | Cosmos Route |
|---------|------|---------------|--------------|
| **Sonarr** | 8989 | http://localhost:8989 | localhost:8989 |
| **Radarr** | 7878 | http://localhost:7878 | localhost:7878 |
| **Lidarr** | 8686 | http://localhost:8686 | localhost:8686 |
| **Prowlarr** | 9696 | http://localhost:9696 | localhost:9696 |
| **Jellyfin** | 8096 | http://localhost:8096 | localhost:8096 |
| **Jackett** | 9117 | http://localhost:9117 | localhost:9117 |
| **Transmission** | 9091 | http://localhost:9091 | localhost:9091 |

## 🚀 Step-by-Step Cosmos Setup

### Step 1: Access Cosmos UI
Open your browser and go to: **https://localhost/cosmos-ui/**

### Step 2: Add Applications to Cosmos

For each service, add it to Cosmos with these settings:

#### Sonarr
- **Name**: Sonarr
- **URL**: `localhost:8989`
- **Domain**: `sonarr.mrintellisense.com`
- **Authentication**: Enable

#### Radarr
- **Name**: Radarr
- **URL**: `localhost:7878`
- **Domain**: `radarr.mrintellisense.com`
- **Authentication**: Enable

#### Lidarr
- **Name**: Lidarr
- **URL**: `localhost:8686`
- **Domain**: `lidarr.mrintellisense.com`
- **Authentication**: Enable

#### Prowlarr
- **Name**: Prowlarr
- **URL**: `localhost:9696`
- **Domain**: `prowlarr.mrintellisense.com`
- **Authentication**: Enable

#### Jellyfin
- **Name**: Jellyfin
- **URL**: `localhost:8096`
- **Domain**: `jellyfin.mrintellisense.com`
- **Authentication**: Enable

#### Jackett
- **Name**: Jackett
- **URL**: `localhost:9117`
- **Domain**: `jackett.mrintellisense.com`
- **Authentication**: Enable

#### Transmission
- **Name**: Transmission
- **URL**: `localhost:9091`
- **Domain**: `transmission.mrintellisense.com`
- **Authentication**: Enable

### Step 3: Configure Authentication

In Cosmos, set up authentication for each app:
1. **Enable authentication** for each service
2. **Create user accounts** in Cosmos
3. **Set access permissions** as needed
4. **Configure session timeouts** (recommended: 24 hours)

## 📺 TV and Device Configuration

### For Smart TVs and Streaming Devices

**Direct Access (Recommended for TVs):**
- TVs connect directly to Jellyfin: `http://your-server-ip:8096`
- **No login required** - TVs stay connected permanently
- **No Cosmos authentication** - direct access to Jellyfin

**Web Interface (Optional for TVs):**
- TVs can also access via Cosmos: `https://jellyfin.mrintellisense.com`
- **Requires login** through Cosmos SSO
- **SSL certificates** handled by Cosmos

### For Mobile Devices and Tablets

**Jellyfin App:**
- Use direct connection: `http://your-server-ip:8096`
- **No authentication** - stays logged in
- **Works offline** and with background sync

**Web Browser:**
- Use Cosmos URL: `https://jellyfin.mrintellisense.com`
- **SSO authentication** required
- **SSL certificates** provided by Cosmos

## 🔧 Service-Specific Configuration

### Jellyfin Setup

1. **Access Jellyfin**: http://localhost:8096
2. **Complete setup wizard** (no login required)
3. **Add media libraries**:
   - Movies: `/data/movies`
   - TV Shows: `/data/tv`
   - Music: `/data/music`
4. **Configure metadata** and artwork
5. **Add to Cosmos** for web SSO

### *Arr Services Setup

1. **Access each service** via direct port
2. **Complete initial setup** for each service
3. **Configure download clients** (Transmission)
4. **Add indexers** (Prowlarr/Jackett)
5. **Add to Cosmos** for web SSO

## 🌐 Final URLs

Once configured in Cosmos, your services will be available at:

- **Sonarr**: https://sonarr.mrintellisense.com
- **Radarr**: https://radarr.mrintellisense.com
- **Lidarr**: https://lidarr.mrintellisense.com
- **Prowlarr**: https://prowlarr.mrintellisense.com
- **Jellyfin**: https://jellyfin.mrintellisense.com
- **Jackett**: https://jackett.mrintellisense.com
- **Transmission**: https://transmission.mrintellisense.com

## 🔒 Security Benefits

### For Web Access
- **Single sign-on** across all services
- **SSL certificates** automatically managed
- **Centralized authentication** through Cosmos
- **Session management** and timeout controls

### For TVs and Devices
- **Direct access** without authentication
- **Permanent connections** - no login required
- **Offline functionality** maintained
- **Background sync** works normally

## 🛠️ Troubleshooting

### Jellyfin Login Issues
If Jellyfin still asks for login:
1. **Clear browser cache** and cookies
2. **Access directly**: http://localhost:8096
3. **Complete setup wizard** first
4. **Then add to Cosmos**

### TV Connection Issues
If TVs can't connect:
1. **Check firewall** allows port 8096
2. **Use server IP** instead of localhost
3. **Try direct connection**: http://your-server-ip:8096
4. **Verify network** connectivity

### Cosmos Authentication Issues
If SSO isn't working:
1. **Check Cosmos logs**: `journalctl -u cosmos`
2. **Verify domain DNS** settings
3. **Test direct access** first
4. **Check SSL certificates** in Cosmos

## 📱 Device Compatibility

### Fully Compatible
- **Smart TVs** (Samsung, LG, Sony, etc.)
- **Fire TV Sticks** and Fire TVs
- **Apple TV** (via Jellyfin app)
- **Roku** (via Jellyfin channel)
- **Android TV** devices
- **iOS/Android** mobile apps

### Web Browser Access
- **Chrome, Firefox, Safari, Edge**
- **Mobile browsers**
- **Tablet browsers**
- **All require Cosmos authentication**

## 🎯 Best Practices

### For TVs and Devices
1. **Use direct connection** for TVs
2. **Configure once** - stays connected
3. **No login required** for media playback
4. **Works offline** and with background sync

### For Web Management
1. **Use Cosmos URLs** for management
2. **Single login** for all services
3. **SSL certificates** automatically managed
4. **Centralized access control**

### For Security
1. **TVs bypass authentication** (intentional)
2. **Web access requires SSO** (secure)
3. **SSL termination** at Cosmos level
4. **Session management** for web users

## ✅ Verification Checklist

- [ ] All services accessible via direct ports
- [ ] Cosmos UI accessible at https://localhost/cosmos-ui/
- [ ] Jellyfin setup wizard completed
- [ ] All services added to Cosmos
- [ ] Authentication enabled in Cosmos
- [ ] SSL certificates working
- [ ] TVs can connect directly to Jellyfin
- [ ] Web access requires Cosmos login
- [ ] All services accessible via clean URLs

## 🎉 Success!

Once completed, you'll have:
- **TVs and devices** that stay logged in permanently
- **Web management** with single sign-on
- **SSL certificates** automatically managed
- **Clean URLs** for all services
- **Centralized authentication** through Cosmos

Your media stack is now ready for both direct device access and secure web management! 🚀 