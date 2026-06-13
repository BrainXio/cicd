#!/bin/bash

# test_pin_actions_simple.sh - Simple test for pin-actions.sh corruption bug
#
# This test verifies that the pinning script doesn't add corrupted log lines
# to workflow files.

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Test directory
TEST_DIR="/tmp/pin-actions-simple-test-$$"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Setup
echo "Setting up test environment..."
mkdir -p "$TEST_DIR/.github/workflows"
mkdir -p "$TEST_DIR/docs/reference"

# Create action registry
cat > "$TEST_DIR/docs/reference/action-hashes.md" << 'EOF'
# Action Hashes Registry

### actions/checkout@v3

- **SHA-1 Hash**: df4cb1c069e1874edd31b4311f1884172cec0e10

### actions/setup-node@v4

- **SHA-1 Hash**: a0853c24544627f65ddf259abe73b1d18a591444
EOF

# Create test workflow
cat > "$TEST_DIR/.github/workflows/test.yml" << 'EOF'
name: Test Workflow
on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: brainxio/actions/common-setup@v1
        with:
          test: value
      - name: Another step
        uses: actions/setup-node@v4
EOF

# Run pinning script with test paths
echo "Running pin-actions.sh..."
sed -e "s|WORKFLOWS_DIR=.*|WORKFLOWS_DIR=\"$TEST_DIR/.github/workflows\"|" \
    -e "s|ACTION_REGISTRY=.*|ACTION_REGISTRY=\"$TEST_DIR/docs/reference/action-hashes.md\"|" \
    "$SCRIPT_DIR/pin-actions.sh" > "$TEST_DIR/pin-actions-test.sh"
chmod +x "$TEST_DIR/pin-actions-test.sh"

# Capture output
OUTPUT=$("$TEST_DIR/pin-actions-test.sh" 2>&1)
EXIT_CODE=$?

echo "Script exit code: $EXIT_CODE"
echo ""

# Test 1: Check for corrupted "Skipping internal action" lines
echo "Test 1: Checking for corrupted 'Skipping internal action' lines..."
if grep -q "Skipping internal action:" "$TEST_DIR/.github/workflows/test.yml"; then
    echo -e "${RED}FAIL${NC} - Found corrupted 'Skipping internal action:' lines"
    grep -n "Skipping internal action:" "$TEST_DIR/.github/workflows/test.yml" || true
    rm -rf "$TEST_DIR"
    exit 1
fi
echo -e "${GREEN}PASS${NC}"

# Test 2: Check for corrupted "Pinned" lines
echo "Test 2: Checking for corrupted 'Pinned' lines..."
if grep -q "^  Pinned " "$TEST_DIR/.github/workflows/test.yml"; then
    echo -e "${RED}FAIL${NC} - Found corrupted 'Pinned' lines"
    grep -n "^  Pinned " "$TEST_DIR/.github/workflows/test.yml" || true
    rm -rf "$TEST_DIR"
    exit 1
fi
echo -e "${GREEN}PASS${NC}"

# Test 3: Check that external actions are pinned
echo "Test 3: Checking that external actions are pinned..."
if ! grep -q "uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" "$TEST_DIR/.github/workflows/test.yml"; then
    echo -e "${RED}FAIL${NC} - actions/checkout not pinned"
    cat "$TEST_DIR/.github/workflows/test.yml"
    rm -rf "$TEST_DIR"
    exit 1
fi
echo -e "${GREEN}PASS${NC}"

# Test 4: Check that internal actions are NOT pinned
echo "Test 4: Checking that internal actions are NOT pinned..."
if ! grep -q "brainxio/actions/common-setup@v1" "$TEST_DIR/.github/workflows/test.yml"; then
    echo -e "${RED}FAIL${NC} - Internal action was incorrectly modified"
    cat "$TEST_DIR/.github/workflows/test.yml"
    rm -rf "$TEST_DIR"
    exit 1
fi
echo -e "${GREEN}PASS${NC}"

# Test 5: Check for any log messages in output
echo "Test 5: Checking for log messages in output file..."
if grep -qE "\[(INFO|WARN|ERROR)\]" "$TEST_DIR/.github/workflows/test.yml"; then
    echo -e "${RED}FAIL${NC} - Found log messages in output file"
    grep -nE "\[(INFO|WARN|ERROR)\]" "$TEST_DIR/.github/workflows/test.yml" || true
    rm -rf "$TEST_DIR"
    exit 1
fi
echo -e "${GREEN}PASS${NC}"

# Cleanup
rm -rf "$TEST_DIR"

echo ""
echo -e "${GREEN}All tests passed!${NC}"
echo ""
echo "The pinning script now correctly avoids writing log messages to workflow files."