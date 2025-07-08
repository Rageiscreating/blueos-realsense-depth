#!/usr/bin/env python3
"""
RealSense Depth Camera BlueOS Extension
Provides web interface for viewing depth data and camera feed
"""

import asyncio
import json
import logging
import time
from flask import Flask, render_template, jsonify, Response
from flask_cors import CORS
import pyrealsense2 as rs
import numpy as np
import cv2
import threading
from threading import Lock

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# BlueOS Extension Service Registration
@app.route('/register_service', methods=['GET'])
def register_service():
    """Register this extension with BlueOS"""
    return jsonify({
        "name": "RealSense Depth Camera",
        "description": "Intel RealSense depth camera integration with live video and depth data",
        "icon": "mdi-camera-plus-outline",
        "company": "Custom Extensions",
        "version": "1.0.0",
        "new_page": True,
        "webpage": "/",
        "api": "/api/"
    })

class RealSenseManager:
    def __init__(self):
        self.pipeline = None
        self.config = None
        self.device_connected = False
        self.latest_depth_frame = None
        self.latest_color_frame = None
        self.depth_data = {
            'center_distance': 0.0,
            'min_distance': 0.0,
            'max_distance': 0.0,
            'timestamp': time.time()
        }
        self.lock = Lock()
        self.running = False
        
    def initialize_camera(self):
        """Initialize RealSense camera"""
        try:
            # Create a context to manage devices
            ctx = rs.context()
            devices = ctx.query_devices()
            
            if len(devices) == 0:
                logger.error("No RealSense devices connected")
                return False
                
            logger.info(f"Found {len(devices)} RealSense device(s)")
            
            # Configure streams
            self.pipeline = rs.pipeline()
            self.config = rs.config()
            
            # Enable depth and color streams
            self.config.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, 30)
            self.config.enable_stream(rs.stream.color, 640, 480, rs.format.bgr8, 30)
            
            # Start streaming
            profile = self.pipeline.start(self.config)
            
            # Get device product line for setting a supporting resolution
            device = profile.get_device()
            logger.info(f"Device: {device.get_info(rs.camera_info.name)}")
            
            self.device_connected = True
            logger.info("RealSense camera initialized successfully")
            return True
            
        except Exception as e:
            logger.error(f"Failed to initialize camera: {e}")
            self.device_connected = False
            return False
    
    def get_frames(self):
        """Get latest frames from camera"""
        if not self.device_connected or not self.pipeline:
            return None, None
            
        try:
            frames = self.pipeline.wait_for_frames(timeout_ms=1000)
            depth_frame = frames.get_depth_frame()
            color_frame = frames.get_color_frame()
            
            if not depth_frame or not color_frame:
                return None, None
                
            return depth_frame, color_frame
            
        except Exception as e:
            logger.error(f"Error getting frames: {e}")
            return None, None
    
    def process_depth_data(self, depth_frame):
        """Process depth frame to extract useful data"""
        if not depth_frame:
            return
            
        try:
            # Convert to numpy array
            depth_image = np.asanyarray(depth_frame.get_data())
            height, width = depth_image.shape
            
            # Get distance at center
            center_distance = depth_frame.get_distance(width // 2, height // 2)
            
            # Get min/max distances (exclude zeros)
            valid_depths = depth_image[depth_image > 0]
            min_distance = np.min(valid_depths) / 1000.0 if len(valid_depths) > 0 else 0.0
            max_distance = np.max(valid_depths) / 1000.0 if len(valid_depths) > 0 else 0.0
            
            with self.lock:
                self.depth_data = {
                    'center_distance': center_distance,
                    'min_distance': min_distance,
                    'max_distance': max_distance,
                    'timestamp': time.time(),
                    'width': width,
                    'height': height
                }
                
        except Exception as e:
            logger.error(f"Error processing depth data: {e}")
    
    def start_streaming(self):
        """Start continuous streaming"""
        self.running = True
        
        def stream_loop():
            while self.running:
                try:
                    depth_frame, color_frame = self.get_frames()
                    
                    if depth_frame and color_frame:
                        with self.lock:
                            self.latest_depth_frame = depth_frame
                            self.latest_color_frame = color_frame
                        
                        self.process_depth_data(depth_frame)
                    
                    time.sleep(0.033)  # ~30 FPS
                    
                except Exception as e:
                    logger.error(f"Streaming error: {e}")
                    time.sleep(1)
        
        thread = threading.Thread(target=stream_loop, daemon=True)
        thread.start()
        logger.info("Started streaming thread")
    
    def stop_streaming(self):
        """Stop streaming"""
        self.running = False
        if self.pipeline:
            self.pipeline.stop()
            logger.info("Stopped streaming")
    
    def get_color_frame_as_jpeg(self):
        """Convert color frame to JPEG for web streaming"""
        with self.lock:
            if self.latest_color_frame is None:
                return None
                
            try:
                # Convert to numpy array
                color_image = np.asanyarray(self.latest_color_frame.get_data())
                
                # Encode as JPEG
                ret, buffer = cv2.imencode('.jpg', color_image)
                if ret:
                    return buffer.tobytes()
                    
            except Exception as e:
                logger.error(f"Error encoding frame: {e}")
                
        return None
    
    def get_depth_frame_as_jpeg(self):
        """Convert depth frame to colorized JPEG for web streaming"""
        with self.lock:
            if self.latest_depth_frame is None:
                return None
                
            try:
                # Convert to numpy array
                depth_image = np.asanyarray(self.latest_depth_frame.get_data())
                
                # Apply colormap
                depth_colormap = cv2.applyColorMap(
                    cv2.convertScaleAbs(depth_image, alpha=0.03), 
                    cv2.COLORMAP_JET
                )
                
                # Encode as JPEG
                ret, buffer = cv2.imencode('.jpg', depth_colormap)
                if ret:
                    return buffer.tobytes()
                    
            except Exception as e:
                logger.error(f"Error encoding depth frame: {e}")
                
        return None

# Global camera manager
camera_manager = RealSenseManager()

@app.route('/')
def index():
    """Main page"""
    return render_template('index.html')

@app.route('/api/status')
def get_status():
    """Get camera status"""
    return jsonify({
        'connected': camera_manager.device_connected,
        'streaming': camera_manager.running
    })

@app.route('/api/depth_data')
def get_depth_data():
    """Get latest depth data"""
    with camera_manager.lock:
        return jsonify(camera_manager.depth_data)

@app.route('/api/video_feed')
def video_feed():
    """Video streaming route"""
    def generate():
        while True:
            frame = camera_manager.get_color_frame_as_jpeg()
            if frame:
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
            else:
                time.sleep(0.1)
    
    return Response(generate(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/api/depth_feed')
def depth_feed():
    """Depth video streaming route"""
    def generate():
        while True:
            frame = camera_manager.get_depth_frame_as_jpeg()
            if frame:
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
            else:
                time.sleep(0.1)
    
    return Response(generate(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

def main():
    """Main function"""
    logger.info("Starting RealSense Depth Camera Extension")
    
    # Initialize camera
    if camera_manager.initialize_camera():
        camera_manager.start_streaming()
        logger.info("Camera initialized and streaming started")
    else:
        logger.warning("Camera initialization failed - running in demo mode")
    
    try:
        # Run Flask app
        app.run(host='0.0.0.0', port=8080, debug=False, threaded=True)
    except KeyboardInterrupt:
        logger.info("Shutting down...")
    finally:
        camera_manager.stop_streaming()

if __name__ == '__main__':
    main()
