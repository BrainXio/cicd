#!/usr/bin/env bash
# Test: Verify Makefile uses SHA comparison for githooks detection

set -euo pipefail

FAILED=0

# Test 1: Check that Makefile uses SHA comparison
echo "Test 1: Checking Makefile for SHA-based hook comparison..."

if grep -q "sha256sum\|shasum\|sha1sum" Makefile; then
    echo "PASS: Makefile uses SHA-based comparison"
else
    echo "FAIL: Makefile does not use SHA-based comparison"
    FAILED=1
fi

# Test 2: Check that Makefile updates hooks when SHA changes
echo "Test 2: Checking Makefile updates hooks when SHA changes..."

if grep -q "\.sha\|\.hash" Makefile; then
    echo "PASS: Makefile tracks hook hashes"
else
    echo "FAIL: Makefile does not track hook hashes"
    FAILED=1
fi

# Test 3: Verify Makefile doesn't use simple file comparison
echo "Test 3: Verifying Makefile doesn't use simple file existence check..."

if grep -q "if \[ ! -e .git/hooks" Makefile; then
    echo "FAIL: Makefile still uses simple file existence check"
    FAILED=1
else
    echo "PASS: Makefile doesn't use simple file existence check"
fi

if [ $FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed"
    exit 1
fi