#!/usr/bin/env bash

# Drupal Configuration Validation Script
# Validates Drupal configuration YAML files against best practices

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the DDEV Drush helper (for backwards compatibility)
source "$SCRIPT_DIR/ddev-drush-helper.sh"

# Default configuration paths
DEFAULT_CONFIG_PATHS=(
    "config"
    "web/sites/default/files/config"
    "web/sites/default/files/config/sync"
    ".ddev/config"
)

# Validation modes
MODE=${MODE:-"auto"}  # auto, static, running
CONFIG_PATH=${CONFIG_PATH:-""}
SPECIFIC_FILE=${SPECIFIC_FILE:-""}
VALIDATION_TYPE=${VALIDATION_TYPE:-"all"}  # all, naming, structure, dependencies

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
INFO=0

# Print functions
print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    ((INFO++))
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Show usage
usage() {
    cat << EOF
Drupal Configuration Validation Script

Usage: $0 [OPTIONS]

OPTIONS:
    -m, --mode MODE         Validation mode: auto, static, running (default: auto)
    -p, --path PATH         Config directory path (default: auto-detect)
    -f, --file FILE         Specific config file to validate
    -t, --type TYPE         Validation type: all, naming, structure, dependencies (default: all)
    -h, --help              Show this help message

MODES:
    auto      - Try static validation first, fallback to running instance
    static    - Validate YAML files only (no Drupal instance needed)
    running   - Validate using running Drupal instance (DDEV aware)

EXAMPLES:
    $0                                    # Auto-detect and validate
    $0 -m static                           # Static validation only
    $0 -p /path/to/config                  # Validate specific directory
    $0 -f node.type.article.yml            # Validate specific file
    $0 -t naming                           # Validate naming conventions only

EOF
}

# Check if yq is available (YAML processor)
check_yq() {
    if ! command -v yq >/dev/null 2>&1; then
        print_warning "yq not found. Installing yq will provide better validation."
        print_info "Install yq from: https://github.com/mikefarah/yq#install"
        return 1
    fi
    return 0
}

# Find configuration directory
find_config_directory() {
    local config_dir=""

    # Try default paths
    for path in "${DEFAULT_CONFIG_PATHS[@]}"; do
        if [[ -d "$path" ]] && [[ -n "$(find "$path" -name "*.yml" -type f 2>/dev/null | head -1)" ]]; then
            config_dir="$path"
            break
        fi
    done

    # Check for Composer-based Drupal project
    if [[ -z "$config_dir" ]] && [[ -f "composer.json" ]]; then
        # Check if config_sync_directory is defined
        if command -v jq >/dev/null 2>&1; then
            local sync_dir=$(jq -r '.extra["drupal-scaffold"]["locations"]["web"] // "web"' composer.json 2>/dev/null || echo "web")
            if [[ -d "${sync_dir}/sites/default/files/config/sync" ]]; then
                config_dir="${sync_dir}/sites/default/files/config/sync"
            fi
        fi
    fi

    echo "$config_dir"
}

# Validate YAML syntax
validate_yaml_syntax() {
    local file="$1"

    if command -v python3 >/dev/null 2>&1; then
        if ! python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
            print_error "$file: Invalid YAML syntax"
            return 1
        fi
    elif check_yq; then
        if ! yq eval '.' "$file" >/dev/null 2>&1; then
            print_error "$file: Invalid YAML syntax"
            return 1
        fi
    else
        print_warning "Cannot validate YAML syntax without yq or python3"
    fi

    return 0
}

# Extract value from YAML
extract_yaml_value() {
    local file="$1"
    local key="$2"
    local default="${3:-}"

    if check_yq; then
        yq eval ".$key // \"$default\"" "$file" 2>/dev/null | tr -d '"'
    else
        # Fallback to grep/sed for basic values
        grep -E "^\s*$key:" "$file" | sed -E "s/^\s*$key:\s*//" | head -1
    fi
}

# Validate node type configuration
validate_node_type() {
    local file="$1"
    local basename=$(basename "$file")
    local machine_name=$(echo "$basename" | sed 's/^node\.type\.//' | sed 's/\.yml$//')

    print_info "Validating node type: $machine_name"

    # Check machine name format
    if [[ ! "$machine_name" =~ ^[a-z0-9_]+$ ]]; then
        print_error "$machine_name: Machine name contains invalid characters"
    fi

    # Check for plural names
    local label=$(extract_yaml_value "$file" "label")
    if [[ "$label" =~ s$ && ! "$label" =~ ^(news|series)$ ]]; then
        print_warning "$machine_name: Label '$label' appears to be plural"
    fi

    # Check for description
    local description=$(extract_yaml_value "$file" "description")
    if [[ -z "$description" || "$description" == "null" ]]; then
        print_warning "$machine_name: Missing description"
    fi

    # Check for unwanted status
    local status=$(extract_yaml_value "$file" "status")
    if [[ "$status" == "true" ]]; then
        print_warning "$machine_name: Node type is published by default"
    fi
}

# Validate field configuration
validate_field() {
    local file="$1"
    local basename=$(basename "$file")
    local field_name=$(echo "$basename" | sed -E 's/^field\.field\.[^.]+\.[^.]+\.(.+)\.yml$/\1/')

    print_info "Validating field: $field_name"

    # Check field naming pattern
    if [[ ! "$field_name" =~ ^field_[a-z0-9_]+$ ]]; then
        print_error "$field_name: Field name doesn't follow field_* pattern"
    fi

    # Check for required settings
    local field_type=$(extract_yaml_value "$file" "field_type")
    if [[ -z "$field_type" || "$field_type" == "null" ]]; then
        print_error "$field_name: Missing field_type"
    fi

    # Check for description
    local description=$(extract_yaml_value "$file" "description")
    if [[ -z "$description" || "$description" == "null" ]]; then
        print_warning "$field_name: Missing field description"
    fi
}

# Validate view configuration
validate_view() {
    local file="$1"
    local basename=$(basename "$file")
    local view_name=$(echo "$basename" | sed 's/^views\.view\.//' | sed 's/\.yml$//')

    print_info "Validating view: $view_name"

    # Check for _1 suffix (common issue)
    if [[ "$view_name" =~ _1$ ]]; then
        print_error "$view_name: View name ends with _1, use more descriptive name"
    fi

    # Check for description
    local description=$(extract_yaml_value "$file" "description")
    if [[ -z "$description" || "$description" == "null" ]]; then
        print_warning "$view_name: Missing view description"
    fi

    # Check for tag
    local tag=$(extract_yaml_value "$file" "tag")
    if [[ -z "$tag" || "$tag" == "null" ]]; then
        print_warning "$view_name: Missing view tag for better organization"
    fi
}

# Validate block configuration
validate_block() {
    local file="$1"
    local basename=$(basename "$file")
    local block_id=$(echo "$basename" | sed 's/^block\.block\.//' | sed 's/\.yml$//')

    print_info "Validating block: $block_id"

    # Check for system blocks that should be in code
    if [[ "$block_id" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
        print_error "$block_id: Block uses UUID, should have a machine name"
    fi

    # Check for theme dependency
    local theme=$(extract_yaml_value "$file" "theme")
    if [[ "$theme" =~ ^(bartik|seven|stable)$ ]]; then
        print_warning "$block_id: Block uses default theme '$theme'"
    fi
}

# Validate vocabulary configuration
validate_vocabulary() {
    local file="$1"
    local basename=$(basename "$file")
    local vocab_name=$(echo "$basename" | sed 's/^taxonomy\.vocabulary\.//' | sed 's/\.yml$//')

    print_info "Validating vocabulary: $vocab_name"

    # Check machine name format
    if [[ ! "$vocab_name" =~ ^[a-z0-9_]+$ ]]; then
        print_error "$vocab_name: Vocabulary machine name contains invalid characters"
    fi

    # Check for description
    local description=$(extract_yaml_value "$file" "description")
    if [[ -z "$description" || "$description" == "null" ]]; then
        print_warning "$vocab_name: Missing vocabulary description"
    fi

    # Check if it should be a list field instead
    # (This is a heuristic - vocabularies for categorization vs simple lists)
    local label=$(extract_yaml_value "$file" "name")
    if [[ "$label" =~ ^(Status|State|Type|Category)$ ]]; then
        print_info "$vocab_name: Consider if this could be a list field instead of taxonomy"
    fi
}

# Run static validation
run_static_validation() {
    local config_path="$1"

    print_info "Running static configuration validation on: $config_path"

    # Find all YAML files
    local yml_files=()
    while IFS= read -r -d '' file; do
        yml_files+=("$file")
    done < <(find "$config_path" -name "*.yml" -type f -print0 2>/dev/null)

    if [[ ${#yml_files[@]} -eq 0 ]]; then
        print_error "No YAML files found in $config_path"
        return 1
    fi

    print_info "Found ${#yml_files[@]} configuration files"

    # Validate each file
    for file in "${yml_files[@]}"; do
        # Validate YAML syntax first
        if ! validate_yaml_syntax "$file"; then
            continue
        fi

        # Validate based on file type
        case "$file" in
            */node.type.*.yml)
                if [[ "$VALIDATION_TYPE" == "all" || "$VALIDATION_TYPE" == "naming" || "$VALIDATION_TYPE" == "structure" ]]; then
                    validate_node_type "$file"
                fi
                ;;
            */field.field.*.yml)
                if [[ "$VALIDATION_TYPE" == "all" || "$VALIDATION_TYPE" == "naming" || "$VALIDATION_TYPE" == "structure" ]]; then
                    validate_field "$file"
                fi
                ;;
            */views.view.*.yml)
                if [[ "$VALIDATION_TYPE" == "all" || "$VALIDATION_TYPE" == "naming" ]]; then
                    validate_view "$file"
                fi
                ;;
            */block.block.*.yml)
                if [[ "$VALIDATION_TYPE" == "all" || "$VALIDATION_TYPE" == "naming" || "$VALIDATION_TYPE" == "structure" ]]; then
                    validate_block "$file"
                fi
                ;;
            */taxonomy.vocabulary.*.yml)
                if [[ "$VALIDATION_TYPE" == "all" || "$VALIDATION_TYPE" == "naming" || "$VALIDATION_TYPE" == "structure" ]]; then
                    validate_vocabulary "$file"
                fi
                ;;
        esac
    done
}

# Run validation on specific file
validate_specific_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        print_error "File not found: $file"
        return 1
    fi

    print_info "Validating specific file: $file"

    # Validate YAML syntax
    if ! validate_yaml_syntax "$file"; then
        return 1
    fi

    # Validate based on file type
    case "$file" in
        */node.type.*.yml)
            validate_node_type "$file"
            ;;
        */field.field.*.yml)
            validate_field "$file"
            ;;
        */views.view.*.yml)
            validate_view "$file"
            ;;
        */block.block.*.yml)
            validate_block "$file"
            ;;
        */taxonomy.vocabulary.*.yml)
            validate_vocabulary "$file"
            ;;
        *)
            print_info "File type not specifically validated: $(basename "$file")"
            print_success "File has valid YAML syntax"
            ;;
    esac
}

# Check if Drupal is running and accessible
check_drupal_running() {
    if check_drush; then
        if run_drush status >/dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

# Fallback to running instance validation
fallback_to_running_validation() {
    print_info "Falling back to running Drupal instance validation"

    # Run appropriate existing validation scripts
    case "$VALIDATION_TYPE" in
        naming|all)
            # Run node type validation
            if [[ -f "$SCRIPT_DIR/validate_nodes.sh" ]]; then
                print_info "Running node type validation..."
                "$SCRIPT_DIR/validate_nodes.sh"
            fi
            ;;
        *)
            print_warning "Running validation not implemented for type: $VALIDATION_TYPE"
            ;;
    esac
}

# Main execution
main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -m|--mode)
                MODE="$2"
                shift 2
                ;;
            -p|--path)
                CONFIG_PATH="$2"
                shift 2
                ;;
            -f|--file)
                SPECIFIC_FILE="$2"
                shift 2
                ;;
            -t|--type)
                VALIDATION_TYPE="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                print_error "Unexpected argument: $1"
                usage
                exit 1
                ;;
        esac
    done

    print_info "Drupal Configuration Validation - Mode: $MODE, Type: $VALIDATION_TYPE"

    # Handle specific file validation
    if [[ -n "$SPECIFIC_FILE" ]]; then
        validate_specific_file "$SPECIFIC_FILE"
        print_summary
        exit $((ERRORS > 0 ? 1 : 0))
    fi

    # Determine config path
    if [[ -z "$CONFIG_PATH" ]]; then
        CONFIG_PATH=$(find_config_directory)
        if [[ -z "$CONFIG_PATH" ]]; then
            print_error "No configuration directory found"
            print_info "Use -p to specify a path, or ensure you're in a Drupal project"
            exit 1
        fi
    fi

    # Check if config directory exists
    if [[ ! -d "$CONFIG_PATH" ]]; then
        print_error "Configuration directory not found: $CONFIG_PATH"
        exit 1
    fi

    # Run validation based on mode
    case "$MODE" in
        static)
            run_static_validation "$CONFIG_PATH"
            ;;
        running)
            if check_drupal_running; then
                fallback_to_running_validation
            else
                print_error "Drupal is not running or accessible"
                exit 1
            fi
            ;;
        auto)
            if [[ -n "$(find "$CONFIG_PATH" -name "*.yml" -type f 2>/dev/null | head -1)" ]]; then
                run_static_validation "$CONFIG_PATH"
            elif check_drupal_running; then
                fallback_to_running_validation
            else
                print_error "No config files found and Drupal is not running"
                exit 1
            fi
            ;;
        *)
            print_error "Invalid mode: $MODE"
            usage
            exit 1
            ;;
    esac
}

# Print summary
print_summary() {
    echo
    echo "=== Validation Summary ==="
    print_success "Validations completed: $INFO"
    if [[ $WARNINGS -gt 0 ]]; then
        print_warning "Warnings found: $WARNINGS"
    fi
    if [[ $ERRORS -gt 0 ]]; then
        print_error "Errors found: $ERRORS"
    fi
    echo "========================="
}

# Run main function
main "$@"

# Print summary and exit with appropriate code
print_summary
exit $((ERRORS > 0 ? 1 : 0))