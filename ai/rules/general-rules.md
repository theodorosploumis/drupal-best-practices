# AI Rules for Drupal Best Practices (Generic Tools)

Applies to AI-assisted coding, reviews, and CLI automation for Drupal 10+ projects. Derived from README sections 2 and 3.

## General expectations
- Keep machine names concise, human-readable, and conflict-free; avoid special characters and redundant prefixes.
- Document intent through descriptions on content types, fields, and views.
- Prefer configuration in code (plugins, block types, theme assets) over database content where feasible.

## Site building (Section 2)
- **Nodes (2.1):** Use singular bundle names; create new bundles only for truly distinct display/workflow needs; disable default revisions unless required; align view modes across content types.
- **Blocks (2.2):** Implement custom block types/plugins in code; avoid UUID-tied static blocks; keep machine names generic and placement-agnostic.
- **Taxonomy (2.3):** Reserve vocabularies for categorization pages; avoid using terms merely for filtering; consider node references for complex authorization or display needs.
- **Other content entities (2.4):** Apply node naming/translation rules to paragraphs, comments, media; keep image style machine names generic and dimension-agnostic.
- **Fields (2.5):** Use `field_[entity]_[short]` patterns; reuse only when behavior is identical; set descriptive labels, consistent upload directories, and drop `gif` unless necessary; use consistent prefixes for shared vs. scoped fields.
- **Views (2.6):** Normalize machine names (no `_1`), provide admin metadata, and keep one display per View; favor `Show: Content`; avoid blanket CSS classes and default Ajax; supply titles, comments, access via permissions, and “No results” text.
- **Forms (2.7):** Default to Webform for custom needs; use core Contact form only for simple, low-volume cases.
- **Text formats & editors (2.8):** Minimize HTML formats, align admin/editor options, rely on CKEditor, and match toolbar buttons to allowed tags; restrict unsafe content to code, not editor input.
- **Users, roles & permissions (2.10):** Define persona-based roles with short machine names; avoid broad permissions on Authenticated; ensure per-user accounts; create module-specific permissions and dashboards; test via masquerade.

## Theming & templates (Section 3)
- Use single-word theme machine names; avoid embedding base theme names or the word `theme`.
- Follow atomic design principles; prefer twig/preprocess-driven theming with necessary templates (404/403/maintenance/login).
- Favor core/Classy as bases; avoid panelizer-style modules and heavy core overrides; keep admin theme overrides minimal and attached via assets.
- Keep view/form mode machine names field-agnostic; select standard breakpoints and SCSS with documented mixins/functions; split large SCSS files by usage.
- Apply semantic, prefixed classes (`twig-`, `js-`); avoid path-alias-driven styling; organize templates into logical subfolders.
