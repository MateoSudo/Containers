#!/bin/bash

# Load KFD module if available
echo "Attempting to load KFD module..."

# Try multiple methods to load KFD
if modprobe kfd 2>/dev/null; then
    echo "KFD module loaded successfully via modprobe"
elif insmod /lib/modules/$(uname -r)/kernel/drivers/gpu/drm/amd/amdkfd/amdkfd.ko 2>/dev/null; then
    echo "KFD module loaded successfully via insmod"
else
    echo "KFD module not available, trying to load from ROCm installation..."
    # Try to load from ROCm installation
    if [ -f "/opt/rocm-5.7.3/lib/modules/$(uname -r)/extra/amdkfd.ko" ]; then
        insmod /opt/rocm-5.7.3/lib/modules/$(uname -r)/extra/amdkfd.ko
        echo "KFD module loaded from ROCm installation"
    else
        echo "KFD module not available, continuing without GPU support"
    fi
fi

# Set up ROCm environment
export ROCR_VISIBLE_DEVICES=0
export HIP_VISIBLE_DEVICES=0
export HSA_OVERRIDE_GFX_VERSION=11.0.0
export PATH="/opt/rocm-5.7.3/bin:$PATH"
export LD_LIBRARY_PATH="/opt/rocm-5.7.3/lib:$LD_LIBRARY_PATH"

# Check if KFD device is accessible
if [ -r /dev/kfd ]; then
    echo "KFD device is accessible"
else
    echo "KFD device is not accessible"
fi

# Start Ollama with GPU support
echo "Starting Ollama with GPU support..."
exec /bin/ollama serve 