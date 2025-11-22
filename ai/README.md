# AI Helpers for Drupal Best Practices

This folder provides AI-friendly outputs derived from `README.md` sections **2. Site building** and **3. Theming, templates** for Drupal 10+ projects.

- `AGENTS.md` – scope rules for AI-written assets in this folder.
- `claude-code-skills.md` – index pointing to per-subsection Claude skills.
- `claude-skills/` – Claude-ready skills with `SKILL.md`, examples, scripts, and references per subsection.
- `rules.md` – generic rules for any CLI/editor AI.
- `commands.md` – slash commands mapping to the relevant README sections.
- `scripts/*.sh` – drush-based validators for subsections (nodes, blocks, taxonomy, fields, views, text formats, theming).

Run validators from a bootstrapped Drupal site, e.g.

```bash
./ai/scripts/validate-nodes.sh
```
