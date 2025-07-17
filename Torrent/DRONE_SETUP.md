# Drone CI/CD Setup Guide

## Prerequisites

### 1. GitHub OAuth App Setup
1. Go to GitHub Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Fill in:
   - Application name: `Drone CI`
   - Homepage URL: `http://your-domain.com:8082` (or `http://localhost:8082` for local)
   - Authorization callback URL: `http://your-domain.com:8082/login` (or `http://localhost:8082/login`)
4. Save the Client ID and Client Secret

### 2. Generate RPC Secret
```bash
openssl rand -hex 16
```

## Configuration Steps

### 1. Update .env file
Copy `.env.example` to `.env` and update:
```bash
# GitHub OAuth credentials from step 1
DRONE_GITHUB_CLIENT_ID=your_actual_client_id
DRONE_GITHUB_CLIENT_SECRET=your_actual_client_secret

# Generated secret from step 2
DRONE_RPC_SECRET=your_generated_secret

# Your domain/IP (change for production)
DRONE_SERVER_HOST=localhost:8082

# Your GitHub username
DRONE_USER_CREATE=username:your_github_username,admin:true
```

### 2. Start the services
```bash
podman-compose up -d drone drone-runner
```

### 3. Access Drone
- Open: http://localhost:8082
- Login with your GitHub account
- Activate repositories you want to build

## Example .drone.yml for your repositories

Create `.drone.yml` in your repository root:

```yaml
kind: pipeline
type: docker
name: default

steps:
- name: test
  image: node:16
  commands:
  - npm install
  - npm test

- name: build
  image: node:16
  commands:
  - npm run build

- name: deploy
  image: plugins/docker
  settings:
    repo: your-registry/your-app
    tags: latest
    username:
      from_secret: docker_username
    password:
      from_secret: docker_password
  when:
    branch:
    - main
```

## Security Notes

1. **Production Setup**: Use HTTPS and proper domain
2. **Secrets**: Store sensitive data in Drone secrets, not in .drone.yml
3. **Registration**: Set `DRONE_REGISTRATION_CLOSED=true` in production
4. **Repository Filter**: Limit which repos Drone can access

## Useful Commands

```bash
# View logs
podman logs drone
podman logs drone-runner

# Restart services
podman-compose restart drone drone-runner

# Access Drone CLI (install drone CLI first)
drone info
drone repo ls
```
