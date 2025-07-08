#!/bin/bash

# Test script for BlueOS RealSense Depth Extension
# This script tests the extension locally before deployment

echo "🧪 Testing BlueOS RealSense Depth Extension"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

test_pass() {
    echo -e "${GREEN}✓ PASS${NC} $1"
}

test_fail() {
    echo -e "${RED}✗ FAIL${NC} $1"
}

test_warn() {
    echo -e "${YELLOW}⚠ WARN${NC} $1"
}

# Test 1: Check required files
echo "Testing required files..."
required_files=("manifest.json" "Dockerfile" "app.py" "requirements.txt" "templates/index.html")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        test_pass "File exists: $file"
    else
        test_fail "File missing: $file"
    fi
done

# Test 2: Validate manifest.json
echo -e "\nTesting manifest.json..."
if python3 -m json.tool manifest.json > /dev/null 2>&1; then
    test_pass "manifest.json is valid JSON"
else
    test_fail "manifest.json is invalid JSON"
fi

# Test 3: Check Docker
echo -e "\nTesting Docker..."
if docker --version > /dev/null 2>&1; then
    test_pass "Docker is available"
else
    test_fail "Docker is not available"
    exit 1
fi

# Test 4: Build Docker image
echo -e "\nBuilding Docker image..."
if docker-compose build > /dev/null 2>&1; then
    test_pass "Docker image builds successfully"
else
    test_fail "Docker image build failed"
    exit 1
fi

# Test 5: Start container
echo -e "\nStarting container..."
docker-compose up -d > /dev/null 2>&1
sleep 5

# Test 6: Check if container is running
if docker-compose ps | grep -q "Up"; then
    test_pass "Container is running"
else
    test_fail "Container failed to start"
    docker-compose logs
    exit 1
fi

# Test 7: Test API endpoints
echo -e "\nTesting API endpoints..."
if curl -s http://localhost:8080/api/status > /dev/null; then
    test_pass "API status endpoint accessible"
else
    test_fail "API status endpoint not accessible"
fi

if curl -s http://localhost:8080/ > /dev/null; then
    test_pass "Web interface accessible"
else
    test_fail "Web interface not accessible"
fi

# Test 8: Check camera detection (if available)
echo -e "\nChecking camera detection..."
if lsusb | grep -q "Intel"; then
    test_pass "Intel RealSense camera detected"
else
    test_warn "No Intel RealSense camera detected (OK for CI/CD)"
fi

# Test 9: Test depth data endpoint
echo -e "\nTesting depth data endpoint..."
depth_response=$(curl -s http://localhost:8080/api/depth_data)
if echo "$depth_response" | grep -q "timestamp"; then
    test_pass "Depth data endpoint returns data"
else
    test_warn "Depth data endpoint may not have camera data"
fi

# Cleanup
echo -e "\nCleaning up..."
docker-compose down > /dev/null 2>&1
test_pass "Test cleanup completed"

echo -e "\n🎉 Testing completed!"
echo "If all tests passed, your extension is ready for deployment."
