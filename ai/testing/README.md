# Testing Configuration Files

This directory contains Drupal configuration files used to validate the skills in real-time.

## Structure

```
testing/
├── README.md           # This file
├── config/             # Configuration files for testing
│   ├── good-examples/  # Properly configured examples
│   └── bad-examples/   # Examples with violations to test validation
└── validate.py         # Validation script
```

## Adding Test Cases

To add new test cases:

1. **Good examples**: Export configurations from a well-configured Drupal site
2. **Bad examples**: Create or modify configs with intentional violations
3. Use realistic examples from actual Drupal projects

## Running Tests

```bash
# Test all skills with random configs
python3 testing/validate.py

# Test specific skill
python3 testing/validate.py --skill nodes

# Test with specific config directory
python3 testing/validate.py --config-dir testing/config
```

## Configuration Files Used

The test configurations include:

- Node types with various naming patterns
- Field configurations with different naming conventions
- View configurations (some with _1 suffix issues)
- Block configurations (including UUID-based ones)
- Taxonomy vocabularies
- Text format configurations
- Theming configurations

These files help ensure the validation scripts correctly identify:
- Naming convention violations
- Missing descriptions
- Improper configurations
- Best practice deviations