# Testing Framework for Drupal Skills

This document explains the testing framework setup for validating Drupal skills.

## Components

### 1. Testing Directory Structure
```
ai/testing/
├── README.md          # Testing documentation
├── SETUP.md           # This file
├── validate.py        # Python validation script
├── config/            # Test configuration files
│   ├── node.type.article.yml      # Good example (article)
│   ├── node.type.pages.yml        # Good example (pages)
│   ├── views.view.articles_1.yml   # Bad example (_1 suffix)
│   ├── field.field.node.article.field_tags.yml  # Good field example
│   └── bad-examples/             # Directory for bad config examples
│       └── node.type.news_articles.yml  # Bad example (plural, no desc)
└── .github/workflows/              # GitHub Actions (in root)
    └── validate-skills.yml         # CI/CD workflow
```

### 2. Python Validation Script (`validate.py`)

Features:
- Lists all available skills from SKILL.md files
- Validates skills against real Drupal configuration files
- Supports both specific skill validation and random selection
- Analyzes expected violations in bad examples
- Cross-platform compatibility (Linux, macOS, Windows)

Usage:
```bash
# List all skills
python3 testing/validate.py --list

# Validate random skill
python3 testing/validate.py

# Validate specific skill
python3 testing/validate.py --skill nodes

# Use custom config directory
python3 testing/validate.py --config-dir /path/to/config
```

### 3. GitHub Actions Workflow (`.github/workflows/validate-skills.yml`)

Automated validation that runs on:
- Push to main/master branch
- Pull requests
- Daily schedule (2 AM UTC)
- Manual workflow dispatch

The workflow:
1. Validates repository structure
2. Runs multiple random skill validations
3. Tests each skill individually
4. Validates with bad examples
5. Checks script syntax
6. Validates JSON/YAML files
7. Tests DDEV helper functionality
8. Generates validation report

## Test Cases Included

### Good Examples:
- `node.type.article.yml` - Proper node type with description
- `node.type.pages.yml` - Static page content type
- `field.field.node.article.field_tags.yml` - Properly named field

### Bad Examples:
- `node.type.news_articles.yml` - Plural name, no description
- `views.view.articles_1.yml` - `_1` suffix (common anti-pattern)

## Adding More Test Cases

To add more comprehensive testing:

1. **Add real configurations** from actual Drupal projects
2. **Include edge cases** like:
   - Complex field configurations
   - Multi-language setups
   - Custom block configurations
   - Advanced view displays
3. **Create pairs** of good/bad examples for comparison
4. **Update validation script** to recognize expected violations

## Running Tests Locally

```bash
# Quick test
cd /path/to/drupal-best-practices
python3 ai/testing/validate.py

# Comprehensive test
python3 ai/testing/validate.py --verbose

# Test specific skill with verbose output
python3 ai/testing/validate.py --skill config-parser --verbose
```

## Expected Behaviors

### Skills Should Detect:
- **Nodes**: Plural names, missing descriptions, incorrect machine names
- **Views**: _1 suffixes, missing metadata, poor configurations
- **Fields**: Incorrect naming patterns, missing reuse opportunities
- **Blocks**: UUID-based blocks, theme dependencies
- **Taxonomy**: Vocabularies that should be list fields
- **Config Parser**: YAML syntax errors, structure issues

### Validation Reports:
The workflow generates reports that can be downloaded from the Actions tab, showing:
- Which skills were tested
- What violations were found
- Any errors or warnings