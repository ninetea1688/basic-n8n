#!/bin/bash

# Wait for Ollama service to be ready
echo "Waiting for Ollama service to start..."
while ! curl -s http://localhost:11434/api/version > /dev/null; do
    echo "Ollama not ready yet, waiting 5 seconds..."
    sleep 5
done

echo "Ollama service is ready!"

# Pull Llama 3.2 model
echo "Downloading Llama 3.2 model..."
curl -X POST http://localhost:11434/api/pull \
  -H "Content-Type: application/json" \
  -d '{"name": "llama3.2"}'

echo "\nLlama 3.2 model download initiated!"
echo "You can check the download progress with: docker exec n8n-ollama ollama list"
echo "Or visit: http://localhost:11434 to verify the service is running"