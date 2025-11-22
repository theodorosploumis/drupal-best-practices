# Tool-Agnostic Rules for Drupal 10+ Best Practices

Use these rules across AI coding helpers, CLIs, and IDE automations. They mirror `README.md` sections 2 and 3.

## Site building (Section 2)
- Machine names for bundles, fields, blocks, and views must be singular, human-meaningful, and free of suffix clutter (e.g., drop `_1`).
- Prefer custom entities or block types over overloading nodes; create new bundles only for distinct display/logic needs.
- Provide descriptions for content types, fields, and Views; document access via permissions rather than roles.
- Reuse fields only when identical across bundles; set deterministic upload directories and avoid `gif` unless required.
- Views should use content-based rows with view modes, explicit titles, tags, and non-AJAX defaults; disable unused displays.
- Standardize on a single HTML format with CKEditor; keep admins aligned with author-capable formats and avoid insecure content via UI.
- Model roles by persona with concise machine names; each module must declare its own permissions and expose dashboards tailored to roles.

## Theming, templates (Section 3)
- Use one-word machine names for themes without base-theme suffixes or the word `theme`; prefer Classy base or cloned contrib themes.
- Follow Atomic design, SCSS, and common breakpoints; avoid panels-family modules.
- Favor twig templates and preprocess functions for structure and classes; include key pages (404/403/maintenance/login).
- Avoid styling based on path aliases or non-semantic classes; use functional prefixes (`twig-`, `js-`) and mixins instead of utility elements.
- Override only necessary CSS/JS, comment mixins/functions, and organize templates by module/entity with minimal folder sprawl.
- Support modern browsers per Drupal 10+ guidance; keep admin theme overrides minimal and core-focused.
