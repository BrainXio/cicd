#!/bin/bash

# test_pin_actions.sh - Test suite for pin-actions.sh
#
# Tests that the pinning script:
# 1. Doesn't add corrupted log lines to workflow files
# 2. Only modifies 'uses:' lines
# 3. Preserves YAML syntax validity

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test directory
TEST_DIR="/tmp/pin-actions-test-$$"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Setup test environment
setup() {
    mkdir -p "$TEST_DIR/.github/workflows"
    mkdir -p "$TEST_DIR/docs/reference"

    # Create a minimal action registry for testing
    cat > "$TEST_DIR/docs/reference/action-hashes.md" << 'EOF'
# Action Hashes Registry

### actions/checkout@v3

- **SHA-1 Hash**: df4cb1c069e1874edd31b4311f1884172cec0e10
- **Version**: v3
- **Last Updated**: 2026-06-13

### actions/setup-node@v4

- **SHA-1 Hash**: a0853c24544627f65ddf259abe73b1d18a591444
- **Version**: v4
- **Last Updated**: 2026-06-13
EOF

    # Create test workflow file
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
}

# Cleanup test environment
cleanup() {
    rm -rf "$TEST_DIR"
}

# Test helper functions
test_start() {
    local test_name="$1"
    echo -n "Testing: $test_name ... "
    ((TESTS_RUN++))
}

test_pass() {
    echo -e "${GREEN}PASS${NC}"
    ((TESTS_PASSED++))
}

test_fail() {
    local reason="$1"
    echo -e "${RED}FAIL${NC} - $reason"
    ((TESTS_FAILED++))
}

# Run the pin-actions script with test directory
run_pin_actions() {
    # Create a modified version that uses TEST_DIR paths
    sed -e "s|WORKFLOWS_DIR=.*|WORKFLOWS_DIR=\"$TEST_DIR/.github/workflows\"|" \
        -e "s|ACTION_REGISTRY=.*|ACTION_REGISTRY=\"$TEST_DIR/docs/reference/action-hashes.md\"|" \
        "$SCRIPT_DIR/pin-actions.sh" > "$TEST_DIR/pin-actions-test.sh"
    chmod +x "$TEST_DIR/pin-actions-test.sh"
    "$TEST_DIR/pin-actions-test.sh" 2>&1
}

# Test 1: No corrupted "Skipping internal action" lines
test_no_corrupted_skip_lines() {
    test_start "No corrupted 'Skipping internal action' lines"

    local output_file="$TEST_DIR/.github/workflows/test.yml"
    if grep -q "Skipping internal action:" "$output_file"; then
        test_fail "Found corrupted 'Skipping internal action:' lines in workflow file"
        grep -n "Skipping internal action:" "$output_file" || true
        return 1
    fi

    test_pass
    return 0
}

# Test 2: No corrupted "Pinned" lines
test_no_corrupted_pinned_lines() {
    test_start "No corrupted 'Pinned' lines"

    local output_file="$TEST_DIR/.github/workflows/test.yml"
    if grep -q "^  Pinned " "$output_file"; then
        test_fail "Found corrupted 'Pinned' lines in workflow file"
        grep -n "^  Pinned " "$output_file" || true
        return 1
    fi

    test_pass
    return 0
}

# Test 3: Only 'uses:' lines are modified
test_only_uses_lines_modified() {
    test_start "Only 'uses:' lines contain SHA-1 hashes"

    local output_file="$TEST_DIR/.github/workflows/test.yml"

    # Check that lines without 'uses:' don't have SHA-1 hashes
    while IFS= read -r line; do
        if [[ ! "$line" =~ uses: ]] && [[ "$line" =~ [a-f0-9]{40} ]]; then
            test_fail "Found SHA-1 hash on non-uses line: $line"
            return 1
        fi
    done < "$output_file"

    test_pass
    return 0
}

# Test 4: YAML syntax is valid
test_yaml_syntax_valid() {
    test_start "YAML syntax is valid"

    local output_file="$TEST_DIR/.github/workflows/test.yml"

    if ! command -v yamllint &> /dev/null; then
        echo -e "${YELLOW}SKIP${NC} (yamllint not available)"
        return 0
    fi

    if ! yamllint -d "{extends: default, rules: {line-length: disable}}" "$output_file" &> /dev/null; then
        test_fail "YAML syntax error in output file"
        yamllint -d "{extends: default, rules: {line-length: disable}}" "$output_file" || true
        return 1
    fi

    test_pass
    return 0
}

# Test 5: External actions are pinned
test_external_actions_pinned() {
    test_start "External actions are pinned to SHA-1 hashes"

    local output_file="$TEST_DIR/.github/workflows/test.yml"

    # Check that actions/checkout is pinned
    if ! grep -q "uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10" "$output_file"; then
        test_fail "actions/checkout not pinned to SHA-1 hash"
        return 1
    fi

    # Check that actions/setup-node is pinned
    if ! grep -q "uses: actions/setup-node@a0853c24544627f65ddf259abe73b1d18a591444" "$output_file"; then
        test_fail "actions/setup-node not pinned to SHA-1 hash"
        return 1
    fi

    test_pass
    return 0
}

# Test 6: Internal actions are preserved
test_internal_actions_preserved() {
    test_start "Internal actions are preserved with version tags"

    local output_file="$TEST_DIR/.github/workflows/test.yml"

    # Check that brainxio actions are NOT pinned
    if grep -q "brainxio/actions/common-setup@[a-f0-9]{40}" "$output_file"; then
        test_fail "Internal action was incorrectly pinned to SHA-1 hash"
        return 1
    fi

    # Check that brainxio actions keep their version tags
    if ! grep -q "brainxio/actions/common-setup@v1" "$output_file"; then
        test_fail "Internal action version tag was removed"
        return 1
    fi

    test_pass
    return 0
}

# Test 7: No log messages in output
test_no_log_messages_in_output() {
    test_start "No log messages appear in output file"

    local output_file="$TEST_DIR/.github/workflows/test.yml"

    # Check for various log message patterns
    local log_patterns=(
        "\[INFO\]"
        "\[WARN\]"
        "\[ERROR\]"
        "Created backup"
        "File updated"
        "Actions pinned"
    )

    for pattern in "${log_patterns[@]}"; do
        if grep -qE "$pattern" "$output_file"; then
            test_fail "Found log message pattern '$pattern' in output file"
            grep -nE "$pattern" "$output_file" || true
            return 1
        fi
    done

    test_pass
    return 0
}

# Main test runner
main() {
    echo "=== Running pin-actions.sh test suite ==="
    echo ""

    setup

    # Run the pinning script
    echo "Running pin-actions.sh..."
    run_pin_actions > /dev/null 2>&1 || true
    echo ""

    # Run all tests
    test_no_corrupted_skip_lines
    test_no_corrupted_pinned_lines
    test_only_uses_lines_modified
    test_yaml_syntax_valid
    test_external_actions_pinned
    test_internal_actions_preserved
    test_no_log_messages_in_output

    # Cleanup
    cleanup

    # Print summary
    echo ""
    echo "=== Test Summary ==="
    echo "Tests run: $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "${RED}Failed: $TESTS_FAILED${NC}"
        exit 1
    else
        echo "Failed: $TESTS_FAILED"
        echo ""
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    fi
}

main "$@"