---
id: drupal-nodes
title: Drupal Node Bundles
summary: Model and maintain node bundles using Drupal 10 site-building conventions.
maintainers:
  - Theodoros Ploumis https://github.com/theodorosploumis
tags:
  - drupal
  - site-building
  - nodes
  - content-modeling
source: README.md
---

## Description
Apply consistent naming, reuse, and revision policies when creating and maintaining node bundles. Favor reusable view modes, keep bundle purposes clear, and document them for downstream editors and themers.

## Usage
- Prompt Claude to propose bundle names, machine names, descriptions, and required fields before creating a type.
- Ask for revision and translation guidance only when the workflow requires it.
- Request view mode plans that avoid redundant displays and encourage reuse across bundles.

## Guardrails
- Machine names are singular, concise, and avoid special characters.
- New bundle creation is justified by display or behavior differences; avoid one-off bundles.
- Avoid hardcoding UUIDs or content IDs in configuration or code.

## Validation
Run the subsection validator from a bootstrapped Drupal site to spot naming and configuration issues:

```bash
./ai/scripts/validate-nodes.sh
```

## References
- Drupal Best Practices README.
- Reuse the “Full” and “Teaser” view modes unless a new, documented display is needed.
