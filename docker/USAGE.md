# Agent Zero Docker Setup

This directory contains the simplified Docker setup for Agent Zero.

## Files
- `Dockerfile` - Unified Dockerfile with all dependencies and Agent Zero installation
- `docker-compose.yml` - Docker Compose configuration with watch support
- `base_fs/` - Base system files
- `run_fs/` - Runtime system files

## Usage

### Option 1: Using docker-manager.sh (Recommended)
```bash
# From the docker directory
./docker-manager.sh
```

### Option 2: Using Docker Compose
```bash
# From the docker directory
docker compose up --build

# With watch mode (for development)
docker compose watch
```

### Option 3: Manual Docker build
```bash
# From the docker directory
docker build -t agent-zero --build-arg BRANCH=main .
docker run -d --name agent-zero -p 8080:80 -v "$(pwd)/../:/a0" -e WATCH=1 agent-zero
```

## Configuration
- **Port**: Container runs on port 80, mapped to host port 8080
- **Volume**: Your local agent-zero directory is mounted to `/a0` in the container
- **Watch**: Enabled by default for live reload during development
- **Branch**: Defaults to `main`, can be overridden with BRANCH environment variable

## Access
Once running, access Agent Zero at: http://localhost:8080
