#!/bin/zsh

# docker-manager.sh: Build and run a single agent-zero container on port 8080 with watch enabled

IMAGE_NAME="agent-zero"
CONTAINER_NAME="agent-zero"
BRANCH=${BRANCH:-main}

# Stop and remove any existing container
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}$"; then
  echo "Stopping and removing existing container: $CONTAINER_NAME"
  docker stop $CONTAINER_NAME || true
  docker rm $CONTAINER_NAME || true
fi

echo "Building Docker image: $IMAGE_NAME (branch: $BRANCH)"
docker build -t $IMAGE_NAME -f Dockerfile --build-arg BRANCH=$BRANCH --build-arg CACHE_DATE=$(date +%s) .

echo "Running container: $CONTAINER_NAME on port 8080 with watch enabled"
docker run -d \
  --name $CONTAINER_NAME \
  -p 8080:80 \
  -e BRANCH=$BRANCH \
  -e WATCH=1 \
  -v "/Users/johnmbwambo/Agent Zero - Project/agent-zero":/a0 \
  $IMAGE_NAME

echo "Container $CONTAINER_NAME is running on http://localhost:8080"
