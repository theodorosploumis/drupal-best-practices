#!/bin/bash

# Drupal Best Practices Skills - Release Helper Script
# This script helps generate releases for the Drupal skills repository

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
RELEASE_TYPE="patch"
DRY_RUN=false
SKIP_VALIDATION=false
PUSH_TO_GITHUB=false
CREATE_GITHUB_RELEASE=false

# Repository root (assumes script is run from utils/ directory)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show usage
usage() {
    cat << EOF
Drupal Best Practices Skills - Release Helper

Usage: $0 [OPTIONS] VERSION

Arguments:
    VERSION            Version number (e.g., 1.0.0, 1.2.3)

Options:
    -t, --type TYPE    Release type: patch, minor, major (default: patch)
    -d, --dry-run      Show what would be done without making changes
    -s, --skip-skip    Skip validation steps
    -p, --push         Push to git after creating release
    -g, --github       Create GitHub release (requires gh CLI)
    -h, --help         Show this help message

Examples:
    $0 1.0.0                    # Create release 1.0.0
    $0 1.1.0 -t minor           # Create minor release 1.1.0
    $0 1.0.1 -t patch -d        # Dry run for patch release
    $0 2.0.0 -t major -p -g     # Create major release and push to GitHub

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            RELEASE_TYPE="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -s|--skip-validation)
            SKIP_VALIDATION=true
            shift
            ;;
        -p|--push)
            PUSH_TO_GITHUB=true
            shift
            ;;
        -g|--github)
            CREATE_GITHUB_RELEASE=true
            PUSH_TO_GITHUB=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            print_error "Unknown option $1"
            usage
            exit 1
            ;;
        *)
            VERSION="$1"
            shift
            ;;
    esac
done

# Validate version format
validate_version() {
    if [[ ! $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format: $VERSION (use format: X.Y.Z)"
        exit 1
    fi
}

# Get current version from claude.json
get_current_version() {
    if [[ -f "claude.json" ]]; then
        jq -r '.version' claude.json 2>/dev/null || echo "0.0.0"
    else
        print_error "claude.json not found!"
        exit 1
    fi
}

# Validate the repository structure
validate_repository() {
    print_info "Validating repository structure..."

    # Check required files
    local required_files=(
        "claude.json"
        "README.md"
    )

    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required file not found: $file"
            exit 1
        fi
    done

    # Validate JSON syntax
    if ! jq . claude.json > /dev/null 2>&1; then
        print_error "Invalid JSON in claude.json"
        exit 1
    fi

    # Check skill directories
    local skills=($(jq -r '.skills[].path' claude.json))
    for skill_path in "${skills[@]}"; do
        if [[ ! -d "$skill_path" ]]; then
            print_error "Skill directory not found: $skill_path"
            exit 1
        fi
        if [[ ! -f "$skill_path/SKILL.md" ]]; then
            print_error "SKILL.md not found in: $skill_path"
            exit 1
        fi
    done

    print_success "Repository structure validation passed"
}

# Validate all scripts
validate_scripts() {
    print_info "Validating all scripts..."

    # Check syntax of all shell scripts
    find scripts -name "*.sh" -type f | while read -r script; do
        if ! bash -n "$script" 2>/dev/null; then
            print_error "Syntax error in script: $script"
            exit 1
        fi
    done

    print_success "All scripts passed validation"
}

# Update version numbers
update_versions() {
    local new_version="$1"

    print_info "Updating version to $new_version..."

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would update claude.json version to $new_version"
        print_info "[DRY RUN] Would update all SKILL.md files to version $new_version"
        return
    fi

    # Update claude.json
    jq ".version = \"$new_version\"" claude.json > claude.json.tmp && mv claude.json.tmp claude.json

    # Update all SKILL.md files
    find claude-skills -name "SKILL.md" -type f | while read - skill_file; do
        # Create backup
        cp "$skill_file" "$skill_file.bak"
        # Update version
        sed -i "s/^version: .*/version: $new_version/" "$skill_file"
        # Remove backup if successful
        rm "$skill_file.bak"
    done

    print_success "Version numbers updated to $new_version"
}

# Generate RELEASE.md
generate_release_notes() {
    local version="$1"
    local release_file="RELEASE.md"

    print_info "Generating release notes..."

    # Get previous version for comparison
    local prev_version=$(get_current_version)

    # Get list of skills with their versions
    local skills_list=""
    local skills=($(jq -r '.skills[] | "\(.id)|\(.name)"' claude.json))
    for skill_info in "${skills[@]}"; do
        local skill_id=$(echo "$skill_info" | cut -d'|' -f1)
        local skill_name=$(echo "$skill_info" | cut -d'|' -f2)
        skills_list="$skills_list- $skill_id (v$version)\n"
    done

    # Determine release type description
    local type_description=""
    case $RELEASE_TYPE in
        major)
            type_description="Major release with breaking changes"
            ;;
        minor)
            type_description="Minor release with new features"
            ;;
        patch)
            type_description="Patch release with bug fixes"
            ;;
    esac

    # Create release notes
    cat > "$release_file" << EOF
# Drupal Best Practices Skills Release

## Version $version
Released: $(date +%Y-%m-%d)
Type: $type_description

### Skills Included
$(echo -e "$skills_list")

### Installation
See README.md for installation instructions

### Changes
- $type_description
- Updated all skills to version $version

EOF

    # Add git commit history if git is available
    if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
        # Get commits since last tag (if exists)
        local last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
        if [[ -n "$last_tag" ]]; then
            echo -e "\n### Git History\n" >> "$release_file"
            git log --pretty=format:"- %s (%h)" "$last_tag"..HEAD 2>/dev/null >> "$release_file" || true
        fi
    fi

    echo -e "\n### Known Issues\n- None\n" >> "$release_file"
    echo -e "\n### Breaking Changes\n- None\n" >> "$release_file"

    print_success "Release notes generated in $release_file"
}

# Create git commit and tag
create_git_release() {
    local version="$1"

    print_info "Creating git commit and tag..."

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would add all changes to git"
        print_info "[DRY RUN] Would commit: Release v$version"
        print_info "[DRY RUN] Would create tag: v$version"
        return
    fi

    # Add changes
    git add .

    # Commit
    git commit -m "Release v$version

- Update version to $version
- Update all skills to version $version
- Generate release notes"

    # Create tag
    git tag -a "v$version" -m "Release v$version"

    print_success "Git commit and tag created"
}

# Push to GitHub
push_to_github() {
    local version="$1"

    print_info "Pushing to GitHub..."

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would push to origin with tags"
        return
    fi

    # Push commits and tags
    git push origin main --tags

    print_success "Pushed to GitHub"
}

# Create GitHub release
create_github_release() {
    local version="$1"

    if ! command -v gh >/dev/null 2>&1; then
        print_error "GitHub CLI (gh) not installed. Please install it to create GitHub releases."
        print_info "Visit: https://cli.github.com/"
        exit 1
    fi

    print_info "Creating GitHub release..."

    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Would create GitHub release v$version"
        return
    fi

    # Create release using gh CLI
    gh release create "v$version" \
        --title "Drupal Best Practices Skills v$version" \
        --notes-file "RELEASE.md"

    print_success "GitHub release created"
}

# Main execution
main() {
    # Check if version provided
    if [[ -z "$VERSION" ]]; then
        print_error "Version number is required"
        usage
        exit 1
    fi

    validate_version

    print_info "Starting release process for version $VERSION (type: $RELEASE_TYPE)"

    if [[ "$DRY_RUN" == "true" ]]; then
        print_warning "DRY RUN MODE - No changes will be made"
    fi

    # Change to repo root if not already there
    cd "$REPO_ROOT"

    # Run validations
    if [[ "$SKIP_VALIDATION" == "false" ]]; then
        validate_repository
        validate_scripts
    else
        print_warning "Skipping validation steps"
    fi

    # Get current version
    local current_version=$(get_current_version)
    print_info "Current version: $current_version"
    print_info "New version: $VERSION"

    # Confirm release
    if [[ "$DRY_RUN" == "false" ]]; then
        echo
        read -p "Continue with release? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Release cancelled"
            exit 0
        fi
    fi

    # Update versions
    update_versions "$VERSION"

    # Generate release notes
    generate_release_notes "$VERSION"

    # Create git release
    create_git_release "$VERSION"

    # Push to GitHub if requested
    if [[ "$PUSH_TO_GITHUB" == "true" ]]; then
        push_to_github "$VERSION"
    fi

    # Create GitHub release if requested
    if [[ "$CREATE_GITHUB_RELEASE" == "true" ]]; then
        create_github_release "$VERSION"
    fi

    print_success "Release $VERSION completed successfully!"

    if [[ "$DRY_RUN" == "false" ]]; then
        echo
        print_info "Next steps:"
        echo "  1. Review the generated RELEASE.md file"
        echo "  2. Test the release locally"
        if [[ "$PUSH_TO_GITHUB" == "false" ]]; then
            echo "  3. Push to GitHub: git push origin main --tags"
        fi
        if [[ "$CREATE_GITHUB_RELEASE" == "false" ]]; then
            echo "  4. Create GitHub release manually or run with -g flag"
        fi
    fi
}

# Run main function
main "$@"