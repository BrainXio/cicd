#!/usr/bin/env bash
# Lookup SHA-1 commit hashes for GitHub Actions
# Queries GitHub API to get commit hashes for action versions

set -euo pipefail

# Default values
ACTION_REGISTRY="docs/reference/action-hashes.md"
TEMP_REGISTRY="temp-action-hashes.md"
GH_API_DELAY=1  # Delay between API calls in seconds

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --registry)
            ACTION_REGISTRY="$2"
            shift 2
            ;;
        --delay)
            GH_API_DELAY="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--registry FILE] [--delay SECONDS]"
            echo ""
            echo "Lookup SHA-1 commit hashes for GitHub Actions."
            echo ""
            echo "Options:"
            echo "  --registry FILE   Action registry file (default: docs/reference/action-hashes.md)"
            echo "  --delay SECONDS   Delay between API calls (default: 1)"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            exit 1
            ;;
    esac
done

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed" >&2
    echo "Install it from: https://github.com/cli/cli#installation" >&2
    exit 1
fi

# Check if registry file exists
if [ ! -f "$ACTION_REGISTRY" ]; then
    echo "Error: Action registry file '$ACTION_REGISTRY' not found" >&2
    exit 1
fi

# Function to get SHA-1 hash for an action
get_action_hash() {
    local action_ref="$1"  # e.g., actions/upload-artifact@v4
    local action_name="${action_ref%@*}"
    local version="${action_ref#*@}"

    # Extract owner and repo from action name
    local owner=""
    local repo=""
    if [[ "$action_name" =~ ^([^/]+)/(.+)$ ]]; then
        owner="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
    else
        echo "Error: Invalid action name format '$action_name'" >&2
        return 1
    fi

    echo "Looking up hash for $action_name@$version..." >&2

    # Get the commit hash from the GitHub API
    local commit_hash=""
    local api_error=""

    # Try to get the hash using the git/refs/tags endpoint first
    if commit_hash=$(gh api "repos/$owner/$repo/git/refs/tags/$version" --jq '.object.sha' 2>/dev/null); then
        # If the result is a reference to another object, we need to dereference it
        if [[ "$commit_hash" == *"refs/"* ]]; then
            # This is a lightweight tag pointing to another reference, try to get the actual commit
            commit_hash=$(gh api "repos/$owner/$repo/commits/$version" --jq '.sha' 2>/dev/null || true)
        fi
    else
        # If tag lookup fails, try getting commit directly
        if commit_hash=$(gh api "repos/$owner/$repo/commits/$version" --jq '.sha' 2>/dev/null); then
            true  # Success
        else
            api_error="Failed to get commit hash for $action_name@$version"
        fi
    fi

    # Validate that we got a proper SHA-1 hash
    if [[ -n "$commit_hash" && "$commit_hash" =~ ^[0-9a-f]{40}$ ]]; then
        echo "$commit_hash"
        return 0
    elif [[ -n "$api_error" ]]; then
        echo "Error: $api_error" >&2
        return 1
    else
        echo "Error: Invalid commit hash format for $action_name@$version" >&2
        return 1
    fi
}

# Function to update registry with hash
update_registry() {
    local action_ref="$1"
    local hash="$2"
    local update_date="$3"

    # Use sed to update the registry file
    # Find the section for this action and update the SHA-1 Hash and Update Date lines
    sed -i.bak "/### ${action_ref//\//\\/}/,/^###/ {s/\*Not yet looked up\*/$hash/; /Update Date/s/\*Not yet updated\*/$update_date/;}" "$ACTION_REGISTRY"

    # Check if the update was successful
    if grep -q "$hash" "$ACTION_REGISTRY"; then
        # Remove backup file
        rm -f "$ACTION_REGISTRY.bak"
        return 0
    else
        echo "Warning: Failed to update registry for $action_ref" >&2
        # Restore from backup
        if [ -f "$ACTION_REGISTRY.bak" ]; then
            mv "$ACTION_REGISTRY.bak" "$ACTION_REGISTRY"
        fi
        return 1
    fi
}

# Main processing
echo "Starting SHA-1 hash lookup for GitHub Actions..." >&2

# Create a temporary copy of the registry
cp "$ACTION_REGISTRY" "$TEMP_REGISTRY"

# Extract action references from the registry
ACTION_REFS=()
while IFS= read -r line; do
    if [[ "$line" =~ ^###\ ([^@]+)@(.+)$ ]]; then
        action_name="${BASH_REMATCH[1]}"
        version="${BASH_REMATCH[2]}"
        ACTION_REFS+=("$action_name@$version")
    fi
done < "$ACTION_REGISTRY"

if [ ${#ACTION_REFS[@]} -eq 0 ]; then
    echo "No actions found in registry" >&2
    exit 1
fi

SUCCESS_COUNT=0
ERROR_COUNT=0

# Process each action
for action_ref in "${ACTION_REFS[@]}"; do
    echo "Processing $action_ref..." >&2

    # Get the hash
    if hash=$(get_action_hash "$action_ref"); then
        update_date=$(date -u +"%Y-%m-%d")
        if update_registry "$action_ref" "$hash" "$update_date"; then
            echo "  ✓ Found hash: $hash" >&2
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            echo "  ✗ Failed to update registry" >&2
            ERROR_COUNT=$((ERROR_COUNT + 1))
        fi
    else
        echo "  ✗ Failed to get hash" >&2
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    # Delay to avoid rate limiting
    sleep "$GH_API_DELAY"
done

# Remove backup file
rm -f "$ACTION_REGISTRY.bak"

# Summary
echo "" >&2
echo "Lookup complete:" >&2
echo "  Successful: $SUCCESS_COUNT" >&2
echo "  Errors: $ERROR_COUNT" >&2

if [ $ERROR_COUNT -gt 0 ]; then
    echo "Some actions failed to lookup. Check error messages above." >&2
    exit 1
fi

echo "Action registry updated successfully!" >&2
exit 0