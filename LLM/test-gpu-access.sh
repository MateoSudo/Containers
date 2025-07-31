#!/bin/bash

echo "=== Testing GPU Access for LLM Containers ==="

echo -e "\n1. Checking Ollama GPU Detection:"
docker exec ollama env | grep -E "(HIP|ROCR|HSA|GPU)"

echo -e "\n2. Checking Ollama GPU Devices:"
docker exec ollama ls -la /dev/dri/
docker exec ollama ls -la /dev/kfd

echo -e "\n3. Checking Jupyter GPU Access:"
docker exec jupyter-notebook ls -la /dev/dri/ 2>/dev/null || echo "GPU devices not accessible in Jupyter"

echo -e "\n4. Testing Ollama API:"
curl -s -X POST http://localhost:11434/api/tags | jq '.models[] | {name, size}' 2>/dev/null || echo "Ollama API not responding"

echo -e "\n5. Checking Container Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(ollama|jupyter|open-webui)"

echo -e "\n6. Testing Web UI Access:"
echo "Open WebUI: http://localhost:3001"
echo "Jupyter Lab: http://localhost:8889"
echo "Ollama API: http://localhost:11434"

echo -e "\n=== GPU Test Complete ===" 