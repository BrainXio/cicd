#!/usr/bin/env bash
# Test: Verify parallel job execution opportunities in CI workflows

set -euo pipefail

WORKFLOW_DIR=".github/workflows"
FAILED=0

# Test 1: Verify ci-python.yml has parallel opportunities
echo "Test 1: Checking ci-python.yml for parallel opportunities..."

PYTHON_YAML="$WORKFLOW_DIR/ci-python.yml"
if [ ! -f "$PYTHON_YAML" ]; then
    echo "ERROR: $PYTHON_YAML not found"
    exit 1
fi

# Check that lint and typecheck can run in parallel (no needs dependency between them)
if grep -A 5 "name: Type Check" "$PYTHON_YAML" | grep -q "needs: lint"; then
    echo "FAIL: typecheck depends on lint (sequential)"
    FAILED=1
else
    echo "PASS: typecheck does not depend on lint (can be parallel)"
fi

# Check that build-verify and mcp-integration can run in parallel
if grep -A 5 "name: Build Verify" "$PYTHON_YAML" | grep -q "needs: test"; then
    if grep -A 5 "name: MCP Server Integration" "$PYTHON_YAML" | grep -q "needs: test"; then
        echo "PASS: build-verify and mcp-integration both depend only on test (can be parallel)"
    fi
fi

# Test 2: Verify ci-go.yml has parallel opportunities
echo "Test 2: Checking ci-go.yml for parallel opportunities..."

GO_YAML="$WORKFLOW_DIR/ci-go.yml"
if [ ! -f "$GO_YAML" ]; then
    echo "ERROR: $GO_YAML not found"
    exit 1
fi

# Check if fmt has no needs (should be first)
if grep -A 10 "name: Format Check" "$GO_YAML" | grep -q "needs:"; then
    echo "FAIL: fmt has dependencies"
    FAILED=1
else
    echo "PASS: fmt has no dependencies (can start immediately)"
fi

# Test 3: Verify ci-rust.yml has parallel opportunities
echo "Test 3: Checking ci-rust.yml for parallel opportunities..."

RUST_YAML="$WORKFLOW_DIR/ci-rust.yml"
if [ ! -f "$RUST_YAML" ]; then
    echo "ERROR: $RUST_YAML not found"
    exit 1
fi

# Check if fmt has no needs (should be first)
if grep -A 10 "name: Format Check" "$RUST_YAML" | grep -q "needs:"; then
    echo "FAIL: fmt has dependencies"
    FAILED=1
else
    echo "PASS: fmt has no dependencies (can start immediately)"
fi

if [ $FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed"
    exit 1
fi