# Claude Code Skills: Drupal Best Practices

Use these skills to anchor AI assistance around Drupal 10+ site building and theming rules drawn from the repository README. Each skill maps to a numbered section for quick reference.

## 2. Site building

### Skill: 2.1 Nodes
- Enforce singular bundle names and human-readable machine names without special characters.
- Create new node bundles only when display or workflow requirements diverge; prefer generic view modes.
- Avoid default revisions unless workflow requires them; keep machine names conflict-free and documented via descriptions.

### Skill: 2.2 Blocks
- Define custom block types or block plugins in code with concise machine names (no region or placement details).
- Treat fields and view modes like node entities; keep names generic and avoid auto-added prefixes in machine names.
- Prefer plugin-based “static” blocks over fixed UUID content blocks for better config portability.

### Skill: 2.3 Taxonomy
- Use singular vocabulary names and reserve taxonomies for true categorization pages.
- Avoid taxonomies solely for filtering; choose list fields when display pages are not needed.
- Consider node references when authorization, fields, or custom displays are required.

### Skill: 2.4 Other content entities
- Apply node naming rules to paragraphs, comments, media, etc.; watch translation impacts on revisioned entities.
- Favor generic image style machine names not tied to dimensions.

### Skill: 2.5 Fields
- Name shared fields generically; name specific fields with entity context (`field_[entity]_[short]`).
- Reuse fields only when behavior is identical; otherwise keep them scoped.
- Provide descriptions, meaningful upload directories, and avoid `gif` unless required.
- Consider consistent prefixes for shared versus entity-specific fields.

### Skill: 2.6 Views
- Normalize machine names (remove `_1` suffixes) and supply admin names, descriptions, tags, and titles.
- Keep one display per View when possible; prefer `Show: Content` to align styling with view modes.
- Avoid custom CSS classes on entire views; disable unused views and add access via permissions, not roles.
- Provide “No results” text and administrative comments; avoid default Ajax.

### Skill: 2.7 Forms
- Prefer the Webform module for custom forms; use core Contact only for minimal, non-persistent needs.

### Skill: 2.8 Text formats and editors
- Minimize HTML formats; keep admin/editor experiences aligned and use CKEditor.
- Match toolbar buttons to allowed tags, disallow unsafe content via editor, and limit format switching.

### Skill: 2.10 Users, roles & permissions
- Create persona-based roles with concise machine names; avoid granting permissions to Authenticated by default.
- Ensure each user has an individual account; add module-specific permissions per feature area.
- Prefer permissions over roles for view access; provide custom admin dashboards and testing with masquerade tools.

## 3. Theming, templates

### Skill: Theming foundations
- Use single-word theme machine names without the word `theme`; avoid embedding base theme names in subthemes.
- Favor twig and preprocess-driven theming; follow atomic design principles and create key templates (404/403/maintenance/login).
- Prefer Classy/core as base themes; avoid panelizer-style modules and heavy overrides of core markup/CSS.
- Choose field-agnostic view/form mode machine names, standard breakpoints, and SCSS with documented mixins/functions.
- Use functional CSS frameworks selectively; apply semantic classes with prefixes (`twig-`, `js-`) and keep admin theming minimal via attached assets.
- Organize templates into meaningful subfolders and avoid path-alias-based styling.
