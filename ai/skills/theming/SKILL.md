---
id: drupal-theming
title: Drupal Theming and Templates
summary: Build Drupal themes with clean machine names, Twig-first templates, and atomic SCSS structure.
version: 0.2.0
created: 2024-03-01
updated: 2025-03-06
maintainers:
  - Drupal Best Practices Maintainers
tags:
  - drupal
  - theming
  - twig
  - scss
source: README.md
---

## Description
Guide Claude to create themes that favor Twig, preprocess logic, and atomic SCSS structure while keeping overrides minimal and purposeful.

## Usage
- Ask for one-word machine names without `theme` or base-theme prefixes.
- Request guidance on using Classy as a base theme and limiting overrides to documented needs (404/403/maintenance/login, etc.).
- Have Claude propose SCSS structure by responsibility (variables, mixins, entities, components) and class naming (`twig-`, `js-`).

## Guardrails
- Avoid path-based styling; add classes in preprocess, not templates.
- Prefer Twig templates with minimal logic; do not overuse theme overrides.
- Use semantic class prefixes and comment mixins/functions; keep SCSS split by responsibility.

## Validation
```bash
./ai/scripts/validate-theming.sh
```

## References
- Drupal Best Practices README.
- Use Classy as a base theme; keep machine names one word and human-readable.
