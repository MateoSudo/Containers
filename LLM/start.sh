#!/bin/bash

# LLM Docker Compose Stack Startup Script

set -e

echo "🚀 Starting LLM Docker Compose Stack..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if config.env exists, if not create from example
if [ ! -f "config.env" ]; then
    if [ -f "config.env.example" ]; then
        echo "📝 Creating config.env from example..."
        cp config.env.example config.env
        echo "⚠️  Please edit config.env with your own values before starting services."
        echo "   Important: Change default passwords and tokens!"
        read -p "Press Enter to continue or Ctrl+C to edit config.env first..."
    else
        echo "❌ config.env.example not found. Please create config.env manually."
        exit 1
    fi
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p models notebooks datasets

# Check GPU support
echo "🔍 Checking GPU support..."
if docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi &> /dev/null; then
    echo "✅ GPU support detected"
else
    echo "⚠️  GPU support not detected. Services will run on CPU only."
    echo "   For AMD GPU support, ensure ROCm drivers are installed."
fi

# Start services
echo "🐳 Starting Docker services..."
docker-compose up -d

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 10

# Check service status
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "🎉 LLM Stack is starting up!"
echo ""
echo "📱 Services:"
echo "   • Open WebUI: http://localhost:3000"
echo "   • Jupyter Notebook: http://localhost:8888"
echo "   • Ollama API: http://localhost:11434"
echo "   • Text Generation WebUI: http://localhost:7860"
echo ""
echo "📚 Next steps:"
echo "   1. Wait a few minutes for all services to fully start"
echo "   2. Access Open WebUI at http://localhost:3000"
echo "   3. Download models: docker-compose exec ollama ollama pull llama2:7b"
echo "   4. Check logs: docker-compose logs -f"
echo ""
echo "🛑 To stop services: docker-compose down"
echo "🔄 To restart: docker-compose restart" 