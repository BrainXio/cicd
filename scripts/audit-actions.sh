#!/usr/bin/env bash
# Audit external GitHub Actions in workflow files
# Scans all workflow files and identifies external actions using version tags

set -euo pipefail

# Default output file
OUTPUT_FILE="action-hashes.md"
WORKFLOW_DIR=".github/workflows"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --workflow-dir)
            WORKFLOW_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--output FILE] [--workflow-dir DIR]"
            echo ""
            echo "Audit external GitHub Actions in workflow files."
            echo ""
            echo "Options:"
            echo "  --output FILE       Output file for action registry (default: action-hashes.md)"
            echo "  --workflow-dir DIR  Directory containing workflow files (default: .github/workflows)"
            echo "  -h, --help          Show this help message"
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            exit 1
            ;;
    esac
done

# Check if workflow directory exists
if [ ! -d "$WORKFLOW_DIR" ]; then
    echo "Error: Workflow directory '$WORKFLOW_DIR' not found" >&2
    exit 1
fi

# Find all workflow files
WORKFLOW_FILES=()
while IFS= read -r -d '' file; do
    WORKFLOW_FILES+=("$file")
done < <(find "$WORKFLOW_DIR" -type f \( -name "*.yml" -o -name "*.yaml" \) -print0)

if [ ${#WORKFLOW_FILES[@]} -eq 0 ]; then
    echo "No workflow files found in '$WORKFLOW_DIR'" >&2
    exit 1
fi

# Collect external actions
declare -A ACTIONS
declare -A ACTION_LOCATIONS

for workflow_file in "${WORKFLOW_FILES[@]}"; do
    while IFS= read -r line; do
        # Extract uses: line (with or without leading dash)
        if [[ "$line" =~ ^[[:space:]]*-?[[:space:]]*uses:[[:space:]]+([^[:space:]]+) ]]; then
            action_ref="${BASH_REMATCH[1]}"

            # Skip internal actions (starting with ./)
            if [[ "$action_ref" =~ ^\./ ]]; then
                continue
            fi

            # Extract action name and version
            if [[ "$action_ref" =~ ^([^@]+)@(.+)$ ]]; then
                action_name="${BASH_REMATCH[1]}"
                version="${BASH_REMATCH[2]}"

                # Store action and location
                ACTIONS["$action_name@$version"]="$version"
                ACTION_LOCATIONS["$action_name@$version"]+="$workflow_file"$'\n'
            fi
        fi
    done < "$workflow_file"
done

# Print results to stdout
ACTION_COUNT=0
for key in "${!ACTIONS[@]}"; do
    ACTION_COUNT=$((ACTION_COUNT + 1))
done

if [ "$ACTION_COUNT" -eq 0 ]; then
    echo "No external actions found in workflow files"
else
    echo "Found $ACTION_COUNT external action(s):"
    echo ""
    for key in "${!ACTIONS[@]}"; do
        action_name="${key%@*}"
        version="${ACTIONS[$key]}"
        locations="${ACTION_LOCATIONS[$key]}"

        echo "Action: $action_name"
        echo "Version: $version"
        echo "Locations:"
        while IFS= read -r location; do
            echo "  - $location"
        done <<< "$locations"
        echo ""
    done
fi

# Generate action registry document
cat > "$OUTPUT_FILE" << 'EOF'
# GitHub Actions Registry

This document tracks all external GitHub Actions used in workflows with their SHA-1 commit hashes.

## External Actions

EOF

if [ "$ACTION_COUNT" -eq 0 ]; then
    echo "No external actions found." >> "$OUTPUT_FILE"
else
    for key in "${!ACTIONS[@]}"; do
        action_name="${key%@*}"
        version="${ACTIONS[$key]}"

        cat >> "$OUTPUT_FILE" << EOF
### $action_name@$version

- **Action**: $action_name
- **Version Tag**: $version
- **SHA-1 Hash**: *Not yet looked up*
- **Update Date**: *Not yet updated*
- **Security Audit**: *Pending*

EOF
    done
fi

echo "Action registry written to: $OUTPUT_FILE"

exit 0