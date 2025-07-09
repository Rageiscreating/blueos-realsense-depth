FROM python:3.9-slim

# BlueOS Extension Metadata
LABEL permissions='\
{\
    "ExposedPorts": {\
        "8080/tcp": {}\
    },\
    "HostConfig": {\
        "Privileged": true,\
        "PortBindings": {\
            "8080/tcp": [\
                {\
                    "HostPort": ""\
                }\
            ]\
        },\
        "Devices": [\
            {\
                "PathOnHost": "/dev/bus/usb",\
                "PathInContainer": "/dev/bus/usb",\
                "CgroupPermissions": "rwm"\
            }\
        ],\
        "Binds": [\
            "/run/udev:/run/udev:ro"\
        ]\
    }\
}'

LABEL authors='[\
    {\
        "name": "RealSense Extension Developer",\
        "email": "developer@example.com"\
    }\
]'

LABEL company='{\
    "about": "Intel RealSense depth camera integration for BlueOS",\
    "name": "Custom Extensions",\
    "email": "support@example.com"\
}'

LABEL readme="https://raw.githubusercontent.com/Rageiscreating/blueos-realsense-depth/main/README.md"

LABEL links='{\
    "website": "https://github.com/Rageiscreating/blueos-realsense-depth",\
    "github": "https://github.com/Rageiscreating/blueos-realsense-depth",\
    "support": "https://github.com/Rageiscreating/blueos-realsense-depth/issues"\
}'

LABEL requirements='{\
    "kernel_modules": ["uvcvideo"]\
}'

LABEL type="device-integration"
LABEL tags='["camera", "depth", "realsense", "sensors", "positioning"]'
LABEL version="1.0.0"

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

# Add BlueOS requirements
LABEL requirements="core >= 1.1"

# Run the application
ENTRYPOINT cd /app && python app.py
