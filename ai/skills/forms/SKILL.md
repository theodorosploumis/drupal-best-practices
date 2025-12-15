---
id: drupal-forms
title: Drupal Forms
summary: Choose the right form tooling and document when to use Webform versus core Contact.
version: 0.2.0
created: 2024-03-01
updated: 2025-03-06
maintainers:
  - Drupal Best Practices Maintainers
tags:
  - drupal
  - site-building
  - forms
source: README.md
---

## Description
Guide Claude to default to Webform for custom forms, reserving core Contact only for simple, single-form cases.

## Usage
- Ask for justification when suggesting core Contact instead of Webform.
- Request exportable configuration and access/handler recommendations.
- Have Claude propose spam mitigation and confirmation patterns aligned with Webform.

## Guardrails
- Prefer Webform for complex or multiple forms; use core Contact only for simple single forms.
- Keep configuration exportable and avoid content-only forms.
- Document access, handlers, and submission storage expectations.

## Validation
Review form choices against project requirements; rerun relevant validators (fields, views) if forms expose entities.

## References
- Drupal Best Practices README.
- Webform is the default choice for bespoke forms in Drupal 10+.
