#!/bin/bash

# Drupal Best Practices Skills - Validation Script
# This script validates the skills repository for correctness

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repository root (assumes script is run from utils/ directory)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Counters for summary
ERRORS=0
WARNINGS=0
SUCCESSES=0

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((SUCCESSES++))
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
    ((WARNINGS++))
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
    ((ERRORS++))
}

# Validate JSON file
validate_json() {
    local file="$1"
    if jq . "$file" > /dev/null 2>&1; then
        print_success "$file: Valid JSON"
        return 0
    else
        print_error "$file: Invalid JSON"
        return 1
    fi
}

# Check if file exists
check_file_exists() {
    local file="$1"
    local description="$2"

    if [[ -f "$file" ]]; then
        print_success "$description exists: $file"
        return 0
    else
        print_error "$description missing: $file"
        return 1
    fi
}

# Check if directory exists
check_dir_exists() {
    local dir="$1"
    local description="$2"

    if [[ -d "$dir" ]]; then
        print_success "$description exists: $dir"
        return 0
    else
        print_error "$description missing: $dir"
        return 1
    fi
}

# Validate skill frontmatter
validate_skill_frontmatter() {
    local skill_file="$1"
    local skill_dir=$(dirname "$skill_file")
    local skill_name=$(basename "$skill_dir")

    # Check required frontmatter fields
    local required_fields=("id" "title" "summary" "version" "created" "updated" "maintainers" "tags" "source")

    for field in "${required_fields[@]}"; do
        if grep -q "^${field}:" "$skill_file"; then
            continue
        else
            print_error "$skill_name: Missing frontmatter field: $field"
        fi
    done

    # Check if ID matches directory name
    local skill_id=$(grep "^id:" "$skill_file" | cut -d' ' -f2- | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    if [[ "$skill_id" == "drupal-$skill_name" ]] || [[ "$skill_id" == "$skill_name" ]]; then
        print_success "$skill_name: Frontmatter ID is consistent"
    else
        print_warning "$skill_name: Frontmatter ID ($skill_id) doesn't match directory name ($skill_name)"
    fi
}

# Validate skill structure
validate_skill_structure() {
    local skill_dir="$1"
    local skill_name=$(basename "$skill_dir")

    # Required files/directories
    check_file_exists "$skill_dir/SKILL.md" "$skill_name/SKILL.md"

    # Optional but recommended
    if [[ -d "$skill_dir/reference" ]]; then
        if [[ -f "$skill_dir/reference/README.md" ]]; then
            print_success "$skill_name: Has reference documentation"
        else
            print_warning "$skill_name: Reference directory exists but no README.md"
        fi
    else
        print_warning "$skill_name: No reference directory"
    fi

    if [[ -d "$skill_dir/examples" ]]; then
        if [[ -f "$skill_dir/examples/prompt.md" ]]; then
            print_success "$skill_name: Has example prompts"
        else
            print_warning "$skill_name: Examples directory exists but no prompt.md"
        fi
    else
        print_warning "$skill_name: No examples directory"
    fi
}

# Validate shell script syntax
validate_shell_scripts() {
    local scripts_dir="$1"

    find "$scripts_dir" -name "*.sh" -type f | while read -r script; do
        if bash -n "$script" 2>/dev/null; then
            print_success "Script syntax OK: $(basename "$script")"
        else
            print_error "Script syntax error: $(basename "$script")"
        fi
    done
}

# Check for numbered sections in markdown files
check_numbered_sections() {
    local file="$1"

    # Look for patterns like "2.1", "§2.1", "Section 2.1"
    if grep -qE "§\d+(\.\d+)?|(\d+\.)+\d+|\bSection\s+\d+(\.\d+)?" "$file"; then
        print_warning "$(basename "$file"): Contains numbered sections that should be removed"
    else
        print_success "$(basename "$file"): No numbered sections found"
    fi
}

# Validate consistency between claude.json and actual skills
validate_skill_consistency() {
    print_info "Validating skill consistency..."

    # Get skills from claude.json
    local json_skills=($(jq -r '.skills[].path' claude.json 2>/dev/null || echo ""))

    # Get actual skill directories
    local actual_dirs=($(find claude-skills -maxdepth 1 -type d -not -path "claude-skills" | sed 's|claude-skills/||' | sort))

    # Check each skill in claude.json exists
    for skill_path in "${json_skills[@]}"; do
        if [[ -d "$skill_path" ]]; then
            print_success "Skill directory exists: $skill_path"
        else
            print_error "Skill in claude.json but missing: $skill_path"
        fi
    done

    # Check for skill directories not in claude.json
    for dir in "${actual_dirs[@]}"; do
        if [[ -n "$dir" ]]; then
            local found=false
            for skill_path in "${json_skills[@]}"; do
                if [[ "claude-skills/$dir" == "$skill_path" ]]; then
                    found=true
                    break
                fi
            done
            if [[ "$found" == "false" ]]; then
                print_warning "Skill directory exists but not in claude.json: claude-skills/$dir"
            fi
        fi
    done
}

# Main validation
main() {
    print_info "Starting validation of Drupal Best Practices Skills repository"
    echo "=================================================="

    # 1. Check repository structure
    print_info "\n1. Checking repository structure..."
    check_file_exists "claude.json" "Claude manifest"
    check_file_exists "README.md" "Repository README"
    check_dir_exists "claude-skills" "Skills directory"
    check_dir_exists "scripts" "Scripts directory"
    check_dir_exists "rules" "Rules directory"
    check_dir_exists "commands" "Commands directory"

    # 2. Validate claude.json
    print_info "\n2. Validating claude.json..."
    if validate_json "claude.json"; then
        # Check required fields
        local required_json_fields=("name" "description" "version" "skills")
        for field in "${required_json_fields[@]}"; do
            if jq -e ".${field}" claude.json > /dev/null 2>&1; then
                print_success "claude.json has field: $field"
            else
                print_error "claude.json missing field: $field"
            fi
        done

        # Check skills array
        local skill_count=$(jq '.skills | length' claude.json 2>/dev/null || echo "0")
        print_info "Found $skill_count skills in claude.json"
    fi

    # 3. Validate skills
    print_info "\n3. Validating skills..."
    if [[ -d "claude-skills" ]]; then
        find claude-skills -maxdepth 2 -name "SKILL.md" -type f | while read -r skill_file; do
            validate_skill_frontmatter "$skill_file"
            validate_skill_structure "$(dirname "$skill_file")"
        done
    fi

    # 4. Validate scripts
    print_info "\n4. Validating scripts..."
    if [[ -d "scripts" ]]; then
        validate_shell_scripts "scripts"
    fi

    # 5. Check for numbered sections
    print_info "\n5. Checking for numbered sections in markdown files..."
    find . -name "*.md" -not -path "./node_modules/*" | while read -r md_file; do
        check_numbered_sections "$md_file"
    done

    # 6. Validate skill consistency
    print_info "\n6. Validating skill consistency..."
    validate_skill_consistency

    # 7. Check permissions
    print_info "\n7. Checking file permissions..."
    find scripts -name "*.sh" -type f | while read -r script; do
        if [[ -x "$script" ]]; then
            print_success "Script is executable: $(basename "$script")"
        else
            print_warning "Script is not executable: $(basename "$script") (run chmod +x)"
        fi
    done

    # Summary
    echo "\n=================================================="
    print_info "Validation Summary:"
    echo -e "  ${GREEN}Successes: $SUCCESSES${NC}"
    echo -e "  ${YELLOW}Warnings: $WARNINGS${NC}"
    echo -e "  ${RED}Errors: $ERRORS${NC}"

    if [[ $ERRORS -gt 0 ]]; then
        print_error "\nValidation failed with $ERRORS error(s)!"
        exit 1
    elif [[ $WARNINGS -gt 0 ]]; then
        print_warning "\nValidation passed with $WARNINGS warning(s)"
        exit 0
    else
        print_success "\nValidation passed successfully!"
        exit 0
    fi
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat << EOF
Drupal Best Practices Skills - Validation Script

Usage: $0 [OPTIONS]

Options:
    -h, --help    Show this help message

This script validates:
- Repository structure
- JSON syntax and required fields
- Skill frontmatter and structure
- Script syntax
- File permissions
- Consistency between claude.json and actual files

EOF
    exit 0
fi

# Run validation
main