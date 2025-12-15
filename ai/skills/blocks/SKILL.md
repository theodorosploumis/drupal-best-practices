---
id: drupal-blocks
title: Drupal Blocks and Block Types
summary: Create reusable custom blocks and plugins with disciplined naming and configuration.
version: 0.2.0
created: 2024-03-01
updated: 2025-03-06
maintainers:
  - Drupal Best Practices Maintainers
tags:
  - drupal
  - site-building
  - blocks
source: README.md
---

## Description
Guide Claude to design custom block types and plugins that are portable, reusable, and consistently named across environments.

## Usage
- Request machine name and admin label suggestions that omit regions and `block_` prefixes.
- Ask for field plans that mirror node/paragraph standards when blocks need structured data.
- Have Claude propose view mode reuse and caching expectations for each block display.

## Guardrails
- Prefer block types or plugins committed to code; avoid UUID-specific content blocks.
- Keep machine names short, region-agnostic, and human-readable.
- Treat block fields and view modes like node bundles for documentation and reuse.

## Validation
```bash
./ai/scripts/validate-blocks.sh
```
Run from a bootstrapped site to flag naming and descriptive gaps.

## References
- Drupal Best Practices README.
- Separate content from placement; regions and layouts are runtime concerns.
