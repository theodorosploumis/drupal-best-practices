#!/usr/bin/env bash
set -euo pipefail

# Validate custom block types against README section 2.2.
# Usage: ./ai/scripts/validate_blocks.sh

if ! command -v drush >/dev/null 2>&1; then
  echo "[error] drush not found. Install drush or run within a Drupal project." >&2
  exit 1
fi

issues=0

read -r -d '' PHP_SCRIPT <<'PHP'
$types = \Drupal\block_content\Entity\BlockContentType::loadMultiple();
foreach ($types as $id => $type) {
  $label = $type->label();
  $desc = trim((string) $type->get('description'));
  $machine_valid = preg_match('/^[a-z0-9_]+$/', $id);
  $mentions_region = (bool) preg_match('/(header|footer|sidebar|region)/i', $label);

  if (!$machine_valid) {
    echo "[machine-name] {$id} contains unsupported characters\n";
  }
  if ($mentions_region) {
    echo "[placement] {$label} references a region/placement; keep names placement-agnostic\n";
  }
  if ($desc === '') {
    echo "[description] {$id} is missing a description\n";
  }
}
PHP

output=$(drush php:eval "$PHP_SCRIPT" || true)
if [[ -n "${output}" ]]; then
  echo "Block type issues:" >&2
  echo "$output" >&2
  issues=1
fi

if [[ $issues -eq 0 ]]; then
  echo "Block types align with best practices."
fi

exit $issues
