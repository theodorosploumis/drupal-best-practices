#!/usr/bin/env bash
set -euo pipefail

# Validate taxonomy vocabularies against README section 2.3.
# Usage: ./ai/scripts/validate_taxonomy.sh

if ! command -v drush >/dev/null 2>&1; then
  echo "[error] drush not found. Install drush or run within a Drupal project." >&2
  exit 1
fi

issues=0

read -r -d '' PHP_SCRIPT <<'PHP'
$vocabularies = \Drupal\taxonomy\Entity\Vocabulary::loadMultiple();
foreach ($vocabularies as $id => $vocabulary) {
  $label = $vocabulary->label();
  $machine_valid = preg_match('/^[a-z0-9_]+$/', $id);
  $plural_hint = str_ends_with($label, 's');
  $description = trim((string) $vocabulary->getDescription());

  if (!$machine_valid) {
    echo "[machine-name] {$id} contains unsupported characters\n";
  }
  if ($plural_hint) {
    echo "[singular] {$label} appears plural; use singular vocabulary names\n";
  }
  if ($description === '') {
    echo "[description] {$id} is missing a description\n";
  }
}
PHP

output=$(drush php:eval "$PHP_SCRIPT" || true)
if [[ -n "${output}" ]]; then
  echo "Taxonomy issues:" >&2
  echo "$output" >&2
  issues=1
fi

if [[ $issues -eq 0 ]]; then
  echo "Taxonomy vocabularies align with best practices."
fi

exit $issues
