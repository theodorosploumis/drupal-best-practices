# AI contribution guide

These instructions summarize the Drupal 10+ best practices from `README.md` for any AI-assisted changes inside the `ai/` folder.

- Prioritize the guidance from **2. Site building** and **3. Theming, templates**. Avoid any Drupal 7.x-only rules.
- Use clear machine names and avoid multi-word theme names; keep everything human-readable and concise.
- Keep recommendations aligned with current Drupal core tooling (composer, drush, ddev) and avoid deprecated workflows.
- Ensure scripts and prompts reinforce configuration over content, avoid hardcoded UUIDs, and respect configuration sync.
- Keep the output concise and actionable so it can be applied from CLI tools or code editors.
