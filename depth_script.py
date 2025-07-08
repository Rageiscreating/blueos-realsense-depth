#!/usr/bin/env python3
"""
RealSense Depth Camera Test Script
Simple script for testing RealSense camera functionality
"""

import pyrealsense2 as rs
import time
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    """Main function for testing RealSense camera"""
    
    logger.info("Starting RealSense Depth Camera Test")
    
    # Create pipeline and config
    pipeline = rs.pipeline()
    config = rs.config()
    
    try:
        # Check for connected devices
        ctx = rs.context()
        devices = ctx.query_devices()
        
        if len(devices) == 0:
            logger.error("No RealSense devices found!")
            logger.info("Available USB devices:")
            import subprocess
            try:
                result = subprocess.run(['lsusb'], capture_output=True, text=True)
                logger.info(result.stdout)
            except:
                logger.info("Could not list USB devices")
            return
        
        logger.info(f"Found {len(devices)} RealSense device(s)")
        for i, device in enumerate(devices):
            logger.info(f"Device {i}: {device.get_info(rs.camera_info.name)}")
        
        # Configure streams
        config.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, 30)
        
        # Start streaming
        logger.info("Starting pipeline...")
        profile = pipeline.start(config)
        
        # Get device info
        device = profile.get_device()
        logger.info(f"Using device: {device.get_info(rs.camera_info.name)}")
        logger.info(f"Serial number: {device.get_info(rs.camera_info.serial_number)}")
        logger.info(f"Firmware version: {device.get_info(rs.camera_info.firmware_version)}")
        
        logger.info("Streaming depth data...")
        logger.info("Press Ctrl+C to stop")
        
        frame_count = 0
        start_time = time.time()
        
        while True:
            try:
                # Wait for frames
                frames = pipeline.wait_for_frames(timeout_ms=5000)
                depth_frame = frames.get_depth_frame()
                
                if not depth_frame:
                    logger.warning("No depth frame received")
                    continue
                
                # Get frame dimensions
                width = depth_frame.get_width()
                height = depth_frame.get_height()
                
                # Get distance at center
                center_x, center_y = width // 2, height // 2
                distance = depth_frame.get_distance(center_x, center_y)
                
                # Calculate FPS
                frame_count += 1
                elapsed = time.time() - start_time
                fps = frame_count / elapsed if elapsed > 0 else 0
                
                # Log data
                logger.info(f"Frame {frame_count:4d} | Distance: {distance:.3f}m | FPS: {fps:.1f} | Resolution: {width}x{height}")
                
                time.sleep(1)  # Update every second
                
            except RuntimeError as e:
                logger.error(f"Runtime error: {e}")
                time.sleep(1)
                continue
            except Exception as e:
                logger.error(f"Unexpected error: {e}")
                break
                
    except Exception as e:
        logger.error(f"Failed to initialize camera: {e}")
        return
    
    except KeyboardInterrupt:
        logger.info("Stopping...")
    
    finally:
        try:
            pipeline.stop()
            logger.info("Pipeline stopped")
        except:
            pass

if __name__ == "__main__":
    main()
