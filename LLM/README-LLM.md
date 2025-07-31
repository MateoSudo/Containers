# LLM Container Setup

This setup provides a complete LLM (Large Language Model) environment with AMD GPU support, featuring Open WebUI, Jupyter Lab, and Ollama API access.

## 🚀 Quick Start

```bash
# Start all services
docker compose up -d

# Check status
./troubleshoot-llm.sh

# Stop all services
docker compose down
```

## 📊 Service Status

| Service | Port | Status | URL |
|---------|------|--------|-----|
| **Ollama API** | 11434 | ✅ Running | http://localhost:11434 |
| **Open WebUI** | 3001 | ✅ Running | http://localhost:3001 |
| **Jupyter Lab** | 8889 | ✅ Running | http://localhost:8889 |
| **Text Generation WebUI** | 7860 | ⏸️ Stopped | http://localhost:7860 |

## 🔧 Configuration

### Port Assignments
- **Open WebUI**: Port 3001 (changed from 3000 due to Gitea conflict)
- **Jupyter Lab**: Port 8889 (changed from 8888 due to VPN conflict)
- **Ollama API**: Port 11434
- **Text Generation WebUI**: Port 7860

### GPU Configuration
- AMD GPU passthrough via `/dev/dri` and `/dev/kfd`
- ROCm environment variables configured
- `HSA_OVERRIDE_GFX_VERSION=11.0.0` for compatibility

## 🤖 Ollama API Usage

### Basic API Commands

```bash
# List available models
curl http://localhost:11434/api/tags

# Generate text
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama2:7b",
    "prompt": "Hello, how are you?",
    "stream": false
  }'

# Chat completion
curl -X POST http://localhost:11434/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama2:7b",
    "messages": [
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

### Python API Example

```python
import requests
import json

# Base URL for Ollama API
OLLAMA_API = "http://localhost:11434"

# List models
response = requests.get(f"{OLLAMA_API}/api/tags")
models = response.json()
print("Available models:", [m['name'] for m in models['models']])

# Generate text
def generate_text(prompt, model="llama2:7b"):
    response = requests.post(
        f"{OLLAMA_API}/api/generate",
        json={
            "model": model,
            "prompt": prompt,
            "stream": False
        }
    )
    return response.json()['response']

# Usage
result = generate_text("Explain quantum computing in simple terms")
print(result)
```

### JavaScript/Node.js API Example

```javascript
const axios = require('axios');

const OLLAMA_API = 'http://localhost:11434';

// List models
async function listModels() {
    const response = await axios.get(`${OLLAMA_API}/api/tags`);
    return response.data.models.map(m => m.name);
}

// Generate text
async function generateText(prompt, model = 'llama2:7b') {
    const response = await axios.post(`${OLLAMA_API}/api/generate`, {
        model: model,
        prompt: prompt,
        stream: false
    });
    return response.data.response;
}

// Usage
listModels().then(models => console.log('Available models:', models));
generateText('Write a haiku about AI').then(result => console.log(result));
```

## 🌐 Web Interfaces

### Open WebUI
- **URL**: http://localhost:3001
- **Features**: Chat interface, model management, conversation history
- **Default Models**: llama2:7b, llama2:13b, llama2:70b
- **Authentication**: Signup enabled, login form enabled

### Jupyter Lab
- **URL**: http://localhost:8889
- **Token**: `your-jupyter-token-here` (change in docker-compose.yml)
- **Features**: Interactive notebooks, data science environment
- **GPU Support**: AMD ROCm enabled

## 🔍 Troubleshooting

### Run the troubleshooting script
```bash
./troubleshoot-llm.sh
```

### Common Issues

#### 1. Port Conflicts
If you get "port already allocated" errors:
- Check what's using the port: `ss -tlnp | grep <port>`
- Change the port in `docker-compose.yml`
- Restart the service: `docker compose restart <service_name>`

#### 2. GPU Not Detected
```bash
# Check GPU devices
ls -la /dev/dri/
ls -la /dev/kfd/

# Check GPU usage in container
docker exec ollama nvidia-smi
```

#### 3. Container Not Starting
```bash
# Check logs
docker compose logs <service_name>

# Restart specific service
docker compose restart <service_name>

# Rebuild and restart
docker compose up -d --build <service_name>
```

#### 4. API Not Responding
```bash
# Test Ollama API
curl http://localhost:11434/api/tags

# Check container status
docker compose ps

# Restart Ollama
docker compose restart ollama
```

## 📁 File Structure

```
LLM/
├── docker-compose.yml          # Main orchestration file
├── Dockerfile.jupyter-amd      # Jupyter with AMD GPU support
├── troubleshoot-llm.sh         # Troubleshooting script
├── README-LLM.md              # This documentation
├── models/                     # Shared model directory
├── notebooks/                  # Jupyter notebooks
└── datasets/                   # Training datasets
```

## 🔄 Management Commands

```bash
# Start specific services
docker compose up -d ollama open-webui jupyter

# Stop specific services
docker compose stop open-webui jupyter

# View logs
docker compose logs -f ollama
docker compose logs -f open-webui
docker compose logs -f jupyter

# Pull a new model
docker exec ollama ollama pull llama2:13b

# Remove a model
docker exec ollama ollama rm llama2:7b

# Check resource usage
docker stats
```

## 🎯 Performance Tips

1. **GPU Memory**: Monitor GPU memory usage with `nvidia-smi` or AMD equivalent
2. **Model Loading**: Larger models take more time to load initially
3. **API Rate Limiting**: Implement rate limiting for production use
4. **Caching**: Use Redis for conversation caching (port 6379)
5. **Database**: PostgreSQL available for persistent storage (port 5432)

## 🔐 Security Notes

- Change default tokens in `docker-compose.yml`
- Use HTTPS in production
- Implement proper authentication for web interfaces
- Monitor API usage and implement rate limiting

## 📈 Monitoring

```bash
# Check container health
docker compose ps

# Monitor resource usage
docker stats

# Check GPU utilization
docker exec ollama nvidia-smi

# View recent logs
docker compose logs --tail=50 ollama
```

## 🆘 Support

If you encounter issues:
1. Run `./troubleshoot-llm.sh`
2. Check the logs: `docker compose logs <service_name>`
3. Verify GPU passthrough is working
4. Ensure ports are not conflicting with other services

Your LLM environment is now ready! 🚀 