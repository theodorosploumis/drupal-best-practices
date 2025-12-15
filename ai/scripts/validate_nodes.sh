#!/usr/bin/env bash
set -euo pipefail

# Validate Drupal 10+ node bundle setup against README section 2.1.
# Usage: ./ai/scripts/validate_nodes.sh

if ! command -v drush >/dev/null 2>&1; then
  echo "[error] drush not found. Install drush or run within a Drupal project." >&2
  exit 1
fi

issues=0

read -r -d '' PHP_SCRIPT <<'PHP'
$types = \Drupal\node\Entity\NodeType::loadMultiple();
foreach ($types as $id => $type) {
  $name = $type->label();
  $desc = trim((string) $type->getDescription());
  $machine_valid = preg_match('/^[a-z0-9_]+$/', $id);
  $singular_hint = str_ends_with($name, 's');
$view_modes = \Drupal::service('entity_display.repository')->getViewModeOptionsByBundle('node', $id);

  if (!$machine_valid) {
    echo "[machine-name] {$id} contains unsupported characters\n";
  }
  if ($singular_hint) {
    echo "[singular] {$name} appears plural; use singular bundle names\n";
  }
  if ($desc === '') {
    echo "[description] {$id} is missing a description\n";
  }
  if (count($view_modes) === 0) {
    echo "[view-modes] {$id} has no view modes configured; prefer shared/generic modes\n";
  }
}
PHP

output=$(drush php:eval "$PHP_SCRIPT" || true)
if [[ -n "${output}" ]]; then
  echo "Node bundle issues:" >&2
  echo "$output" >&2
  issues=1
fi

if [[ $issues -eq 0 ]]; then
  echo "Node bundles align with best practices."
fi

exit $issues
