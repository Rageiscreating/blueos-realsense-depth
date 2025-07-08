# 🚀 BlueOS Extension Setup Guide - CORRECTED

## ⚠️ Important Update

After checking the [official BlueOS documentation](https://blueos.cloud/docs/stable/development/extensions/), I've corrected our extension to follow the proper BlueOS extension format:

### Key Changes Made:
1. **Removed manifest.json** - BlueOS uses Docker labels instead
2. **Added proper Docker labels** to Dockerfile with permissions and metadata
3. **Added register_service endpoint** to app.py for BlueOS integration
4. **Updated to official BlueOS extension format**

## Step 1: Configure Git (One-time setup)

Replace with your actual details:

```powershell
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

## Step 2: Create GitHub Repository

1. Go to [GitHub.com](https://github.com) and sign in
2. Click **"+"** → **"New repository"**
3. Repository details:
   - **Name**: `blueos-realsense-depth`
   - **Description**: `BlueOS extension for Intel RealSense depth cameras`
   - **Public** (required for BlueOS)
   - **DON'T** check "Initialize with README"
4. Click **"Create repository"**
5. **Copy the repository URL**

## Step 3: Create Docker Hub Repository

1. Go to [Docker Hub](https://hub.docker.com) and sign in
2. Click **"Create Repository"**
3. Repository details:
   - **Name**: `blueos-realsense-depth`
   - **Description**: `BlueOS extension for Intel RealSense depth cameras`
   - **Public** (required for BlueOS)
4. Click **"Create"**

## Step 4: Set Up GitHub Actions

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Add these **Repository secrets**:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_PASSWORD`: Your Docker Hub [access token](https://hub.docker.com/settings/security)

## Step 5: Push Code to GitHub

```powershell
# 1. Commit your code
git add .
git commit -m "Initial commit: BlueOS RealSense Extension"

# 2. Add your GitHub repository as remote
git remote add origin https://github.com/yourusername/blueos-realsense-depth.git

# 3. Set main branch and push
git branch -M main
git push -u origin main

# 4. Create a release tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

## Step 6: Wait for Docker Build

1. Go to your GitHub repository
2. Click **"Actions"** tab
3. Wait for the workflow to complete (green checkmark)
4. Check Docker Hub - your image should appear

## Step 7: Submit to BlueOS Extensions Repository

1. Go to [BlueOS Extensions Repository](https://github.com/bluerobotics/BlueOS-Extensions-Repository)
2. Fork the repository
3. Create a new folder: `extensions/yourusername-realsense-depth/`
4. Add these files:
   - `metadata.json`:
   ```json
   {
       "name": "RealSense Depth Camera",
       "docker": "yourusername/blueos-realsense-depth",
       "maintainer": "yourusername",
       "description": "Intel RealSense depth camera integration with web interface"
   }
   ```
   - `icon.png` (64x64 pixel icon)
5. Submit a Pull Request

## Step 8: Alternative - Manual Installation

If you don't want to wait for PR approval, you can install manually:

1. **Access BlueOS**: Go to `http://blueos.local`
2. **Extensions Manager**: Go to Extensions → Extensions Manager
3. **Installed tab**: Click "Installed"
4. **Add Extension**: Click the "+" button
5. **Fill in details**:
   - **Extension Identifier**: `yourusername.realsense-depth`
   - **Extension Name**: `RealSense Depth Camera`
   - **Docker image**: `yourusername/blueos-realsense-depth`
   - **Docker tag**: `latest` or `v1.0.0`
   - **Custom settings**: Leave empty (permissions are in Docker labels)

## Step 9: Access Your Extension

Once installed:
- **Web Interface**: `http://blueos.local:8080`
- **BlueOS Sidebar**: Look for "RealSense Depth Camera"
- **API**: `http://blueos.local:8080/api/`

## 🔧 Testing Commands

```powershell
# Build and test locally
docker build -t yourusername/blueos-realsense-depth .
docker run -p 8080:8080 --privileged -v /dev:/dev yourusername/blueos-realsense-depth

# Test the register_service endpoint
curl http://localhost:8080/register_service

# Test API
curl http://localhost:8080/api/status
```

## 📝 Important Notes

- **Repository must be public** for BlueOS to access it
- **Docker image must be on Docker Hub** (not GitHub Container Registry)
- **Use Docker labels** for permissions (not separate manifest file)
- **Include register_service endpoint** in your web app
- **Follow SemVer** for version tags (v1.0.0, v1.0.1, etc.)

## 🚨 Troubleshooting

### "Invalid manifest URL" Error
- This happens because BlueOS expects Docker labels, not manifest.json
- Our updated Dockerfile now includes proper labels

### Extension Not Appearing
- Check that Docker image is public on Docker Hub
- Verify GitHub Actions completed successfully
- Ensure all Docker labels are properly formatted

### Camera Not Detected
- Ensure RealSense camera is connected via USB 3.0
- Check that privileged mode is enabled
- Verify udev rules are accessible

## ✅ Success Checklist

- [ ] GitHub repository created and public
- [ ] Docker Hub repository created and public
- [ ] GitHub Actions secrets configured
- [ ] Code pushed to GitHub
- [ ] Docker image built successfully
- [ ] Extension installed in BlueOS
- [ ] Web interface accessible
- [ ] Camera detected and working

**You're ready to deploy! 🤿**
