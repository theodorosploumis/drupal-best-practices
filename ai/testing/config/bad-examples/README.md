# Bad Configuration Examples

This directory contains Drupal configuration files with intentional violations to test validation scripts.

## Files and Expected Violations

### Node Types
- `node.type.blogs.yml` - Plural name ("blogs"), no description
- `node.type.news_articles.yml` - Plural name ("news_articles"), no description
- `node.type.test-content.yml` - Invalid machine name (contains hyphen), no description

### Views
- `views.view.content_1.yml` - Ends with _1 suffix (anti-pattern), no description
- `views.view.unnamed.yml` - Empty label, no description

### Blocks
- `block.block.90255764-97a2-4622-ae0a-838372d92bd3.yml` - Uses UUID as machine name identifier, depends on bartik theme

### Fields
- `field.field.node.article.body.yml` - No description (body fields often lack documentation)
- `field.field.node.article.article_category.yml` - Empty label, no description

### Taxonomy
- `taxonomy.vocabulary.statuses.yml` - No description (should probably be a list field instead)
- `taxonomy.vocabulary.article_types.yml` - No description (plural name, should be list field)

### Display Modes
- `core.entity_view_display.node.article.teaser_1.yml` - Uses _1 suffix (should use standard display modes)

## Validation Scripts Should Detect

### Node Type Validation Should Find:
1. Plural names ending in 's'
2. Missing descriptions
3. Invalid machine names (non-alphanumeric/underscore characters)

### View Validation Should Find:
1. Machine names ending with _1
2. Missing labels
3. Missing descriptions

### Block Validation Should Find:
1. UUID-based machine names
2. Dependencies on default themes (bartik, seven)

### Field Validation Should Find:
1. Missing descriptions
2. Missing labels
3. Inconsistent naming patterns

### Taxonomy Validation Should Find:
1. Missing descriptions
2. Suggest list fields for simple categorization

### Display Mode Validation Should Find:
1. _1 suffix in display mode names
2. Non-standard display mode names

## Using These Examples

These files help ensure validation scripts correctly identify:
- Naming convention violations
- Missing required metadata
- Drupal best practice deviations
- Common configuration anti-patterns

When testing, validation scripts should report these as errors or warnings.