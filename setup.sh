#!/bin/bash
# Setup script for RealSense Depth Camera BlueOS Extension

echo "🎥 RealSense Depth Camera - BlueOS Extension Setup"
echo "================================================="

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

echo "✅ Docker and Docker Compose are installed"

# Check if RealSense camera is connected
echo "🔍 Checking for RealSense camera..."
if lsusb | grep -q "Intel Corp"; then
    echo "✅ Intel RealSense camera detected"
else
    echo "⚠️  No Intel RealSense camera detected. Please connect your camera."
fi

# Build and start the extension
echo "🏗️  Building Docker image..."
docker-compose build

echo "🚀 Starting RealSense Depth Camera extension..."
docker-compose up -d

echo "✅ Extension started successfully!"
echo "🌐 Access the web interface at: http://localhost:8080"
echo "📊 API documentation at: http://localhost:8080/api/"

# Check if the service is running
sleep 5
if docker-compose ps | grep -q "Up"; then
    echo "✅ Extension is running"
else
    echo "❌ Extension failed to start. Check logs with: docker-compose logs"
fi

echo "🎉 Setup complete!"
