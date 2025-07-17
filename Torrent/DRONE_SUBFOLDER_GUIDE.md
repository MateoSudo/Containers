# Drone CI/CD with Subfolders Guide

## Problem
When you have multiple containers in subfolders of a single repository, Drone needs to know which subfolder changed to trigger the correct build.

## Solution: Path-based Triggers

### Repository Structure
```
your-repo/
├── .drone.yml                    # Main pipeline (optional)
├── Torrent/
│   ├── .drone.yml               # Torrent stack pipeline
│   ├── podman-compose.yml
│   └── setup-media-stack.sh
├── WebApp/
│   ├── .drone.yml               # Web app pipeline
│   ├── Dockerfile
│   └── src/
└── Database/
    ├── .drone.yml               # Database pipeline
    └── docker-compose.yml
```

## Example .drone.yml for Torrent Subfolder

Create `Torrent/.drone.yml`:

```yaml
kind: pipeline
type: docker
name: torrent-stack

# Only trigger when files in Torrent/ folder change
trigger:
  paths:
    include:
    - "Torrent/**"
  event:
  - push
  - pull_request

steps:
- name: validate-compose
  image: docker/compose:latest
  commands:
  - cd Torrent
  - docker-compose config

- name: deploy-stack
  image: alpine:latest
  commands:
  - apk add --no-cache openssh-client
  - cd Torrent
  - echo "Deploying torrent stack..."
  # Add your deployment commands here
  when:
    branch:
    - main

- name: notify
  image: plugins/slack
  settings:
    webhook:
      from_secret: slack_webhook
    channel: deployments
    template: >
      {{#success build.status}}
        ✅ Torrent stack deployed successfully
      {{else}}
        ❌ Torrent stack deployment failed
      {{/success}}
  when:
    status: [ success, failure ]
```

## Alternative: Single .drone.yml with Conditional Steps

Create a single `.drone.yml` in repo root:

```yaml
kind: pipeline
type: docker
name: multi-container

steps:
# Torrent Stack Steps
- name: torrent-validate
  image: docker/compose:latest
  commands:
  - cd Torrent
  - docker-compose config
  when:
    paths:
      include:
      - "Torrent/**"

- name: torrent-deploy
  image: alpine:latest
  commands:
  - echo "Deploying torrent stack..."
  - cd Torrent
  # Add deployment commands
  when:
    branch:
    - main
    paths:
      include:
      - "Torrent/**"

# Web App Steps
- name: webapp-test
  image: node:16
  commands:
  - cd WebApp
  - npm install
  - npm test
  when:
    paths:
      include:
      - "WebApp/**"

- name: webapp-build
  image: docker:latest
  commands:
  - cd WebApp
  - docker build -t webapp:latest .
  when:
    branch:
    - main
    paths:
      include:
      - "WebApp/**"

# Database Steps
- name: database-deploy
  image: docker/compose:latest
  commands:
  - cd Database
  - docker-compose up -d
  when:
    branch:
    - main
    paths:
      include:
      - "Database/**"
```

## Benefits of This Approach

1. **Efficient**: Only builds what changed
2. **Organized**: Each subfolder can have its own pipeline
3. **Scalable**: Easy to add more containers/services
4. **Flexible**: Different deployment strategies per service

## Drone Configuration

In your Drone server settings, make sure to:

1. **Enable the repository** in Drone UI
2. **Set appropriate secrets** for each pipeline
3. **Configure webhooks** if using external notifications

## Testing Path Triggers

You can test if path triggers work by:

```bash
# Make a change in Torrent folder
echo "# Updated" >> Torrent/README.md
git add Torrent/README.md
git commit -m "Update torrent docs"
git push

# This should only trigger the torrent pipeline
```

## Best Practices

1. **Use descriptive pipeline names** (`torrent-stack`, `web-app`, etc.)
2. **Include validation steps** before deployment
3. **Add notification steps** for deployment status
4. **Use secrets** for sensitive configuration
5. **Test path patterns** to ensure they work as expected

## Troubleshooting

- **Pipeline not triggering**: Check path patterns in `trigger.paths`
- **Wrong pipeline running**: Verify `include` patterns are specific enough
- **All pipelines running**: Make sure you're using `paths` in `when` conditions
