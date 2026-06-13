#!/usr/bin/env bash
# Test script for validate-action-pinning.sh
# Tests various scenarios for action pinning validation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATE_SCRIPT="$SCRIPT_DIR/validate-action-pinning.sh"

# Create a temporary directory for test files
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

# Counter for tests
PASSED=0
FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local expected_exit_code="$2"
    shift 2
    local test_file="$TEST_DIR/test_workflow.yml"

    # Create test file with provided content
    cat > "$test_file" <<EOF
$(cat)
EOF

    # Run validation script
    if "$VALIDATE_SCRIPT" "$test_file" > "$TEST_DIR/output.txt" 2>&1; then
        actual_exit_code=0
    else
        actual_exit_code=$?
    fi

    # Check result
    if [ "$actual_exit_code" -eq "$expected_exit_code" ]; then
        echo -e "${GREEN}PASS${NC}: $test_name"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}FAIL${NC}: $test_name"
        echo "Expected exit code: $expected_exit_code, got: $actual_exit_code"
        echo "Output:"
        cat "$TEST_DIR/output.txt"
        FAILED=$((FAILED + 1))
    fi
}

# Test 1: Valid SHA-1 hash should pass
echo "Test 1: Valid SHA-1 hash should pass"
run_test "Valid SHA-1 hash" 0 <<EOF
name: Test Workflow
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10
EOF

# Test 2: Version tag should fail
echo "Test 2: Version tag should fail"
run_test "Version tag should fail" 1 <<EOF
name: Test Workflow
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
EOF

# Test 3: Internal action should pass
echo "Test 3: Internal action should pass"
run_test "Internal action should pass" 0 <<EOF
name: Test Workflow
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: brainxio/actions/setup-rust-deps@v1
EOF

# Test 4: Composite action should pass
echo "Test 4: Composite action should pass"
run_test "Composite action should pass" 0 <<EOF
name: Test Workflow
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: ./actions/common-setup
EOF

# Test 5: Invalid hash (too short) should fail
echo "Test 5: Invalid hash (too short) should fail"
run_test "Invalid hash (too short) should fail" 1 <<EOF
name: Test Workflow
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e1
EOF

# Test 6: Invalid hash (non-hex) should fail
echo "Test 6: Invalid hash (non-hex) should fail"
run_test "Invalid hash (non-hex) should fail" 1 <<EOF
name: Test Workflow
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e1z
EOF

# Test 7: Multiple valid actions should pass
echo "Test 7: Multiple valid actions should pass"
run_test "Multiple valid actions should pass" 0 <<EOF
name: Test Workflow
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10
      - uses: actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02
      - uses: ./actions/common-setup
EOF

# Test 8: Mixed valid and invalid should fail
echo "Test 8: Mixed valid and invalid should fail"
run_test "Mixed valid and invalid should fail" 1 <<EOF
name: Test Workflow
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10
      - uses: actions/upload-artifact@v4  # Invalid - version tag
EOF

# Summary
echo ""
echo "=== Test Summary ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi