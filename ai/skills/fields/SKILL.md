---
id: drupal-fields
title: Drupal Fields
summary: Name, describe, and reuse fields with clear ownership and scope.
version: 0.2.0
created: 2024-03-01
updated: 2025-03-06
maintainers:
  - Drupal Best Practices Maintainers
tags:
  - drupal
  - site-building
  - fields
source: README.md
---

## Description
Help Claude create field plans with consistent machine names, descriptions, and reuse rules that respect configuration sync.

## Usage
- Ask for machine names using `field_[bundle]_[short]` for specific fields and generic names for shared fields.
- Request field descriptions, widget/formatter choices, and file directory guidance.
- Have Claude flag when reuse is unsafe due to differing semantics.

## Guardrails
- Provide descriptions for every field and avoid ambiguous reuse.
- Use meaningful file directories; avoid GIF formats unless required.
- Keep machine names concise and predictable for bundle-specific fields.

## Validation
```bash
./ai/scripts/validate-fields.sh
```

## References
- Drupal Best Practices README.
- Share fields only when semantics and configuration truly align.
