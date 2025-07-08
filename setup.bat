@echo off
REM Setup script for RealSense Depth Camera BlueOS Extension

echo 🎥 RealSense Depth Camera - BlueOS Extension Setup
echo =================================================

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker is not installed. Please install Docker Desktop first.
    pause
    exit /b 1
)

REM Check if Docker Compose is installed
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)

echo ✅ Docker and Docker Compose are installed

REM Build and start the extension
echo 🏗️  Building Docker image...
docker-compose build

echo 🚀 Starting RealSense Depth Camera extension...
docker-compose up -d

echo ✅ Extension started successfully!
echo 🌐 Access the web interface at: http://localhost:8080
echo 📊 API documentation at: http://localhost:8080/api/

REM Check if the service is running
timeout /t 5 /nobreak >nul
docker-compose ps | findstr "Up" >nul
if %errorlevel% equ 0 (
    echo ✅ Extension is running
) else (
    echo ❌ Extension failed to start. Check logs with: docker-compose logs
)

echo 🎉 Setup complete!
pause
