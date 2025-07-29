#!/bin/bash

# Health Check Script for LLM Docker Compose Stack

echo "🔍 Health Check for LLM Stack"
echo "=============================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running"
    exit 1
fi

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml not found"
    exit 1
fi

# Check service status
echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "🔗 Testing service connectivity..."

# Test Open WebUI
echo "Testing Open WebUI (port 3000)..."
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ Open WebUI is accessible"
else
    echo "❌ Open WebUI is not accessible"
fi

# Test Ollama
echo "Testing Ollama API (port 11434)..."
if curl -s http://localhost:11434/api/tags > /dev/null; then
    echo "✅ Ollama API is accessible"
else
    echo "❌ Ollama API is not accessible"
fi

# Test Jupyter
echo "Testing Jupyter (port 8888)..."
if curl -s http://localhost:8888 > /dev/null; then
    echo "✅ Jupyter is accessible"
else
    echo "❌ Jupyter is not accessible"
fi

# Test Text Generation WebUI
echo "Testing Text Generation WebUI (port 7860)..."
if curl -s http://localhost:7860 > /dev/null; then
    echo "✅ Text Generation WebUI is accessible"
else
    echo "❌ Text Generation WebUI is not accessible"
fi

# Check GPU support
echo ""
echo "🎮 GPU Support:"
if docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi > /dev/null 2>&1; then
    echo "✅ GPU support detected"
    docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits
else
    echo "⚠️  GPU support not detected"
fi

# Check disk space
echo ""
echo "💾 Disk Space:"
df -h . | tail -1

# Check memory usage
echo ""
echo "🧠 Memory Usage:"
free -h

# Check running containers
echo ""
echo "🐳 Running Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "📋 Summary:"
echo "• Open WebUI: http://localhost:3000"
echo "• Jupyter: http://localhost:8888"
echo "• Ollama API: http://localhost:11434"
echo "• Text Generation WebUI: http://localhost:7860"
echo ""
echo "📚 Useful commands:"
echo "• View logs: docker-compose logs -f [service_name]"
echo "• Stop services: docker-compose down"
echo "• Restart services: docker-compose restart"
echo "• Pull models: docker-compose exec ollama ollama pull llama2:7b" 