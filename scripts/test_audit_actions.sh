#!/usr/bin/env bash
# Test suite for audit-actions.sh

set -eo pipefail

# Test directory setup
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR" 2>/dev/null || true' EXIT

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function to run a test
run_test() {
    local test_name="$1"
    local test_function="$2"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "Running: $test_name... "

    if $test_function; then
        echo -e "${GREEN}PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 1: Script exists and is executable
test_script_exists() {
    [ -f "./scripts/audit-actions.sh" ] && [ -x "./scripts/audit-actions.sh" ]
}

# Test 2: Script scans workflow files
test_scans_workflow_files() {
    # Create test workflow files
    mkdir -p "$TEST_DIR/.github/workflows"
    cat > "$TEST_DIR/.github/workflows/test.yml" << 'EOF'
name: Test Workflow
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
EOF

    # Run audit script
    cd "$TEST_DIR"
    output=$(/home/mister-robot/claude-dev/workspace/brainxio_cicd/scripts/audit-actions.sh 2>&1 || true)

    # Check that it found the actions
    echo "$output" | grep -q "actions/checkout" && \
    echo "$output" | grep -q "actions/setup-python"
}

# Test 3: Distinguishes external from internal actions
test_distinguishes_external_internal() {
    mkdir -p "$TEST_DIR/.github/workflows"
    cat > "$TEST_DIR/.github/workflows/test.yml" << 'EOF'
name: Test Workflow
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ./internal-action
EOF

    cd "$TEST_DIR"
    output=$(/home/mister-robot/claude-dev/workspace/brainxio_cicd/scripts/audit-actions.sh 2>&1 || true)

    # Should find external action but not internal
    echo "$output" | grep -q "actions/checkout" && \
    ! echo "$output" | grep -q "internal-action"
}

# Test 4: Lists action name, version tag, and workflow location
test_lists_action_metadata() {
    mkdir -p "$TEST_DIR/.github/workflows"
    cat > "$TEST_DIR/.github/workflows/test.yml" << 'EOF'
name: Test Workflow
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
EOF

    cd "$TEST_DIR"
    output=$(/home/mister-robot/claude-dev/workspace/brainxio_cicd/scripts/audit-actions.sh 2>&1 || true)

    # Should contain action name, version, and file location
    echo "$output" | grep -q "actions/checkout" && \
    echo "$output" | grep -q "v4" && \
    echo "$output" | grep -q "test.yml"
}

# Test 5: Generates initial action registry document
test_generates_registry() {
    mkdir -p "$TEST_DIR/.github/workflows"
    cat > "$TEST_DIR/.github/workflows/test.yml" << 'EOF'
name: Test Workflow
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
EOF

    cd "$TEST_DIR"
    /home/mister-robot/claude-dev/workspace/brainxio_cicd/scripts/audit-actions.sh --output "$TEST_DIR/action-hashes.md" 2>&1 || true

    # Check that registry file was created
    [ -f "$TEST_DIR/action-hashes.md" ]
}

# Test 6: Handles multiple workflow files
test_handles_multiple_files() {
    mkdir -p "$TEST_DIR/.github/workflows"
    cat > "$TEST_DIR/.github/workflows/test1.yml" << 'EOF'
name: Test Workflow 1
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
EOF

    cat > "$TEST_DIR/.github/workflows/test2.yml" << 'EOF'
name: Test Workflow 2
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/setup-python@v5
EOF

    cd "$TEST_DIR"
    output=$(/home/mister-robot/claude-dev/workspace/brainxio_cicd/scripts/audit-actions.sh 2>&1 || true)

    # Should find actions from both files
    echo "$output" | grep -q "actions/checkout" && \
    echo "$output" | grep -q "actions/setup-python" && \
    echo "$output" | grep -q "test1.yml" && \
    echo "$output" | grep -q "test2.yml"
}

# Test 7: Handles workflows with no external actions
test_handles_no_external_actions() {
    local test_dir
    test_dir="$(mktemp -d)"
    trap 'rm -rf "$test_dir"' RETURN

    mkdir -p "$test_dir/.github/workflows"
    cat > "$test_dir/.github/workflows/test.yml" << 'EOF'
name: Test Workflow
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: ./internal-action
      - run: echo "test"
EOF

    cd "$test_dir"
    output=$(/home/mister-robot/claude-dev/workspace/brainxio_cicd/scripts/audit-actions.sh 2>&1 || true)

    # Should indicate no external actions found
    echo "$output" | grep -qi "no external actions\|0 external actions"
}

# Run all tests
echo "Running audit-actions.sh test suite..."
echo "======================================"
echo ""

run_test "Script exists and is executable" test_script_exists
run_test "Script scans workflow files" test_scans_workflow_files
run_test "Distinguishes external from internal actions" test_distinguishes_external_internal
run_test "Lists action name, version tag, and workflow location" test_lists_action_metadata
run_test "Generates initial action registry document" test_generates_registry
run_test "Handles multiple workflow files" test_handles_multiple_files
run_test "Handles workflows with no external actions" test_handles_no_external_actions

echo ""
echo "======================================"
echo "Tests run: $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"

# Exit with appropriate code
if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
fi

exit 0