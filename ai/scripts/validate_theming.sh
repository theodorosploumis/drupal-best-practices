#!/usr/bin/env bash
set -euo pipefail

# Validate theme naming and structure against README section 3.
# Usage: ./ai/scripts/validate_theming.sh

if ! command -v drush >/dev/null 2>&1; then
  echo "[error] drush not found. Install drush or run within a Drupal project." >&2
  exit 1
fi

issues=0

read -r -d '' PHP_SCRIPT <<'PHP'
$themes = \Drupal::service('theme_handler')->listInfo();
foreach ($themes as $machine => $theme) {
  $name = $theme->info['name'] ?? $machine;
  $base = $theme->info['base theme'] ?? '';
  $is_core = $theme->info['project'] === 'drupal';

  // Skip core themes but still enforce machine name rules for customs/subthemes.
  $machine_valid = preg_match('/^[a-z0-9]+$/', $machine);
  if (!$machine_valid) {
    echo "[machine-name] {$machine} should be a single lowercase word without underscores or hyphens\n";
  }
  if (stripos($machine, 'theme') !== false) {
    echo "[machine-name] {$machine} should not include the word 'theme'\n";
  }
  if ($base && str_contains($machine, $base)) {
    echo "[subtheme-name] {$machine} includes base theme {$base}; keep names independent\n";
  }
}
PHP

output=$(drush php:eval "$PHP_SCRIPT" || true)
if [[ -n "${output}" ]]; then
  echo "Theme issues:" >&2
  echo "$output" >&2
  issues=1
fi

if [[ $issues -eq 0 ]]; then
  echo "Themes align with best practices."
fi

exit $issues
