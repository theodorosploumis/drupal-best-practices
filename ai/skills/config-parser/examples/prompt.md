# Example prompts for Drupal Config Parser skill

## Basic validation
"Analyze the Drupal configuration in the config/ directory and check for any naming convention violations."

## Specific validation
"Check all node type configurations in config/ for plural names and missing descriptions."

## Field validation
"Validate all field configurations in web/sites/default/files/config/sync/ to ensure they follow the field_[entity]_[description] pattern."

## View validation
"Analyze all view configurations to identify any with machine names ending in _1 or with missing administrative metadata."

## Dependency analysis
"Check all configuration files for missing or invalid module dependencies."

## Before import validation
"I'm about to import these configuration files. Can you validate them and identify any potential issues before I import them to production?"

## CI/CD pipeline
"Validate the exported configuration files in our CI pipeline to ensure they meet Drupal best practices before deployment."