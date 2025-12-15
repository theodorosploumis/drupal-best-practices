---
id: drupal-config-parser
title: Drupal Config Parser
summary: Parse and validate Drupal configuration YAML files for best practices compliance
version: 0.1.0
created: 2025-01-15
updated: 2025-01-15
maintainers:
  - Drupal Best Practices Maintainers
tags:
  - drupal
  - configuration
  - validation
  - static-analysis
  - yml
source: README.md
---

## Description
Parse Drupal configuration YAML files to validate best practices without requiring a running Drupal instance. This skill can analyze exported configuration files to check naming conventions, structure compliance, and configuration patterns.

## Usage
- Prompt Claude to validate Drupal configurations against best practices
- Use for CI/CD pipelines, pre-commit hooks, or offline validation
- Analyze configuration before importing to a live site
- Validate configuration snapshots and backups

### Command Line Usage
```bash
# Analyze config from default locations
./validate-config.sh

# Analyze specific config directory
./validate-config.sh --path /path/to/config

# Analyze specific config file
./validate-config.sh --file node.type.article.yml

# Validate specific rules
./validate-config.sh --rules naming,dependencies
```

## Guardrails
- Only processes YAML files with .yml or .yaml extension
- Validates YAML syntax before processing
- Reports errors clearly without breaking on invalid files
- Maintains backward compatibility with existing validation scripts

## Validation
Run the config parser to validate Drupal configurations:

```bash
./ai/scripts/validate-config.sh
```

## References
- Drupal Best Practices README
- Drupal Configuration Management documentation
- Drupal core configuration schema definitions