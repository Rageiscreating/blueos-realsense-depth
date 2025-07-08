#!/bin/bash

# BlueOS RealSense Depth Extension Deployment Script
# This script helps deploy the extension to GitHub and test it locally

set -e

echo "🚀 BlueOS RealSense Depth Extension Deployment"
echo "==============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if git is initialized
if [ ! -d ".git" ]; then
    print_step "Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial commit: BlueOS RealSense Depth Extension"
    print_status "Git repository initialized"
else
    print_status "Git repository already exists"
fi

# Check for GitHub remote
if ! git remote get-url origin >/dev/null 2>&1; then
    print_warning "No GitHub remote found!"
    echo "Please add your GitHub repository remote:"
    echo "git remote add origin https://github.com/yourusername/blueos-realsense-depth.git"
    echo ""
    read -p "Enter your GitHub repository URL: " REPO_URL
    if [ ! -z "$REPO_URL" ]; then
        git remote add origin "$REPO_URL"
        print_status "GitHub remote added: $REPO_URL"
    fi
fi

# Build and test locally
print_step "Building Docker image locally..."
if docker-compose build; then
    print_status "Docker image built successfully"
else
    print_error "Docker build failed"
    exit 1
fi

# Test camera detection (if running on Linux with camera)
print_step "Testing camera detection..."
if lsusb | grep -q "Intel"; then
    print_status "Intel RealSense camera detected"
else
    print_warning "No Intel RealSense camera detected (this is OK for deployment)"
fi

# Push to GitHub
print_step "Pushing to GitHub..."
read -p "Push to GitHub now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git push -u origin main
    print_status "Code pushed to GitHub"
    
    # Create release tag
    read -p "Create a release tag? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter version tag (e.g., v1.0.0): " VERSION_TAG
        git tag -a "$VERSION_TAG" -m "Release $VERSION_TAG"
        git push origin "$VERSION_TAG"
        print_status "Release tag $VERSION_TAG created and pushed"
    fi
fi

echo ""
print_status "Deployment complete!"
echo ""
echo "Next steps:"
echo "1. Wait for GitHub Actions to build the Docker image"
echo "2. Install in BlueOS Extensions Manager using your repository URL"
echo "3. Access the web interface at http://blueos.local:8080"
echo ""
echo "Repository URL for BlueOS Extension Manager:"
echo "$(git remote get-url origin)"
