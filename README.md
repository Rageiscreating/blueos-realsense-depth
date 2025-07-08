# RealSense Depth Camera - BlueOS Extension

A comprehensive BlueOS extension for Intel RealSense depth cameras, providing real-time depth sensing capabilities with a modern web interface for underwater robotics applications.

## Features

- 🎥 **Real-time Video Streaming**: Live color camera feed
- 📏 **Depth Visualization**: Colorized depth map display  
- 📊 **Depth Analytics**: Center, minimum, and maximum distance measurements
- 🌐 **Web Interface**: Modern, responsive web GUI accessible from any device
- 🔧 **BlueOS Integration**: Seamless integration with BlueOS ecosystem
- ⚡ **Real-time Updates**: Live data updates at 30 FPS

## Supported Hardware

- Intel RealSense D400 series cameras
- Intel RealSense D415 (tested)
- Intel RealSense D435
- Intel RealSense D455

## Installation

### Option 1: Install from BlueOS Extension Manager

1. Open BlueOS web interface (usually at `http://blueos.local`)
2. Navigate to **Extensions** → **Extensions Manager**
3. Click **Add Extension** and enter the repository URL:
   ```
   https://github.com/yourusername/blueos-realsense-depth
   ```
4. Click **Install** and wait for the extension to be deployed

### Option 2: Manual Docker Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/blueos-realsense-depth.git
   cd blueos-realsense-depth
   ```

2. Build and run with Docker Compose:
   ```bash
   docker-compose up -d
   ```

3. Access the web interface at `http://localhost:8080`

## BlueOS Deployment

### Step 1: GitHub Repository Setup

1. **Create a new repository** on GitHub (e.g., `blueos-realsense-depth`)
2. **Push this code** to your repository:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/yourusername/blueos-realsense-depth.git
   git push -u origin main
   ```

### Step 2: GitHub Actions & Container Registry

1. **Enable GitHub Actions** in your repository settings
2. **Enable GitHub Container Registry** (ghcr.io) in your repository settings
3. **Create a release** to trigger the Docker image build:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

### Step 3: Install in BlueOS

1. **Access BlueOS** web interface (usually at `http://blueos.local`)
2. **Navigate to Extensions** → **Extensions Manager**
3. **Click "Add Extension"** and enter:
   ```
   https://github.com/yourusername/blueos-realsense-depth
   ```
4. **Click Install** and wait for deployment

### Step 4: Access the Extension

Once installed, the extension will be available:
- **Web Interface**: `http://blueos.local:8080`
- **Extension Tab**: Available in BlueOS sidebar
- **API Endpoints**: `http://blueos.local:8080/api/`

### Extension Registry

The extension is automatically built and published to GitHub Container Registry (ghcr.io) via GitHub Actions when you:
- Push to main branch
- Create a new release/tag

**Docker Image**: `ghcr.io/yourusername/blueos-realsense-depth:latest`

## Configuration

### Hardware Setup

1. Connect your Intel RealSense camera to the companion computer via USB 3.0
2. Ensure the camera is properly mounted and has clear field of view
3. Verify camera detection with `lsusb` command

### Software Configuration

The extension automatically detects connected RealSense cameras. No additional configuration required.

## Usage

### Web Interface

1. Open your web browser
2. Navigate to `http://[companion-computer-ip]:8080`
3. View live camera feed and depth data
4. Monitor real-time depth measurements

### API Endpoints

The extension provides RESTful API endpoints:

- `GET /api/status` - Camera connection status
- `GET /api/depth_data` - Latest depth measurements (JSON)
- `GET /api/video_feed` - Live color video stream (MJPEG)
- `GET /api/depth_feed` - Live depth visualization stream (MJPEG)

### Example API Response

```json
{
  "center_distance": 1.234,
  "min_distance": 0.456,
  "max_distance": 5.678,
  "timestamp": 1625097600.123,
  "width": 640,
  "height": 480
}
```

## Integration with ROV Systems

### ArduSub Integration

The depth data can be integrated with ArduSub for:
- Obstacle avoidance
- Precision maneuvers near structures
- Automated depth-based navigation
- Object tracking and inspection

### MAVLink Integration

Future versions will include MAVLink messaging for direct integration with flight controllers.

## Development

### Project Structure

```
blueos-realsense-depth/
├── manifest.json          # BlueOS extension manifest
├── docker-compose.yml     # Docker compose configuration
├── Dockerfile            # Docker image definition
├── app.py               # Main Flask application
├── templates/
│   └── index.html       # Web interface
├── static/              # Static assets (if needed)
└── README.md           # This file
```

### Building from Source

1. Install dependencies:
   ```bash
   pip install pyrealsense2 flask flask-cors opencv-python numpy
   ```

2. Run locally for development:
   ```bash
   python app.py
   ```

3. Access development interface at `http://localhost:8080`

### Testing

Test the extension with:
```bash
# Check camera detection
rs-enumerate-devices

# Test depth streaming
python depth_script.py
```

## Troubleshooting

### Camera Not Detected

1. Verify USB connection (USB 3.0 recommended)
2. Check camera drivers: `lsusb | grep Intel`
3. Restart the extension: `docker compose restart`
4. Check logs: `docker compose logs -f`

### Poor Performance

1. Ensure USB 3.0 connection
2. Reduce stream resolution in `app.py`
3. Check available bandwidth
4. Monitor CPU usage

### Permission Issues

1. Ensure container has privileged access
2. Check USB device permissions
3. Verify udev rules are loaded

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue on GitHub
- Join the BlueOS Discord community
- Check the BlueOS documentation

## Changelog

### v1.0.0
- Initial release
- Basic depth sensing functionality
- Web interface with live video feeds
- RESTful API for depth data
- BlueOS extension support

## Acknowledgments

- Intel RealSense team for the excellent SDK
- BlueRobotics for the BlueOS platform
- OpenCV community for image processing tools
