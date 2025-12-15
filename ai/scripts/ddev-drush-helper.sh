#!/bin/bash

# DDEV Drush Helper
# This script provides functions to detect DDEV environment and use appropriate Drush command

# Function to detect if we're in a DDEV environment
is_ddev_environment() {
    # Check if DDEV is installed and we're in a DDEV project
    if command -v ddev >/dev/null 2>&1; then
        # Check if we're in a DDEV project directory (look for .ddev/config.yaml)
        if [[ -f ".ddev/config.yaml" ]] || ddev describe >/dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

# Function to get the appropriate Drush command
get_drush_command() {
    if is_ddev_environment; then
        echo "ddev drush"
    else
        # Check if local drush is available
        if command -v drush >/dev/null 2>&1; then
            echo "drush"
        else
            # Try to find drush in vendor/bin (common in Composer projects)
            if [[ -f "vendor/bin/drush" ]]; then
                echo "./vendor/bin/drush"
            else
                echo "drush"  # Default, will fail with a clear error
            fi
        fi
    fi
}

# Function to run Drush with appropriate command
run_drush() {
    local drush_cmd=$(get_drush_command)

    # Check if the command exists
    if [[ "$drush_cmd" == "drush" ]] && ! command -v drush >/dev/null 2>&1; then
        echo "[error] Drush not found. Please install Drush or ensure you're in a DDEV environment." >&2
        exit 1
    fi

    # Run the command with all arguments
    $drush_cmd "$@"
}

# Function to check if Drush is available (with DDEV support)
check_drush() {
    if is_ddev_environment; then
        # In DDEV, we assume ddev drush will work
        return 0
    else
        # Outside DDEV, check for local drush
        command -v drush >/dev/null 2>&1 || {
            echo "[error] Drush not found. Install drush or run within a DDEV project." >&2
            exit 1
        }
    fi
}

# Export functions if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f is_ddev_environment
    export -f get_drush_command
    export -f run_drush
    export -f check_drush
fi