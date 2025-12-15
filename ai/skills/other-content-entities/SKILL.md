---
id: drupal-other-content-entities
title: Other Content Entities
summary: Apply node standards to media, paragraphs, comments, and similar entities.
version: 0.2.0
created: 2024-03-01
updated: 2025-03-06
maintainers:
  - Drupal Best Practices Maintainers
tags:
  - drupal
  - site-building
  - media
  - paragraphs
  - comments
source: README.md
---

## Description
Extend node-oriented conventions to media, paragraphs, comments, and related entities while accounting for translation and display nuances.

## Usage
- Ask Claude to mirror node naming, documentation, and view mode reuse when modeling non-node entities.
- Request guidance on translation handling, especially for paragraphs.
- Have Claude suggest image style names that describe intent instead of dimensions.

## Guardrails
- Keep machine names concise and reusable across bundles.
- Ensure translation workflows are explicit for nested entities like paragraphs.
- Prefer descriptive image style names (goal-based, not pixel-based) and avoid GIF unless required.

## Validation
Refer to scripts aligned with the specific entity (e.g., fields, views, blocks) after applying changes.

## References
- Drupal Best Practices README.
- Apply node naming, descriptions, and view mode reuse patterns consistently.
