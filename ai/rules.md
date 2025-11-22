# AI-Agnostic Rules for Drupal Best Practices

Apply these Drupal 10+ rules across any CLI/editor tooling. They mirror README sections 2 and 3.

- **Machine names:** Use single words without prefixes or suffixes tied to regions/themes; avoid collisions and keep them human-readable.
- **Content modeling (2.1–2.5):** Favor fewer bundles, singular labels, documented descriptions, and reusable fields with clear `field_[bundle]_[short]` naming. Treat blocks, taxonomies, media, and paragraphs with the same discipline and avoid hardcoded UUID content.
- **Views (2.6):** One view per display when possible, explicit admin metadata, permission-based access, entity view mode rendering, non-Ajax by default, and clear empty states.
- **Forms (2.7):** Default to Webform; core Contact only for trivial single-form needs.
- **Text formats (2.8):** Standardize on one HTML format using CKEditor; align toolbar buttons with allowed tags and restrict switching formats.
- **Theming (3):** One-word theme machine names without `theme` suffixes or base-theme coupling, atomic/twig-first approach, preprocess for classes, minimal overrides, SCSS with shared breakpoints, semantic class prefixes (`twig-`, `js-`), and avoid styling by path aliases.
- **Tooling:** Prefer composer, drush, and ddev for automation; keep guidance compatible with config synchronization and current Drupal core support.
