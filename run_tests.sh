#!/usr/bin/env bash
# Build and run the Docker test suite locally
# Usage: ./run_tests.sh
set -euo pipefail

IMAGE="dots-test:latest"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "Building test image..."
docker build -f "$REPO_ROOT/tests/Dockerfile" -t "$IMAGE" "$REPO_ROOT"

echo ""
echo "Running tests..."
docker run --rm "$IMAGE"
