#!/usr/bin/env bash
# Check for updates to pinned GitHub Actions and generate PRs when updates are available
# Usage: check-action-updates.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ACTION_REGISTRY="${ACTION_REGISTRY:-/home/mister-robot/claude-dev/workspace/brainxio_cicd/docs/reference/action-hashes.md}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
OUTPUT_DIR="${OUTPUT_DIR:-/tmp/action_updates}"
DRY_RUN="${DRY_RUN:-false}"

# Function to log messages
log() {
    echo "[$(date -Iseconds)] $*" >&2
}

# Function to log info messages
info() {
    log "${BLUE}INFO${NC}: $*"
}

# Function to log success messages
success() {
    log "${GREEN}SUCCESS${NC}: $*"
}

# Function to log warning messages
warn() {
    log "${YELLOW}WARNING${NC}: $*"
}

# Function to log error messages
error() {
    log "${RED}ERROR${NC}: $*"
}

# Function to check if required tools are available
check_dependencies() {
    local missing_tools=()

    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi

    if ! command -v curl &> /dev/null; then
        missing_tools+=("curl")
    fi

    if [ ${#missing_tools[@]} -gt 0 ]; then
        error "Missing required tools: ${missing_tools[*]}"
        error "Please install them and try again"
        return 1
    fi

    success "All dependencies are available"
}

# Function to parse action registry and extract action information
parse_action_registry() {
    local registry_file="${1:-$ACTION_REGISTRY}"

    if [ ! -f "$registry_file" ]; then
        error "Action registry file not found: $registry_file"
        return 1
    fi

    info "Parsing action registry: $registry_file"

    # Extract action information using grep and sed
    # This will output lines in the format: action_name|version_tag|sha1_hash
    grep -A 5 "### " "$registry_file" | grep -E "(^- \*\*Action\*\*:|^- \*\*Version Tag\*\*:|^- \*\*SHA-1 Hash\*\*:)" | \
    sed 's/^- \*\*Action\*\*: //; s/^- \*\*Version Tag\*\*: //; s/^- \*\*SHA-1 Hash\*\*: //' | \
    paste -d'|' - - - | \
    grep -v "^|"  # Remove empty lines
}

# Function to get the latest release tag for an action
get_latest_release_tag() {
    local action_owner_repo="$1"

    if [ -z "$GITHUB_TOKEN" ]; then
        warn "No GitHub token provided, using unauthenticated API requests (rate limited)"
    fi

    local api_url="https://api.github.com/repos/$action_owner_repo/releases/latest"
    local headers=()

    if [ -n "$GITHUB_TOKEN" ]; then
        headers+=("-H" "Authorization: token $GITHUB_TOKEN")
    fi

    # Make API request to get latest release
    local response
    response=$(curl -s "${headers[@]}" "$api_url")

    # Extract tag name from response
    local tag_name
    tag_name=$(echo "$response" | jq -r '.tag_name // empty' 2>/dev/null)

    if [ -n "$tag_name" ] && [ "$tag_name" != "null" ]; then
        echo "$tag_name"
        return 0
    else
        # If no latest release, try to get the latest tag
        api_url="https://api.github.com/repos/$action_owner_repo/tags"
        response=$(curl -s "${headers[@]}" "$api_url")
        tag_name=$(echo "$response" | jq -r '.[0].name // empty' 2>/dev/null)

        if [ -n "$tag_name" ] && [ "$tag_name" != "null" ]; then
            echo "$tag_name"
            return 0
        fi
    fi

    return 1
}

# Function to resolve a tag to its SHA-1 hash
resolve_tag_to_sha() {
    local action_owner_repo="$1"
    local tag="$2"

    if [ -z "$GITHUB_TOKEN" ]; then
        warn "No GitHub token provided, using unauthenticated API requests (rate limited)"
    fi

    local api_url="https://api.github.com/repos/$action_owner_repo/commits/$tag"
    local headers=()

    if [ -n "$GITHUB_TOKEN" ]; then
        headers+=("-H" "Authorization: token $GITHUB_TOKEN")
    fi

    # Make API request to get commit SHA
    local response
    response=$(curl -s "${headers[@]}" "$api_url")

    # Extract SHA from response
    local sha
    sha=$(echo "$response" | jq -r '.sha // empty' 2>/dev/null)

    if [ -n "$sha" ] && [ "$sha" != "null" ]; then
        echo "$sha"
        return 0
    fi

    return 1
}

# Function to check if an action has updates available
check_action_for_updates() {
    local action_info="$1"

    # Parse action info (format: action_name|version_tag|sha1_hash)
    IFS='|' read -r action_name version_tag current_sha <<< "$action_info"

    info "Checking for updates: $action_name@$version_tag (current: ${current_sha:0:7})"

    # Get latest release tag
    local latest_tag
    if ! latest_tag=$(get_latest_release_tag "$action_name"); then
        warn "Could not determine latest release for $action_name"
        return 0
    fi

    info "Latest release for $action_name: $latest_tag"

    # If latest tag is different from current version tag, check the SHA
    if [ "$latest_tag" != "$version_tag" ]; then
        # Resolve latest tag to SHA
        local latest_sha
        if ! latest_sha=$(resolve_tag_to_sha "$action_name" "$latest_tag"); then
            warn "Could not resolve tag $latest_tag to SHA for $action_name"
            return 0
        fi

        info "Latest SHA for $action_name@$latest_tag: ${latest_sha:0:7}"

        # Compare SHAs
        if [ "$latest_sha" != "$current_sha" ]; then
            success "Update available for $action_name: $version_tag -> $latest_tag"
            echo "$action_name|$version_tag|$current_sha|$latest_tag|$latest_sha"
            return 0
        else
            info "No update needed for $action_name (SHA unchanged)"
            return 0
        fi
    else
        info "No new release found for $action_name"
        return 0
    fi
}

# Function to get release notes for a tag
get_release_notes() {
    local action_owner_repo="$1"
    local tag="$2"

    if [ -z "$GITHUB_TOKEN" ]; then
        warn "No GitHub token provided, using unauthenticated API requests (rate limited)"
    fi

    local api_url="https://api.github.com/repos/$action_owner_repo/releases/tags/$tag"
    local headers=()

    if [ -n "$GITHUB_TOKEN" ]; then
        headers+=("-H" "Authorization: token $GITHUB_TOKEN")
    fi

    # Make API request to get release notes
    local response
    response=$(curl -s "${headers[@]}" "$api_url")

    # Extract release notes from response
    local notes
    notes=$(echo "$response" | jq -r '.body // empty' 2>/dev/null)

    if [ -n "$notes" ] && [ "$notes" != "null" ]; then
        echo "$notes"
        return 0
    fi

    return 1
}

# Function to check for security advisories
check_security_advisories() {
    local action_owner_repo="$1"

    if [ -z "$GITHUB_TOKEN" ]; then
        warn "No GitHub token provided, cannot check security advisories"
        return 0
    fi

    local api_url="https://api.github.com/repos/$action_owner_repo/security-advisories"
    local headers=("-H" "Authorization: token $GITHUB_TOKEN" "-H" "Accept: application/vnd.github+json")

    # Make API request to get security advisories
    local response
    response=$(curl -s "${headers[@]}" "$api_url")

    # Check if there are any advisories
    local count
    count=$(echo "$response" | jq 'length // 0' 2>/dev/null)

    if [ "$count" -gt 0 ]; then
        echo "Found $count security advisories for $action_owner_repo"
        echo "$response" | jq -r '.[] | "Advisory: \(.summary) - \(.severity)"'
        return 0
    fi

    return 1
}

# Function to generate update report
generate_update_report() {
    local updates=("$@")

    if [ ${#updates[@]} -eq 0 ]; then
        info "No updates available"
        return 0
    fi

    info "Generating update report for ${#updates[@]} actions"

    # Create output directory
    mkdir -p "$OUTPUT_DIR"

    # Create report file
    local report_file="$OUTPUT_DIR/action_updates_$(date +%Y%m%d_%H%M%S).md"

    {
        echo "# GitHub Actions Update Report"
        echo ""
        echo "Generated on: $(date -Iseconds)"
        echo "Actions with updates available: ${#updates[@]}"
        echo ""
        echo "## Summary of Updates"
        echo ""

        for update in "${updates[@]}"; do
            IFS='|' read -r action_name current_tag current_sha latest_tag latest_sha <<< "$update"

            echo "### $action_name"
            echo ""
            echo "- Current version: $current_tag (${current_sha:0:7})"
            echo "- Latest version: $latest_tag (${latest_sha:0:7})"
            echo "- Update type: SHA-1 hash update"
            echo ""

            # Get release notes
            if release_notes=$(get_release_notes "$action_name" "$latest_tag"); then
                echo "#### Release Notes for $latest_tag"
                echo ""
                echo "$release_notes"
                echo ""
            fi

            # Check for security advisories
            if security_notes=$(check_security_advisories "$action_name"); then
                echo "#### Security Advisories"
                echo ""
                echo "$security_notes"
                echo ""
            fi

            echo "---"
            echo ""
        done

        echo "## Instructions for Update"
        echo ""
        echo "1. Review each action's release notes and security advisories above"
        echo "2. Test the updated actions in a staging environment"
        echo "3. Update workflow files to use the new SHA-1 hashes"
        echo "4. Update the action registry at $ACTION_REGISTRY"
        echo "5. Create a pull request with these changes"
        echo ""
        echo "## Manual Update Commands"
        echo ""

        for update in "${updates[@]}"; do
            IFS='|' read -r action_name current_tag current_sha latest_tag latest_sha <<< "$update"
            echo "- Update $action_name from ${current_sha:0:7} to ${latest_sha:0:7}"
        done

        echo ""
    } > "$report_file"

    success "Update report generated: $report_file"
    echo "$report_file"
}

# Function to create a PR (dry run mode)
create_pr_dry_run() {
    local report_file="$1"

    info "Creating PR (dry run mode)"
    echo "PR Title: chore(ci): update GitHub Actions to latest versions"
    echo "PR Body: See $report_file for details"
    echo "Branch: action-updates-$(date +%Y%m%d)"

    success "PR creation simulated successfully"
}

# Main function
main() {
    info "Starting GitHub Actions update check"

    # Check dependencies
    check_dependencies || return 1

    # Parse action registry
    local actions
    mapfile -t actions < <(parse_action_registry)

    if [ ${#actions[@]} -eq 0 ]; then
        warn "No actions found in registry"
        return 0
    fi

    info "Found ${#actions[@]} actions in registry"

    # Check each action for updates
    local updates=()
    for action_info in "${actions[@]}"; do
        if update_info=$(check_action_for_updates "$action_info"); then
            if [ -n "$update_info" ]; then
                updates+=("$update_info")
            fi
        fi
    done

    # Generate update report
    local report_file
    report_file=$(generate_update_report "${updates[@]}")

    # Create PR if updates were found
    if [ ${#updates[@]} -gt 0 ]; then
        if [ "$DRY_RUN" = "true" ]; then
            create_pr_dry_run "$report_file"
        else
            # In a real implementation, this would create an actual PR
            info "In a full implementation, this would create a PR with the updates"
            info "For now, review the report at: $report_file"
        fi
    else
        info "No updates available for any actions"
    fi

    success "GitHub Actions update check completed"
}

# Run main function only if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi