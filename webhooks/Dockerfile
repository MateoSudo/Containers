FROM python:3.11-slim

# Install git for repository operations
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy webhook scripts
COPY *.py ./

# Create directory for logs
RUN mkdir -p /app/logs

# Expose ports
EXPOSE 5000 5001

# Default command (can be overridden)
CMD ["python", "github-to-gitea.py"] 