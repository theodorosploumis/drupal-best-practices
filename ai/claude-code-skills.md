# Claude Code Skills for Drupal Best Practices

Use these skills to guide Claude Code when assisting Drupal 10+ work. Each skill maps to README sections.

## 2.1 Nodes
- Ensure content types use singular names and human-friendly machine names without special characters.
- Create bundles only when display or functionality differs; keep revisions only where workflows require them.
- Prefer shared, generic view modes and document each bundle with a description.

## 2.2 Blocks
- Create custom block types or plugins in code with clean machine names (no region info, no `block_` prefix).
- Treat block fields and view modes like node bundles and avoid hardcoded UUID-driven blocks.

## 2.3 Taxonomy
- Keep vocabulary names singular; use taxonomy for categorization pages, not simple filtering.
- Consider entity references when authorization, fields, or displays exceed taxonomy needs.

## 2.4 Other content entities
- Apply node conventions to media, paragraphs, and comments; watch translation handling for paragraphs.
- Use concise, reusable image style names that describe intent rather than dimensions.

## 2.5 Fields
- Name shared fields generically and specific fields with entity context using `field_[bundle]_[short]`.
- Add descriptions, reuse fields only when invariant, and set meaningful file directories; drop `gif` unless required.

## 2.6 Views
- Normalize machine names (remove `_1` suffix), titles, tags, and admin descriptions for every display.
- Favor separate Views per display, render entities via view modes, avoid blanket CSS classes and default Ajax.
- Require permission-based access controls and clear "No results" text.

## 2.7 Forms
- Default to the Webform module for custom forms; reserve core Contact only for simple single-form cases.

## 2.8 Text formats and editors
- Standardize on a single HTML format using CKEditor; align buttons with allowed tags and limit format switching.
- Keep insecure content out of WYSIWYG and ensure admin formats mirror author access when possible.

## 3. Theming, templates
- Use one-word theme machine names without `theme` or base-theme prefixes; favor twig and atomic design patterns.
- Add classes via preprocess in `.theme`, cover special templates (404/403/maintenance/login), and keep overrides minimal.
- Prefer Classy as a base; if using contrib themes, decouple machine names. Use SCSS, meaningful breakpoints, and semantic class prefixes (`twig-`, `js-`).
- Avoid styling by path aliases, comment mixins/functions, and split SCSS by responsibility (entities, variables, etc.).
