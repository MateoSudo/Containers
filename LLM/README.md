# LLM Docker Compose Stack

A comprehensive Docker Compose stack for hosting Large Language Models (LLMs) with AMD GPU support, featuring Open WebUI, Jupyter Notebook server for training, and additional tools.

## Features

- **Open WebUI**: Modern web interface for interacting with LLMs
- **Ollama**: Local LLM server with AMD GPU support
- **Jupyter Notebook**: Training environment with GPU acceleration
- **Text Generation WebUI**: Alternative interface (optional)
- **PostgreSQL**: Database for conversation history (optional)
- **Redis**: Caching layer (optional)
- **AMD GPU Support**: Full GPU acceleration for training and inference

## Prerequisites

### System Requirements

- Docker and Docker Compose installed
- AMD GPU with ROCm support
- At least 16GB RAM (32GB+ recommended)
- 50GB+ free disk space for models

### AMD GPU Setup

1. **Install AMD ROCm drivers**:
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install rocm-dkms
   
   # Or follow AMD's official installation guide:
   # https://rocmdocs.amd.com/en/latest/Installation_Guide/Installation-Guide.html
   ```

2. **Install Docker with GPU support**:
   ```bash
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   
   # Add user to docker group
   sudo usermod -aG docker $USER
   
   # Install NVIDIA Container Toolkit (for compatibility)
   sudo apt-get install nvidia-container-toolkit
   sudo systemctl restart docker
   ```

3. **Verify GPU support**:
   ```bash
   docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
   ```

## Quick Start

1. **Clone and navigate to the project**:
   ```bash
   cd /path/to/your/llm-stack
   ```

2. **Create necessary directories**:
   ```bash
   mkdir -p models notebooks datasets
   ```

3. **Configure environment variables**:
   ```bash
   # Copy and edit the configuration
   cp config.env.example config.env
   nano config.env
   ```

4. **Start the stack**:
   ```bash
   # Start all services
   docker-compose up -d
   
   # Or start specific services
   docker-compose up -d ollama open-webui jupyter
   ```

5. **Download models** (optional):
   ```bash
   # Pull models using Ollama
   docker-compose exec ollama ollama pull llama2:7b
   docker-compose exec ollama ollama pull llama2:13b
   ```

## Services

### Open WebUI (Port 3000)
- **URL**: http://localhost:3000
- **Purpose**: Modern web interface for LLM interactions
- **Features**: Chat interface, model management, conversation history

### Ollama (Port 11434)
- **URL**: http://localhost:11434
- **Purpose**: LLM server with AMD GPU acceleration
- **API**: RESTful API for model inference

### Jupyter Notebook (Port 8888)
- **URL**: http://localhost:8888
- **Purpose**: Training environment with GPU support
- **Token**: Set in `config.env` (JUPYTER_TOKEN)

### Text Generation WebUI (Port 7860) - Optional
- **URL**: http://localhost:7860
- **Purpose**: Alternative web interface
- **Features**: Advanced generation parameters, extensions

### PostgreSQL (Port 5432) - Optional
- **Purpose**: Database for conversation history
- **Credentials**: Set in `config.env`

### Redis (Port 6379) - Optional
- **Purpose**: Caching layer for improved performance

## Configuration

### Environment Variables

Edit `config.env` to customize your setup:

```bash
# Security
WEBUI_SECRET_KEY=your-secure-secret-key
JUPYTER_TOKEN=your-jupyter-token

# Database
POSTGRES_PASSWORD=your-secure-password

# Models
DEFAULT_MODELS=llama2:7b,llama2:13b,llama2:70b
```

### GPU Configuration

The stack is configured for AMD GPUs. For NVIDIA GPUs, modify the `docker-compose.yml`:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu]
```

## Usage

### Starting Services

```bash
# Start all services
docker-compose up -d

# Start specific services
docker-compose up -d ollama open-webui

# View logs
docker-compose logs -f ollama
```

### Managing Models

```bash
# List available models
docker-compose exec ollama ollama list

# Pull a model
docker-compose exec ollama ollama pull llama2:7b

# Remove a model
docker-compose exec ollama ollama rm llama2:7b
```

### Training with Jupyter

1. Access Jupyter at http://localhost:8888
2. Use the token from `config.env`
3. Create notebooks in the `notebooks/` directory
4. Models and datasets are available in mounted volumes

### API Usage

```bash
# Generate text via Ollama API
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama2:7b",
    "prompt": "Hello, how are you?",
    "stream": false
  }'
```

## Troubleshooting

### GPU Issues

1. **Check GPU detection**:
   ```bash
   docker-compose exec ollama nvidia-smi
   # or
   docker-compose exec ollama rocm-smi
   ```

2. **Verify ROCm installation**:
   ```bash
   rocm-smi
   ```

3. **Check Docker GPU support**:
   ```bash
   docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
   ```

### Memory Issues

1. **Increase Docker memory limit**:
   - Docker Desktop: Settings → Resources → Memory
   - Linux: Edit `/etc/docker/daemon.json`

2. **Use smaller models**:
   ```bash
   docker-compose exec ollama ollama pull llama2:7b
   ```

### Port Conflicts

If ports are already in use, modify the `docker-compose.yml`:

```yaml
ports:
  - "3001:8080"  # Change 3000 to 3001
```

## Security Considerations

1. **Change default passwords** in `config.env`
2. **Use strong secret keys** for WebUI
3. **Restrict network access** if needed
4. **Regular updates** of Docker images
5. **Backup volumes** regularly

## Backup and Restore

### Backup

```bash
# Backup volumes
docker run --rm -v llm-stack_ollama-data:/data -v $(pwd):/backup alpine tar czf /backup/ollama-backup.tar.gz -C /data .

# Backup models directory
tar czf models-backup.tar.gz models/
```

### Restore

```bash
# Restore volumes
docker run --rm -v llm-stack_ollama-data:/data -v $(pwd):/backup alpine tar xzf /backup/ollama-backup.tar.gz -C /data

# Restore models
tar xzf models-backup.tar.gz
```

## Performance Optimization

1. **Use SSD storage** for models and data
2. **Allocate sufficient RAM** to Docker
3. **Monitor GPU usage** with `rocm-smi`
4. **Use appropriate model sizes** for your hardware
5. **Enable caching** with Redis for better performance

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source and available under the MIT License. 