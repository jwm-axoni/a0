# Agent Zero Docker Setup

This directory contains a streamlined Docker setup for Agent Zero that eliminates the dual-image approach and provides a unified container management experience.

## Quick Start

1. **Build and start Agent Zero:**
   ```bash
   ./docker-manager.sh build
   ./docker-manager.sh start
   ```

2. **Access the application:**
   - Web UI: http://localhost:8080
   - SSH: `ssh root@localhost -p 22`

## Docker Manager Script

The `docker-manager.sh` script provides a unified interface for managing Agent Zero containers:

### Commands

- `build` - Build Docker image (no cache)
- `build-cached` - Build Docker image (with cache)
- `start` - Start Agent Zero container
- `stop` - Stop Agent Zero container
- `restart` - Restart Agent Zero container
- `dev` - Start in development mode with live reload
- `logs` - Show container logs
- `shell` - Open shell in container
- `status` - Show container status
- `clean` - Clean up containers and images

### Environment Variables

- `BRANCH` - Git branch to use (default: main)
- `WEB_UI_PORT` - Web UI port (default: 8080)

### Examples

```bash
# Basic usage
./docker-manager.sh build
./docker-manager.sh start

# Development with live reload
./docker-manager.sh dev

# Custom branch and port
BRANCH=development WEB_UI_PORT=9090 ./docker-manager.sh start

# View logs
./docker-manager.sh logs

# Open shell for debugging
./docker-manager.sh shell

# Clean up everything
./docker-manager.sh clean
```

## Architecture Changes

### Before (Problems)
- Two separate Docker images (`agent-zero-base` and `agent-zero-run`)
- Multiple container creation paths
- Inconsistent naming schemes
- Potential for duplicate containers

### After (Solutions)
- Single unified Dockerfile
- Consistent container naming
- Automatic cleanup of conflicting containers
- Simplified build process
- Better development workflow

## Files Structure

```
docker/
├── Dockerfile              # Unified Dockerfile (combines base + run)
├── docker-compose.yml      # Docker Compose configuration
├── docker-manager.sh       # Unified management script
├── README.md              # This file
├── base/                  # Base system files (legacy)
│   ├── Dockerfile         # Legacy base Dockerfile
│   ├── build.txt          # Legacy build commands
│   └── fs/                # Base filesystem overlay
└── run/                   # Runtime files (legacy)
    ├── Dockerfile         # Legacy run Dockerfile
    ├── build.txt          # Legacy build commands
    ├── dev_docker.sh      # Legacy dev script
    ├── docker-compose.yml # Legacy compose file
    └── fs/                # Runtime filesystem overlay
```

## Migration from Legacy Setup

If you were using the old dual-image setup:

1. **Stop existing containers:**
   ```bash
   ./docker-manager.sh clean
   ```

2. **Remove old images:**
   ```bash
   docker rmi agent-zero-base:local agent-zero-run:local
   ```

3. **Use new unified setup:**
   ```bash
   ./docker-manager.sh build
   ./docker-manager.sh start
   ```

## Development Workflow

For active development with live code reloading:

```bash
# Start development mode
./docker-manager.sh dev

# This will:
# 1. Build the container if needed
# 2. Start the container with volume mounts
# 3. Enable Docker Compose watch for live reload
# 4. Automatically sync code changes to the container
```

## Troubleshooting

### Port Conflicts
If port 8080 is in use, specify a different port:
```bash
WEB_UI_PORT=9090 ./docker-manager.sh start
```

### Container Conflicts
The manager script automatically cleans up conflicting containers, but you can manually clean up:
```bash
./docker-manager.sh clean
```

### Build Issues
For a completely fresh build without cache:
```bash
./docker-manager.sh clean
./docker-manager.sh build
```

### Debugging
To inspect the container:
```bash
./docker-manager.sh shell
./docker-manager.sh logs
./docker-manager.sh status
```

## Legacy Support

The original `base/` and `run/` directories are preserved for compatibility but are no longer used by the unified setup. They can be removed once you've verified the new setup works correctly.

## Best Practices

1. **Use the manager script** instead of direct docker commands
2. **Set environment variables** for custom configurations
3. **Use `dev` mode** for development with live reload
4. **Clean up regularly** to avoid disk space issues
5. **Check logs** if containers fail to start
