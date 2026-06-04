#!/usr/bin/env bash
# Build and run the Docker test suite locally
# Usage: ./run_tests.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

TOTAL_PASS=0
TOTAL_FAIL=0

run_test() {
    local label="$1" IMAGE="$2" FOLDER="$3"

    echo ""
    echo "═══════════════════════════════════════"
    echo "  Testing: $label"
    echo "═══════════════════════════════════════"

    local p f
    p=$(docker build -f "$REPO_ROOT/$FOLDER" -t "$IMAGE" "$REPO_ROOT" 2>&1 | tail -1)
    echo "  Built: $p"

    local out
    out=$(docker run --rm "$IMAGE" 2>&1) || true
    echo "$out"

    local fails
    fails=$(echo "$out" | grep '^\[FAIL\]' | wc -l | tr -d ' ')
    local passes
    passes=$(echo "$out" | grep '^\[PASS\]' | wc -l | tr -d ' ')

    echo "  → $passes passed, $fails failed"
    TOTAL_PASS=$((TOTAL_PASS + passes))
    TOTAL_FAIL=$((TOTAL_FAIL + fails))
}

run_test "Ubuntu (Docker)" "dots-test-ubuntu:latest" "tests/Dockerfile"
run_test "Arch Linux (Docker)" "dots-test-arch:latest" "tests/Dockerfile.arch"

echo ""
echo "═══════════════════════════════════════"
echo "  Total: ${TOTAL_PASS} passed, ${TOTAL_FAIL} failed"
echo "═══════════════════════════════════════"

[[ $TOTAL_FAIL -eq 0 ]]
