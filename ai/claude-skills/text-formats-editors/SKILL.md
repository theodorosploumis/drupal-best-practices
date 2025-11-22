---
id: drupal-text-formats-editors
title: Text Formats and Editors
summary: Standardize HTML formats and editor settings for safe, consistent authoring.
version: 0.2.0
created: 2024-03-01
updated: 2025-03-06
maintainers:
  - Drupal Best Practices Maintainers
tags:
  - drupal
  - site-building
  - text-formats
  - ckeditor
source: README.md §2.8 Text formats and editors
---

## Description
Help Claude align text formats, allowed tags, and CKEditor button sets so authors share a consistent, secure HTML format.

## Usage
- Ask for a single standardized HTML format with matching CKEditor settings and allowed HTML tags.
- Request button set recommendations that mirror allowed tags and remove insecure options.
- Have Claude plan format access to avoid authors switching between overlapping formats.

## Guardrails
- Keep insecure content out of WYSIWYG; align editor buttons with allowed tags.
- Limit format switching by mirroring access controls and keeping formats minimal.
- Prefer one HTML format for most authors; ensure admin formats align with policy.

## Validation
```bash
./ai/scripts/validate-text-formats.sh
```

## References
- Drupal Best Practices README §2.8 Text formats and editors.
- Standardize on CKEditor for Drupal 10+.
