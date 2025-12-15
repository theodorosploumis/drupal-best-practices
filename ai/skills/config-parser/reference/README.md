# Drupal Configuration Parser Reference

## Configuration Locations

Drupal stores configuration files in several standard locations:

### Default Locations
- `config/` - Standard config export directory
- `web/sites/default/files/config/` - Config sync directory in Composer projects
- `web/sites/default/files/config/sync/` - Alternative sync location
- `.ddev/config/` - DDEV-specific config location

### Config File Types
- `node.type.*.yml` - Content type configurations
- `field.field.*.yml` - Field configurations
- `field.storage.*.yml` - Field storage configurations
- `views.view.*.yml` - View configurations
- `block.block.*.yml` - Block configurations
- `taxonomy.vocabulary.*.yml` - Taxonomy vocabularies
- `core.entity_view_display.*.yml` - View display configurations
- `core.entity_form_display.*.yml` - Form display configurations

## Validation Rules

### Naming Conventions
- Node types: Singular, lowercase with underscores
- Fields: Follow pattern `field_[entity]_[description]`
- Views: Descriptive, no suffix numbers
- Vocabularies: Singular names

### Dependency Management
- Required modules should exist
- Config dependencies should be resolvable
- Avoid circular dependencies

### Structure Validation
- Required fields must be present
- UUIDs should be valid when present
- Status flags should be appropriate
- Labels and descriptions should be provided