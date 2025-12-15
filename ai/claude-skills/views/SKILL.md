---
id: drupal-views
title: Drupal Views
summary: Build Views with intentional naming, access, and display planning.
version: 0.2.0
created: 2024-03-01
updated: 2025-03-06
maintainers:
  - Drupal Best Practices Maintainers
tags:
  - drupal
  - site-building
  - views
source: README.md §2.6 Views
---

## Description
Ensure Views have clear machine names, titles, tags, and display-level documentation while enforcing access and render strategies.

## Usage
- Ask Claude to normalize machine names (remove `_1` suffixes) and provide admin descriptions.
- Request per-display titles, access rules, and No Results messages.
- Have Claude recommend rendering entities via view modes and separating displays when behavior diverges.

## Guardrails
- Require permission-based access on each display.
- Avoid blanket CSS classes and default Ajax unless justified.
- Prefer separate Views per display and reuse view modes instead of field rendering when possible.

## Validation
```bash
./ai/scripts/validate-views.sh
```

## References
- Drupal Best Practices README §2.6 Views.
- Render entities through view modes to keep templating consistent.
