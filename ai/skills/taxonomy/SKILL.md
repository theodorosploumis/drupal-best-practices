---
id: drupal-taxonomy
title: Drupal Taxonomy
summary: Model vocabularies and terms responsibly for categorization and landing pages.
maintainers:
  - Theodoros Ploumis https://github.com/theodorosploumis
tags:
  - drupal
  - site-building
  - taxonomy
source: README.md
---

## Description
Use taxonomy for categorization and curated landing pages while keeping names singular and purpose-driven.

## Usage
- Ask Claude whether taxonomy or another entity type (e.g., entity reference) fits the requirement.
- Request vocabulary naming and description guidance to keep purpose clear.
- Have Claude outline display patterns that avoid overloading taxonomy when richer entities are needed.

## Guardrails
- Singular vocabulary names and concise machine names.
- Use taxonomy for categorization and term pages, not simple filters when entity references suffice.
- Consider permissions, fields, and translation needs before defaulting to taxonomy.

## Validation
```bash
./ai/scripts/validate-taxonomy.sh
```

## References
- Drupal Best Practices README.
- Prefer entity references when authorization, fields, or displays exceed taxonomy needs.
