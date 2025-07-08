# BlueOS RealSense Depth Extension Deployment Script (Windows PowerShell)
# This script helps deploy the extension to GitHub and test it locally

Write-Host "🚀 BlueOS RealSense Depth Extension Deployment" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

function Write-Status {
    param($Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param($Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param($Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Step {
    param($Message)
    Write-Host "[STEP] $Message" -ForegroundColor Blue
}

# Check if git is initialized
if (-not (Test-Path ".git")) {
    Write-Step "Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial commit: BlueOS RealSense Depth Extension"
    Write-Status "Git repository initialized"
} else {
    Write-Status "Git repository already exists"
}

# Check for GitHub remote
try {
    $remoteUrl = git remote get-url origin 2>$null
    if (-not $remoteUrl) {
        throw "No remote found"
    }
    Write-Status "GitHub remote found: $remoteUrl"
} catch {
    Write-Warning "No GitHub remote found!"
    Write-Host "Please add your GitHub repository remote:"
    Write-Host "git remote add origin https://github.com/yourusername/blueos-realsense-depth.git"
    Write-Host ""
    $repoUrl = Read-Host "Enter your GitHub repository URL"
    if ($repoUrl) {
        git remote add origin $repoUrl
        Write-Status "GitHub remote added: $repoUrl"
    }
}

# Build and test locally
Write-Step "Building Docker image locally..."
try {
    docker-compose build
    Write-Status "Docker image built successfully"
} catch {
    Write-Error "Docker build failed"
    Write-Host "Make sure Docker Desktop is running and try again"
    exit 1
}

# Test Docker Desktop status
Write-Step "Checking Docker Desktop status..."
try {
    docker info | Out-Null
    Write-Status "Docker Desktop is running"
} catch {
    Write-Warning "Docker Desktop may not be running or accessible"
}

# Push to GitHub
Write-Step "Pushing to GitHub..."
$pushChoice = Read-Host "Push to GitHub now? (y/n)"
if ($pushChoice -match "^[Yy]$") {
    try {
        git push -u origin main
        Write-Status "Code pushed to GitHub"
        
        # Create release tag
        $tagChoice = Read-Host "Create a release tag? (y/n)"
        if ($tagChoice -match "^[Yy]$") {
            $versionTag = Read-Host "Enter version tag (e.g., v1.0.0)"
            git tag -a $versionTag -m "Release $versionTag"
            git push origin $versionTag
            Write-Status "Release tag $versionTag created and pushed"
        }
    } catch {
        Write-Error "Failed to push to GitHub. Check your credentials and try again."
    }
}

Write-Host ""
Write-Status "Deployment complete!"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Wait for GitHub Actions to build the Docker image"
Write-Host "2. Install in BlueOS Extensions Manager using your repository URL"
Write-Host "3. Access the web interface at http://blueos.local:8080"
Write-Host ""
Write-Host "Repository URL for BlueOS Extension Manager:"
try {
    $repoUrl = git remote get-url origin
    Write-Host $repoUrl -ForegroundColor Cyan
} catch {
    Write-Host "Run: git remote get-url origin" -ForegroundColor Yellow
}
