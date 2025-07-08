FROM python:3.9-slim

# Install system dependencies including RealSense SDK
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    libgl1-mesa-glx \
    libusb-1.0-0-dev \
    libssl-dev \
    pkg-config \
    libudev-dev \
    udev \
    usbutils \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install \
    pyrealsense2 \
    flask \
    flask-cors \
    opencv-python \
    numpy \
    websockets \
    asyncio

# Create app directory
WORKDIR /app

# Copy application files
COPY . /app/

# Create web interface directory
RUN mkdir -p /app/static /app/templates

# Expose port
EXPOSE 8080

# Run the application
CMD ["python", "app.py"]
