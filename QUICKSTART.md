# 🚀 BlueOS RealSense Extension - Quick Start

## What We Fixed

✅ **Removed manifest.json** - BlueOS uses Docker labels  
✅ **Added proper Docker labels** in Dockerfile  
✅ **Added register_service endpoint** to app.py  
✅ **Updated GitHub Actions** to push to Docker Hub  
✅ **Fixed BlueOS compatibility** based on official documentation  

## Quick Setup Steps

### 1. Create GitHub Repository
1. Go to GitHub.com → New Repository
2. Name: `blueos-realsense-depth`
3. Make it **Public**
4. Don't initialize with README

### 2. Create Docker Hub Repository  
1. Go to hub.docker.com → Create Repository
2. Name: `blueos-realsense-depth`
3. Make it **Public**

### 3. Configure GitHub Secrets
In your GitHub repo → Settings → Secrets and variables → Actions:
- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub [access token](https://hub.docker.com/settings/security)

### 4. Deploy Your Extension

```powershell
# Configure git (replace with your details)
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Add and commit changes
git add .
git commit -m "BlueOS RealSense Extension - Fixed for official compatibility"

# Add GitHub remote (replace yourusername)
git remote add origin https://github.com/yourusername/blueos-realsense-depth.git

# Push to GitHub
git branch -M main
git push -u origin main

# Create release tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 5. Install in BlueOS

**Method A: Manual Installation**
1. Go to `http://blueos.local`
2. Extensions → Extensions Manager → Installed → "+" button
3. Fill in:
   - Extension Identifier: `yourusername.realsense-depth`
   - Extension Name: `RealSense Depth Camera`
   - Docker image: `yourusername/blueos-realsense-depth`
   - Docker tag: `latest`
   - Custom settings: (leave empty)

**Method B: Add to BlueOS Store** (Optional)
1. Fork [BlueOS Extensions Repository](https://github.com/bluerobotics/BlueOS-Extensions-Repository)
2. Add your extension metadata
3. Submit Pull Request

### 6. Access Your Extension
- Web Interface: `http://blueos.local:8080`
- BlueOS Sidebar: "RealSense Depth Camera"
- API: `http://blueos.local:8080/api/`

## 🔧 Testing

```powershell
# Test locally (if you have Docker)
docker build -t test-realsense .
docker run -p 8080:8080 test-realsense

# Test endpoints
curl http://localhost:8080/register_service
curl http://localhost:8080/api/status
```

## 🎯 What's New

### register_service Endpoint
Your extension now properly registers with BlueOS:
```json
{
    "name": "RealSense Depth Camera",
    "description": "Intel RealSense depth camera integration",
    "icon": "mdi-camera-plus-outline",
    "company": "Custom Extensions",
    "version": "1.0.0",
    "new_page": true,
    "webpage": "/",
    "api": "/api/"
}
```

### Docker Labels
All permissions and metadata are now in the Dockerfile as labels:
- Privileged access for camera
- USB device mounting
- udev integration
- Port exposure

## 🚨 Important Notes

- **Repository must be PUBLIC** for BlueOS to access
- **Docker Hub** (not GitHub Container Registry) required
- **SemVer tags** required (v1.0.0, v1.0.1, etc.)
- **Docker labels** contain all metadata

## ✅ Success Indicators

You'll know it's working when:
- GitHub Actions completes successfully
- Docker image appears on Docker Hub
- Extension installs without "invalid manifest" error
- Web interface loads in BlueOS
- Camera detection works with RealSense hardware

**Ready to deploy! 🤿**
