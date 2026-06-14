#!/usr/bin/env bash
# Test: Verify all Python execution uses uv run consistently

set -euo pipefail

FAILED=0

# Test 1: Check shell scripts for raw Python commands
echo "Test 1: Checking shell scripts for raw Python/pip commands..."

if grep -rnE "^\s+(python|python3|pip|pip3)\s" scripts/*.sh 2>/dev/null | grep -v "uv run\|uv pip\|#!/usr/bin/env python"; then
    echo "FAIL: Found raw Python/pip commands in scripts"
    FAILED=1
else
    echo "PASS: No raw Python/pip commands in scripts"
fi

# Test 2: Check workflow files for raw Python commands
echo "Test 2: Checking workflow files for raw Python/pip commands..."

if grep -rnE "^\s+(python|python3|pip|pip3)\s" .github/workflows/*.yml 2>/dev/null | grep -v "uv run\|uv pip\|python-version\|requires-python\|language: python\|gitleaks\|trufflehog\|lychee\|rustsec\|wagoid\|setup-node\|setup-go\|setup-uv\|rust-toolchain\|typos\|action-gh-release\|upload-artifact\|common-setup"; then
    echo "FAIL: Found raw Python/pip commands in workflows"
    FAILED=1
else
    echo "PASS: No raw Python/pip commands in workflows"
fi

# Test 3: Verify uv run is used for Python execution
echo "Test 3: Verifying uv run is used for Python execution..."

if grep -r "uv run" .github/workflows/*.yml scripts/*.sh 2>/dev/null | grep -q "python"; then
    echo "PASS: uv run is used for Python execution"
else
    echo "INFO: No Python execution found (may be expected for non-Python repos)"
fi

if [ $FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed"
    exit 1
fi