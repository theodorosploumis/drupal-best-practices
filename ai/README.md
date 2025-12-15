# AI Integration Kit for Drupal Best Practices

This `ai/` directory packages guidance from README sections 2 (Site building) and 3 (Theming) for AI coding tools and validation workflows targeting Drupal 10+.

Contents:
- `AGENTS.md` — authoring instructions for expanding AI assets.
- `skills/` — Claude Code skill cards mapped to README subsections.
- `rules/` — generic AI rules for any CLI or IDE integration.
- `commands/` — slash commands to load context-specific best practices.
- `scripts/` — bash validators that use `drush php:eval` to surface configuration issues per subsection.

Usage tips:
- Run scripts from a Drupal project root where Drush is available.
- Pair slash commands with task context (e.g., `/drupal-best-practices-views events_page`).
- Keep new assets tool-agnostic and Drupal 10+ focused.
