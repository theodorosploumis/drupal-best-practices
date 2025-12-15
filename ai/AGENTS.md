# AI Authoring Instructions

## Scope
Applies to all files under `ai/`.

## Guidelines

### Content Standards
- Derive guidance from the repository README, prioritizing Drupal 10+ usage
- Do not reintroduce Drupal 7.x-only rules
- Prefer concise, actionable checklists suited for AI-assisted development tools
- Remove numbered sections from documentation to avoid maintenance issues

### File Organization
- Skills go in `skills/` directory with SKILL.md format
- Validation scripts go in `scripts/` directory with hyphenated naming
- Use `skills/skill-name/` structure for each skill
- Each skill should contain: SKILL.md, examples/, reference/
- Avoid duplicate files - consolidate instead of creating multiple versions

### Script Standards
- Support both static YAML analysis and running Drupal instances when possible
- Include DDEV detection using the ddev-drush-helper.sh
- Use clear usage instructions with --help flag
- Fail with clear, human-readable error messages
- Use lowercase, hyphenated file names (not underscores)

### CLI Tool Preferences
- Keep command examples tool-agnostic when possible
- For Drupal CLI, prioritize: ddev drush > drush > composer
- Include options for different validation modes (static, running, auto)

### Documentation
- Use relative paths in usage examples (not hardcoded ./ai/scripts/)
- Keep examples current and functional
- Reference the unified skills/ directory structure
