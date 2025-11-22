# Claude Code Skills for Drupal 10+ Best Practices

These skills mirror the repository's best practices so Claude-based tools can deliver focused help per subsection.

## 2. Site building

### Skill: 2.1 Nodes
- Enforce singular machine names for node bundles and fields; avoid conflicts or ambiguous prefixes.
- Recommend custom entities or block types instead of using nodes for dynamic blocks.
- Limit new bundles to cases with distinct displays or behavior; align view modes across types and document content type purpose.

### Skill: 2.2 Blocks
- Generate custom block types or plugins with concise machine names (no theme/region hints and no `block_` prefix).
- Treat block fields and view modes like other content entities; prefer code-generated block types for stability.
- Avoid hardcoding UUID-based blocks; use plugins for static blocks.

### Skill: 2.3 Taxonomy
- Use singular vocabulary names and reserve taxonomies for categorized pages rather than simple filters.
- Prefer list fields for filtering-only needs and consider node references when authorization, fields, or displays are required.

### Skill: 2.4 Other content entities
- Apply node rules to paragraphs, media, comments, etc.; watch translation/revision behavior (especially paragraphs).
- Name image styles generically (e.g., `large_wide`) instead of dimension-specific machine names.

### Skill: 2.5 Fields
- Advocate clear, reusable machine names: `field_[content_type]_[short_name]` for specific fields and generic prefixes for shared ones.
- Require field descriptions, meaningful upload directories (avoid date-based defaults), and removal of `gif` unless necessary.
- Encourage consistent prefixes when projects mandate them and reuse fields only when truly identical across bundles.

### Skill: 2.6 Views
- Normalize machine names (remove `_1` suffixes) and create one View per display when possible.
- Use `Show: Content` with view modes, provide titles, descriptions, tags, access by permission, and no default AJAX.
- Disable unused Views, supply "No results" text, and avoid blanket custom CSS classes.

### Skill: 2.7 Forms
- Recommend Webform for custom forms; use core Contact form only for minimal needs without stored submissions.

### Skill: 2.8 Text formats and editors
- Standardize on one HTML editor format with CKEditor, aligned buttons and allowed tags; avoid insecure content via UI.
- Prevent role-based format hopping and keep admins aligned with authors' editable formats.

### Skill: 2.10 Users, roles & permissions
- Model roles by persona, avoid overpowered authenticated roles, and keep machine names short.
- Ensure each module declares its own permissions with verb-led names; prefer Masquerade for permission testing.
- Provide custom admin dashboards and limit duplicate admin accounts.

## 3. Theming, templates

### Skill: 3 Theming fundamentals
- Use one-word theme machine names without `theme` or base-theme suffixes; prefer Classy base theme or cloned contrib themes without inheritance.
- Align CSS with Atomic design, SCSS, and consistent breakpoints; avoid panels family modules.
- Rely on preprocess functions and targeted twig templates (including 404/403/maintenance/login) instead of DB theme settings for teams.
- Avoid path-alias-based styling and non-semantic CSS classes; use functional prefixes (`twig-`, `js-`) and mixins over utility elements.
- Override only necessary CSS/JS, favor utility-first frameworks selectively, comment mixins/functions, and organize templates by module/entity.
- Support modern browser guidance (Drupal 10+ drops IE11) and keep admin theme mostly core with light overrides.
