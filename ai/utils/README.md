# Utility Scripts

This directory contains helper scripts for managing the Drupal Best Practices Skills repository.

## Scripts

### release.sh

A comprehensive release automation script that helps generate releases for the skills repository.

#### Features:
- Version bumping for both `claude.json` and all skill files
- Automatic release notes generation
- Git commit and tag creation
- GitHub release creation (using gh CLI)
- Dry-run mode for testing
- Validation before release

#### Usage:

```bash
# Basic usage
./release.sh 1.0.0

# Specify release type (patch/minor/major)
./release.sh 1.1.0 --type minor

# Dry run to see what would happen
./release.sh 1.0.1 --dry-run

# Full release with GitHub integration
./release.sh 2.0.0 --type major --push --github

# Show help
./release.sh --help
```

#### Options:
- `-t, --type TYPE`: Release type (patch/minor/major)
- `-d, --dry-run`: Show what would be done without making changes
- `-s, --skip-validation`: Skip validation steps
- `-p, --push`: Push to git after creating release
- `-g, --github`: Create GitHub release (requires gh CLI)
- `-h, --help`: Show help message

#### Prerequisites:
- Git initialized repository
- jq for JSON manipulation
- Optional: gh CLI for GitHub releases

### validate.sh

A comprehensive validation script that checks the repository for correctness and consistency.

#### Features:
- Repository structure validation
- JSON syntax checking
- Skill frontmatter validation
- Shell script syntax checking
- Consistency checks between `claude.json` and actual files
- Permission verification
- Checks for numbered sections (which should be removed)

#### Usage:

```bash
# Run full validation
./validate.sh

# Show help
./validate.sh --help
```

#### What it validates:
1. **Repository Structure**
   - Required files (claude.json, README.md)
   - Required directories (skills, scripts, rules, commands)

2. **claude.json**
   - Valid JSON syntax
   - Required fields (name, description, version, skills)
   - Skills array consistency

3. **Skills**
   - Each skill has SKILL.md with required frontmatter
   - Optional reference and examples directories
   - Frontmatter ID consistency with directory name

4. **Scripts**
   - Shell script syntax
   - Executable permissions

5. **Markdown Files**
   - No numbered sections (should be removed)
   - Proper formatting

6. **Consistency**
   - All skills in claude.json exist
   - No extra directories not listed in claude.json

## Workflow Examples

### Pre-release Checklist:
```bash
# 1. Validate everything is OK
./validate.sh

# 2. Do a dry run of the release
./release.sh 1.0.0 --dry-run

# 3. If everything looks good, create the release
./release.sh 1.0.0 --push --github
```

### Development Workflow:
```bash
# 1. Make your changes
# 2. Validate before committing
./validate.sh

# 3. Commit changes
git add .
git commit -m "Add new validation features"

# 4. Create development release
./release.sh 1.1.0-dev --type minor

# 5. Test locally
# 6. If ready for production:
./release.sh 1.1.0 --type minor --push --github
```

## Installation

Make sure the scripts are executable:
```bash
chmod +x utils/release.sh
chmod +x utils/validate.sh
```

## Dependencies

### Required:
- `bash` (version 4.0+)
- `jq` for JSON manipulation
- `git` for version control

### Optional for release.sh:
- `gh` (GitHub CLI) for creating GitHub releases

### To install dependencies:
```bash
# On Ubuntu/Debian
sudo apt-get install jq

# On macOS
brew install jq

# GitHub CLI (optional)
# Follow instructions at: https://cli.github.com/
```