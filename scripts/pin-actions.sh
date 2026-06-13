#!/bin/bash

# pin-actions.sh - Pin external GitHub Actions to SHA-1 hashes
#
# This script updates all workflow files to use SHA-1 hashes instead of version tags
# for external actions, while preserving internal actions (starting with brainxio/).
# It creates backups of original files before modification.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
WORKFLOWS_DIR="/home/mister-robot/claude-dev/workspace/brainxio_cicd/.github/workflows"
ACTION_REGISTRY="/home/mister-robot/claude-dev/workspace/brainxio_cicd/docs/reference/action-hashes.md"
BACKUP_SUFFIX=".backup-$(date +%Y%m%d-%H%M%S)"

# Counters
files_updated=0
actions_pinned=0

# Function to log messages
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required files exist
if [[ ! -d "$WORKFLOWS_DIR" ]]; then
    log_error "Workflows directory not found: $WORKFLOWS_DIR"
    exit 1
fi

if [[ ! -f "$ACTION_REGISTRY" ]]; then
    log_error "Action registry not found: $ACTION_REGISTRY"
    exit 1
fi

log "Starting to pin external GitHub Actions to SHA-1 hashes..."
log "Workflows directory: $WORKFLOWS_DIR"
log "Action registry: $ACTION_REGISTRY"

# Function to extract action and hash from registry
extract_action_hash() {
    local action_tag="$1"
    local action_name=""
    local tag=""

    # Split action@tag into action and tag
    IFS='@' read -r action_name tag <<< "$action_tag"

    # Look for the action in the registry and extract its SHA-1 hash
    local hash=""

    # Find the section for this action and extract the hash
    local in_section=false
    local current_action=""
    local current_tag=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Check for section header
        if [[ "$line" =~ ^###\ (.+)@(.+)$ ]]; then
            current_action="${BASH_REMATCH[1]}"
            current_tag="${BASH_REMATCH[2]}"

            # Check if this is the section we're looking for
            if [[ "$current_action" == "$action_name" && "$current_tag" == "$tag" ]]; then
                in_section=true
            else
                in_section=false
            fi
        elif [[ $in_section == true && "$line" =~ ^-\ \*\*SHA-1\ Hash\*\*:\ ([a-f0-9]{40})$ ]]; then
            hash="${BASH_REMATCH[1]}"
            break
        elif [[ $in_section == true && "$line" =~ ^###\  ]]; then
            # We've reached the next section, stop looking
            break
        fi
    done < "$ACTION_REGISTRY"

    echo "$hash"
}

# Create backup of action registry
cp "$ACTION_REGISTRY" "${ACTION_REGISTRY}${BACKUP_SUFFIX}"
log "Created backup of action registry: ${ACTION_REGISTRY}${BACKUP_SUFFIX}"

# Process each workflow file
log "Looking for workflow files..."
# Use find to get all .yml and .yaml files, excluding backups and temp files
mapfile -t workflow_files < <(find "$WORKFLOWS_DIR" -name "*.yml" -o -name "*.yaml" | grep -v -E "(\.backup-|\.tmp$)")

log "Found ${#workflow_files[@]} workflow files"

for workflow_file in "${workflow_files[@]}"; do
    # Skip backup files
    if [[ "$workflow_file" == *.backup-* ]]; then
        log "Skipping backup file: $workflow_file"
        continue
    fi

    # Skip temporary files
    if [[ "$workflow_file" == *.tmp ]]; then
        log "Skipping temporary file: $workflow_file"
        continue
    fi

    log "Processing workflow: $(basename "$workflow_file")"

    # Create backup
    cp "$workflow_file" "${workflow_file}${BACKUP_SUFFIX}"
    log "  Created backup: ${workflow_file}${BACKUP_SUFFIX}"

    # Track if this file was modified
    file_modified=0

    # Create a temporary file for modifications
    temp_file="${workflow_file}.tmp"

    # Process the file line by line
    # We need to be careful with the end of file condition
    # IMPORTANT: All log statements must use >&2 to avoid writing to temp file
    {
        while IFS= read -r line; do
            # Check if line contains a "uses:" directive with an external action
            # This pattern matches both lines that start with a dash and indented lines
            if [[ "$line" =~ [[:space:]]*[-]*[[:space:]]*uses:[[:space:]]*([^[:space:]]+@[^[:space:]]+) ]]; then
                full_action="${BASH_REMATCH[1]}"
                action_name="${full_action%@*}"
                tag="${full_action#*@}"

                # Skip internal BrainXio actions (starting with brainxio/)
                if [[ "$action_name" == brainxio/* ]]; then
                    log "  Skipping internal action: $full_action" >&2
                    echo "$line"
                    continue
                fi

                # Extract the SHA-1 hash for this action
                hash=$(extract_action_hash "$full_action")

                if [[ -n "$hash" ]]; then
                    # Replace the action with its SHA-1 hash
                    # We need to be careful to preserve the exact indentation and formatting
                    new_line="${line/$full_action/$action_name@$hash}"
                    echo "$new_line"
                    log "  Pinned $full_action -> $action_name@$hash" >&2
                    ((actions_pinned++))
                    file_modified=1
                else
                    log_warn "  No SHA-1 hash found for $full_action in registry" >&2
                    echo "$line"
                fi
            else
                # Output the line unchanged
                echo "$line"
            fi
        done

        # Handle the last line if it doesn't end with a newline
        if [[ -n "$line" ]]; then
            # Check if line contains a "uses:" directive with an external action
            if [[ "$line" =~ [[:space:]]*[-]*[[:space:]]*uses:[[:space:]]*([^[:space:]]+@[^[:space:]]+) ]]; then
                full_action="${BASH_REMATCH[1]}"
                action_name="${full_action%@*}"
                tag="${full_action#*@}"

                # Skip internal BrainXio actions (starting with brainxio/)
                if [[ "$action_name" == brainxio/* ]]; then
                    log "  Skipping internal action: $full_action" >&2
                    echo -n "$line"
                fi

                # Extract the SHA-1 hash for this action
                hash=$(extract_action_hash "$full_action")

                if [[ -n "$hash" ]]; then
                    # Replace the action with its SHA-1 hash
                    # We need to be careful to preserve the exact indentation and formatting
                    new_line="${line/$full_action/$action_name@$hash}"
                    echo -n "$new_line"
                    log "  Pinned $full_action -> $action_name@$hash" >&2
                    ((actions_pinned++))
                    file_modified=1
                else
                    log_warn "  No SHA-1 hash found for $full_action in registry" >&2
                    echo -n "$line"
                fi
            else
                # Output the line unchanged
                echo -n "$line"
            fi
        fi
    } < "$workflow_file" > "$temp_file"

    # If the file was modified, replace the original
    if [[ $file_modified -eq 1 ]]; then
        mv "$temp_file" "$workflow_file"
        ((files_updated++))
        log "  File updated: $(basename "$workflow_file")"
    else
        # No changes made, remove temp file
        rm -f "$temp_file"
    fi
done

log "Summary:"
log "  Files updated: $files_updated"
log "  Actions pinned: $actions_pinned"

if [[ $actions_pinned -gt 0 ]]; then
    log "Successfully pinned external GitHub Actions to SHA-1 hashes!"
else
    log_warn "No external actions were pinned. Check if all actions are already pinned or if there are no external actions."
fi