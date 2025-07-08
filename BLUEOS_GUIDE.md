# BlueOS Extension Development Guide

## Overview

This guide covers the development and deployment of the RealSense Depth Camera extension for BlueOS.

## BlueOS Extension Structure

A BlueOS extension requires these key files:

### 1. manifest.json
```json
{
  "name": "RealSense Depth Camera",
  "description": "RealSense depth camera extension for BlueOS",
  "icon": "mdi-camera-plus-outline",
  "company": "Custom",
  "version": "1.0.0",
  "new_page": true,
  "webpage": "/",
  "api": "/api/",
  "permissions": {
    "ExposedPorts": {
      "8080/tcp": {}
    },
    "HostConfig": {
      "Privileged": true,
      "NetworkMode": "host"
    }
  }
}
```

### 2. Dockerfile
The Dockerfile must:
- Use a Linux base image
- Install RealSense SDK
- Set up the web application
- Expose necessary ports

### 3. Docker Compose (for testing)
```yaml
services:
  realsense_depth:
    build: .
    privileged: true
    network_mode: host
    devices:
      - /dev/bus/usb:/dev/bus/usb
    volumes:
      - /dev:/dev
      - /var/run/udev:/var/run/udev:ro
```

## Development Workflow

### 1. Local Development
```bash
# Build and test locally
docker-compose build
docker-compose up -d

# Test endpoints
curl http://localhost:8080/api/status
curl http://localhost:8080/api/depth_data
```

### 2. GitHub Actions CI/CD
The `.github/workflows/build.yml` file:
- Builds the Docker image
- Pushes to GitHub Container Registry
- Tags releases appropriately

### 3. BlueOS Integration
When installed in BlueOS:
- Extension runs with proper permissions
- Accessible via BlueOS web interface
- Hardware access for USB cameras

## Hardware Requirements

### Supported Cameras
- Intel RealSense D415
- Intel RealSense D435
- Intel RealSense D455
- Any D400 series camera

### System Requirements
- BlueOS compatible hardware
- USB 3.0 port
- Minimum 1GB RAM
- ARM64 or x86_64 architecture

## API Documentation

### Endpoints

#### GET /api/status
Returns camera connection status
```json
{
  "camera_connected": true,
  "camera_info": {
    "name": "Intel RealSense D415",
    "serial": "123456789",
    "firmware": "5.12.7.100"
  }
}
```

#### GET /api/depth_data
Returns latest depth measurements
```json
{
  "timestamp": "2025-01-15T10:30:00Z",
  "center_distance": 1.45,
  "min_distance": 0.85,
  "max_distance": 3.20,
  "frame_width": 640,
  "frame_height": 480
}
```

#### GET /api/video_feed
Returns MJPEG video stream of color camera

#### GET /api/depth_feed
Returns MJPEG video stream of depth visualization

## Troubleshooting

### Common Issues

1. **Camera not detected**
   - Check USB connection
   - Verify camera is not in use by another application
   - Check permissions in manifest.json

2. **Permission denied**
   - Ensure privileged mode is enabled
   - Check device mounts in docker-compose.yml

3. **Web interface not accessible**
   - Check port forwarding (8080)
   - Verify network_mode: host

4. **Build failures**
   - Check Docker Desktop is running
   - Verify all dependencies in requirements.txt

### Debug Commands

```bash
# Check camera detection
lsusb | grep Intel

# Check container logs
docker-compose logs -f

# Test API endpoints
curl -v http://localhost:8080/api/status

# Check container permissions
docker exec -it container_name ls -la /dev/bus/usb
```

## Deployment Checklist

- [ ] manifest.json configured correctly
- [ ] Dockerfile builds successfully
- [ ] GitHub Actions workflow working
- [ ] Extension tested locally
- [ ] API endpoints functional
- [ ] Web interface accessible
- [ ] Camera detection working
- [ ] README.md updated
- [ ] Repository pushed to GitHub
- [ ] Release tag created

## Best Practices

1. **Error Handling**: Always handle camera disconnection gracefully
2. **Resource Management**: Properly close camera connections
3. **Security**: Use minimal required permissions
4. **Performance**: Optimize video streaming for bandwidth
5. **Logging**: Include comprehensive logging for debugging
6. **Testing**: Test on actual BlueOS hardware before deployment

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues and questions:
- Check the troubleshooting section
- Review BlueOS documentation
- Open an issue on GitHub
- Contact the BlueOS community
