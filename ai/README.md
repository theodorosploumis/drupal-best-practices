# AI Integration Kit for Drupal Best Practices

This `ai/` directory packages guidance from README sections on Site building and Theming for AI coding tools and validation workflows targeting Drupal 10+.

This repository is configured as a **Claude Code skills repository** containing 10 comprehensive skills for Drupal development, with a complete testing framework for real-time validation.

Contents:
- `AGENTS.md` — authoring instructions for expanding AI assets.
- `skills/` — Claude Code skills with SKILL.md files, examples, and reference documentation.
- `SKILLS-INDEX.md` — index of all available skills.
- `testing/` — comprehensive testing framework with real Drupal config files and validation scripts.
- `rules/` — generic AI rules for any CLI or IDE integration.
- `commands/` — slash commands to load context-specific best practices.
- `scripts/` — validation scripts that support both static YAML analysis and running Drupal instances.
- `utils/` — helper scripts for release management and validation.
- `claude.json` — Claude Code skills repository manifest.

## Installing Skills in Claude Code

### Option 1: Clone the Repository
```bash
# Clone to your local skills directory
git clone https://github.com/theodorosploumis/drupal-best-practices.git ~/.claude/skills/drupal-best-practices

# Or clone to any location and add to Claude Code config
git clone https://github.com/theodorosploumis/drupal-best-practices.git ~/my-skills/drupal-best-practices
```

### Option 2: Add to Claude Code Configuration
Add to your Claude Code config file (`~/.claude/config.json`):
```json
{
  "skillsPaths": [
    "/path/to/drupal-best-practices/ai"
  ]
}
```

### Option 3: Add as Remote Repository
In Claude Code, use:
```
/skills-add https://github.com/theodorosploumis/drupal-best-practices.git
```

## Available Skills

Once installed, you can use these skills:
- `drupal-nodes` - Node bundle modeling and management
- `drupal-blocks` - Custom block types and plugins
- `drupal-fields` - Field design and configuration
- `drupal-forms` - Form building with Webform
- `drupal-taxonomy` - Vocabulary and term structure
- `drupal-views` - View creation and optimization
- `drupal-theming` - Theme development practices
- `drupal-other-content-entities` - Paragraphs, media, and more
- `drupal-text-formats-editors` - Text format configuration
- `drupal-config-parser` - Parse and validate Drupal configuration YAML files

## Testing Framework

The `testing/` directory provides a comprehensive testing framework for validating skills against real Drupal configuration files:

### Features
- **Real Config Files**: Test with actual Drupal YAML configurations
- **Automated Validation**: Python script validates skills randomly or specifically
- **GitHub Actions**: CI/CD pipeline runs tests automatically
- **Cross-Platform**: Works on Linux, macOS, and Windows

### Using the Testing Framework

```bash
# List all available skills
python3 testing/validate.py --list

# Validate a random skill with test configs
python3 testing/validate.py

# Test a specific skill
python3 testing/validate.py --skill nodes

# Test with your own config files
python3 testing/validate.py --config-dir /path/to/your/config
```

### Test Cases Included
- **Good Examples**: Properly configured Drupal entities
- **Bad Examples**: Configurations with intentional violations (for testing validation logic)
- **Edge Cases**: Common Drupal configuration anti-patterns

### GitHub Actions
The repository includes automated testing that:
- Runs on every push and pull request
- Tests all skills daily
- Validates against multiple Python versions
- Generates detailed validation reports

## Development

### Setting Up Development Environment

1. **Clone the repository**:
   ```bash
   git clone https://github.com/theodorosploumis/drupal-best-practices.git
   cd drupal-best-practices/ai
   ```

2. **Install testing dependencies**:
   ```bash
   # Install Python dependencies for testing framework
   pip install -r testing/requirements.txt
   ```

3. **Set up a test Drupal site**:
   ```bash
   # Create a test Drupal installation for validation
   ddev config --project-type drupal10 --docroot web --create-docroot
   ddev start
   ddev composer create drupal/recommended-project
   ddev composer require drush
   ```

### Validating Skills Locally

1. **Validate skill structure**:
   ```bash
   # Check if claude.json is valid
   jq . claude.json

   # Verify all skill directories exist
   ls -la skills/*/
   ```

2. **Run individual skill validators**:
   ```bash
   # From a Drupal project root with Drush
   # If scripts are in ai/scripts/
   ./ai/scripts/validate-nodes.sh
   ./ai/scripts/validate-fields.sh
   ./ai/scripts/validate-views.sh
   # ... etc for all skills

   # Or if you have the scripts in your current directory
   ./validate-nodes.sh
   ./validate-fields.sh
   ./validate-views.sh
   # ... etc for all skills

   # Static validation using YAML files (no Drupal instance needed)
   ./ai/scripts/validate-config.sh --mode static
   ./ai/scripts/validate-nodes.sh --mode static --path config/
   ./ai/scripts/validate-fields.sh --mode static --path web/sites/default/files/config/sync/

   # Auto mode (tries static first, falls back to running instance)
   ./ai/scripts/validate-config.sh  # Auto-detect and validate

   # Or use the testing framework for more comprehensive validation:
   python3 testing/validate.py --skill nodes
   python3 testing/validate.py --config-dir /path/to/your/config
   ```

3. **Test skill content**:
   ```bash
   # Verify each SKILL.md has required frontmatter
   for skill in skills/*/SKILL.md; do
     echo "Checking $skill..."
     head -20 "$skill" | grep -E "^(id|title|summary):"
   done

   # Run comprehensive testing using the testing framework:
   python3 testing/validate.py  # Tests all skills
   python3 testing/validate.py --verbose  # Detailed output
   ```

4. **Test commands** (if using Claude Code locally):
   ```
   /skill drupal-nodes
   /skill drupal-views "Create a view for blog posts"
   ```

## Creating a New Release

### Development Release

1. **Update version numbers**:
   ```bash
   # Update claude.json
   jq '.version = "1.1.0-dev"' claude.json > claude.json.tmp && mv claude.json.tmp claude.json

   # Update individual skill versions
   find skills -name "SKILL.md" -exec sed -i.bak 's/version: [0-9]\+\.[0-9]\+\.[0-9]\+/version: 1.1.0-dev/' {} \;
   ```

2. **Run full validation**:
   ```bash
   # Validate all scripts work
   for script in scripts/*.sh; do
     echo "Testing $script..."
     # Test syntax
     bash -n "$script"
   done
   ```

3. **Test with Claude Code**:
   - Load the skills locally
   - Test each skill with sample prompts
   - Verify examples in each skill work correctly

### Production Release

1. **Create RELEASE.md**:
   ```bash
   cat > RELEASE.md << 'EOF'
   # Drupal Best Practices Skills Release

   ## Version 1.0.0
   Released: $(date +%Y-%m-%d)

   ### New Skills
   - Initial release of 9 Drupal skills
   - Complete validation scripts for all skill areas
   - Comprehensive documentation and examples

   ### Skills Included
   - drupal-nodes (v0.2.0)
   - drupal-blocks (v0.2.0)
   - drupal-fields (v0.2.0)
   - drupal-forms (v0.2.0)
   - drupal-taxonomy (v0.2.0)
   - drupal-views (v0.2.0)
   - drupal-theming (v0.2.0)
   - drupal-other-content-entities (v0.2.0)
   - drupal-text-formats-editors (v0.2.0)

   ### Installation
   See README.md for installation instructions

   ### Known Issues
   - None

   ### Breaking Changes
   - None
   EOF
   ```

2. **Update version for production**:
   ```bash
   # Remove -dev suffix
   jq '.version = "1.0.0"' claude.json > claude.json.tmp && mv claude.json.tmp claude.json

   # Update skill versions
   find skills -name "SKILL.md" -exec sed -i.bak 's/version: [0-9]\+\.[0-9]\+\.[0-9]\+-dev/version: 1.0.0/' {} \;

   # Clean up backup files
   find skills -name "*.bak" -delete
   ```

3. **Create git tag**:
   ```bash
   git add .
   git commit -m "Release v1.0.0"
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin main --tags
   ```

4. **Create GitHub Release**:
   ```bash
   # Using gh CLI
   gh release create v1.0.0 --title "Drupal Best Practices Skills v1.0.0" --notes-file RELEASE.md
   ```

## Adding New Skills

1. **Create skill directory**:
   ```bash
   mkdir skills/my-new-skill
   cd skills/my-new-skill
   ```

2. **Create skill structure**:
   ```
   my-new-skill/
   ├── SKILL.md              # Main skill definition
   ├── reference/
   │   └── README.md         # Reference documentation
   ├── examples/
   │   └── prompt.md         # Example usage
   └── scripts/
       └── README.md         # Validation info
   ```

3. **Add to claude.json**:
   ```json
   {
     "id": "drupal-my-new-skill",
     "name": "Drupal My New Skill",
     "description": "Description of what this skill does",
     "path": "skills/my-new-skill",
     "tags": ["drupal", "category"]
   }
   ```

4. **Create validation script** (if needed):
   ```bash
   # Add to scripts/validate-my-new-skill.sh
   chmod +x scripts/validate-my-new-skill.sh
   ```

## CI/CD and Continuous Validation

This repository includes automated testing to ensure skills remain effective:

### Automated Testing
- **GitHub Actions**: Tests run automatically on every push and pull request
- **Daily Validation**: All skills are tested daily against sample configurations
- **Multi-Python Support**: Tests run across Python 3.8-3.11
- **Validation Reports**: Detailed reports generated for each test run

### Test Coverage
- YAML syntax validation for all configuration files
- Script syntax checking
- DDEV environment detection testing
- Real-world configuration validation
- Naming convention checks
- Best practices compliance

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add or modify skills following the existing structure
4. Test thoroughly:
   ```bash
   # Run tests locally before submitting
   python3 testing/validate.py --verbose

   # Validate your changes
   ./utils/validate.sh
   ```
5. Submit a pull request

## Adding New Test Cases

To improve test coverage:
1. Add real Drupal configuration files to `testing/config/`
2. Include both good and bad examples
3. Update `testing/validate.py` to recognize new patterns
4. Document expected violations in test files

## Usage tips:
- Run scripts from a Drupal project root where Drush is available.
- Pair slash commands with task context (e.g., `/drupal-best-practices-views events_page`).
- Keep new assets tool-agnostic and Drupal 10+ focused.
- Test skills with real-world scenarios before releasing.
- Use the testing framework to validate changes before committing.
