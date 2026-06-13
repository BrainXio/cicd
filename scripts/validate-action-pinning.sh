#!/usr/bin/env bash
# Validate that all external GitHub Actions in workflow files are pinned to SHA-1 hashes
# Usage: validate-action-pinning.sh <file1> [file2] ...

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to validate a single workflow file
validate_workflow_file() {
    local file="$1"
    local errors=0

    # Check if file exists
    if [ ! -f "$file" ]; then
        echo -e "${RED}ERROR${NC}: File not found: $file" >&2
        return 1
    fi

    # Find all 'uses:' lines in the file
    # We use grep with PCRE to match the pattern and extract the action reference
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip empty lines
        [ -z "$line" ] && continue

        # Check if line contains 'uses:'
        if echo "$line" | grep -q "uses:"; then
            # Extract the action reference (everything after 'uses:')
            action_ref=$(echo "$line" | sed -E 's/.*uses:[[:space:]]*([^#[:space:]]+).*/\1/')

            # Skip if empty
            [ -z "$action_ref" ] && continue

            # Check if it's a local/composite action (starts with ./ or ../)
            if [[ "$action_ref" == ./* ]] || [[ "$action_ref" == ../* ]]; then
                echo -e "  ${GREEN}OK${NC}: Local action - $action_ref"
                continue
            fi

            # Check if it's an internal BrainXio action
            if [[ "$action_ref" == brainxio/* ]]; then
                echo -e "  ${GREEN}OK${NC}: Internal BrainXio action - $action_ref"
                continue
            fi

            # Check if it's an external action - must be pinned to SHA-1 hash
            # External action format: owner/repo@ref
            if [[ "$action_ref" == *@* ]]; then
                # Extract the ref part (after @)
                ref="${action_ref#*@}"

                # Check if ref is a valid SHA-1 hash (40 hexadecimal characters)
                if [[ "$ref" =~ ^[0-9a-f]{40}$ ]]; then
                    echo -e "  ${GREEN}OK${NC}: SHA-1 pinned - $action_ref"
                else
                    echo -e "  ${RED}ERROR${NC}: External action not pinned to SHA-1 hash: $action_ref" >&2
                    echo "        Line: $line" >&2
                    errors=$((errors + 1))
                fi
            else
                echo -e "  ${RED}ERROR${NC}: Invalid action reference format: $action_ref" >&2
                echo "        Line: $line" >&2
                errors=$((errors + 1))
            fi
        fi
    done < "$file"

    return $errors
}

# Main function
main() {
    local files=("$@")
    local total_errors=0

    if [ ${#files[@]} -eq 0 ]; then
        echo "Usage: $0 <file1> [file2] ..." >&2
        return 1
    fi

    echo "Validating GitHub Actions pinning in ${#files[@]} file(s)..."

    for file in "${files[@]}"; do
        echo "Checking $file..."
        if ! validate_workflow_file "$file"; then
            total_errors=$((total_errors + 1))
        fi
    done

    if [ "$total_errors" -gt 0 ]; then
        echo -e "${RED}Validation failed${NC}: $total_errors file(s) contain unpinned external actions." >&2
        return 1
    else
        echo -e "${GREEN}All workflow files validated successfully!${NC}"
        return 0
    fi
}

# Run main function with all arguments
main "$@"