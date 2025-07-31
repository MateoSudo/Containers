#!/bin/bash

echo "🔍 LLM Container Troubleshooting Script"
echo "======================================"

# Function to check container status
check_container() {
    local container_name=$1
    local port=$2
    local service_name=$3
    
    echo -e "\n📊 Checking $service_name..."
    
    # Check if container is running
    if docker ps | grep -q "$container_name"; then
        echo "✅ Container $container_name is running"
        
        # Check container health
        local health=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null)
        if [ "$health" = "healthy" ]; then
            echo "✅ Container is healthy"
        elif [ "$health" = "unhealthy" ]; then
            echo "❌ Container is unhealthy"
        else
            echo "⚠️  Health status: $health"
        fi
        
        # Test port connectivity
        if [ -n "$port" ]; then
            if curl -s -I "http://localhost:$port" >/dev/null 2>&1; then
                echo "✅ Port $port is accessible"
            else
                echo "❌ Port $port is not accessible"
            fi
        fi
    else
        echo "❌ Container $container_name is not running"
    fi
}

# Function to check Ollama API
check_ollama_api() {
    echo -e "\n🤖 Checking Ollama API..."
    
    # Test basic API
    if curl -s "http://localhost:11434/api/tags" >/dev/null 2>&1; then
        echo "✅ Ollama API is responding"
        
        # Get available models
        local models=$(curl -s "http://localhost:11434/api/tags" | jq -r '.models[].name' 2>/dev/null)
        if [ -n "$models" ]; then
            echo "📋 Available models:"
            echo "$models" | while read -r model; do
                echo "  - $model"
            done
        else
            echo "⚠️  No models found"
        fi
    else
        echo "❌ Ollama API is not responding"
    fi
}

# Function to check GPU access
check_gpu_access() {
    echo -e "\n🎮 Checking GPU Access..."
    
    # Check if GPU devices are accessible
    if [ -e "/dev/dri" ]; then
        echo "✅ /dev/dri is accessible"
        ls -la /dev/dri/
    else
        echo "❌ /dev/dri is not accessible"
    fi
    
    if [ -e "/dev/kfd" ]; then
        echo "✅ /dev/kfd is accessible"
    else
        echo "❌ /dev/kfd is not accessible"
    fi
    
    # Check GPU usage in containers
    echo -e "\n📊 GPU Usage in Containers:"
    docker exec ollama nvidia-smi 2>/dev/null || echo "nvidia-smi not available in Ollama container"
}

# Function to show service URLs
show_service_urls() {
    echo -e "\n🌐 Service URLs:"
    echo "  • Open WebUI: http://localhost:3001"
    echo "  • Jupyter Lab: http://localhost:8889"
    echo "  • Ollama API: http://localhost:11434"
    echo "  • Text Generation WebUI: http://localhost:7860"
}

# Function to show recent logs
show_logs() {
    local container_name=$1
    local lines=${2:-10}
    
    echo -e "\n📝 Recent logs for $container_name (last $lines lines):"
    docker compose logs --tail="$lines" "$container_name" 2>/dev/null || echo "No logs available"
}

# Main execution
echo "Starting comprehensive LLM container check..."

# Check all containers
check_container "ollama" "11434" "Ollama"
check_container "open-webui" "3001" "Open WebUI"
check_container "jupyter-notebook" "8889" "Jupyter Lab"

# Check Ollama API
check_ollama_api

# Check GPU access
check_gpu_access

# Show service URLs
show_service_urls

# Show recent logs for troubleshooting
echo -e "\n📋 Recent Logs Summary:"
show_logs "ollama" 5
show_logs "open-webui" 5
show_logs "jupyter-notebook" 5

echo -e "\n🎯 Quick Commands:"
echo "  • Start all services: docker compose up -d"
echo "  • Stop all services: docker compose down"
echo "  • Restart specific service: docker compose restart <service_name>"
echo "  • View logs: docker compose logs <service_name>"
echo "  • Test Ollama API: curl http://localhost:11434/api/tags"
echo "  • Pull a model: docker exec ollama ollama pull llama2:7b"

echo -e "\n✅ Troubleshooting complete!" 