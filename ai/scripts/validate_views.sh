#!/usr/bin/env bash
set -euo pipefail

# Validate Views against README section 2.6.
# Usage: ./ai/scripts/validate_views.sh

if ! command -v drush >/dev/null 2>&1; then
  echo "[error] drush not found. Install drush or run within a Drupal project." >&2
  exit 1
fi

issues=0

read -r -d '' PHP_SCRIPT <<'PHP'
use Drupal\views\Views;

$views = Views::getAllViews();
foreach ($views as $view) {
  $id = $view->id();
  $label = $view->label();
  $tag = $view->get('tag');
  $desc = trim((string) $view->get('description'));
  $machine_valid = preg_match('/^[a-z0-9_]+$/', $id);
  if (!$machine_valid) {
    echo "[machine-name] {$id} contains unsupported characters\n";
  }
  if ($desc === '') {
    echo "[description] {$id} is missing a description\n";
  }
  if ($tag === '') {
    echo "[tag] {$id} has no tag; add tags for organization\n";
  }

  $displays = $view->get('display');
  foreach ($displays as $display_id => $display) {
    if (str_ends_with($display_id, '_1')) {
      echo "[display-name] {$id} display {$display_id} uses default _1 suffix; rename to meaningful id\n";
    }
    $title = $display['display_options']['title'] ?? '';
    if (trim((string) $title) === '') {
      echo "[title] {$id} display {$display_id} is missing a title\n";
    }
    $row_plugin = $display['display_options']['row']['type'] ?? '';
    if ($row_plugin !== '' && !str_starts_with($row_plugin, 'entity:')) {
      echo "[row] {$id} display {$display_id} uses row type {$row_plugin}; prefer Show: Content (entity rows)\n";
    }
    $use_ajax = $display['display_options']['use_ajax'] ?? false;
    if ($use_ajax) {
      echo "[ajax] {$id} display {$display_id} uses Ajax; default should be disabled\n";
    }
    $access = $display['display_options']['access']['type'] ?? '';
    if ($access === 'role') {
      echo "[access] {$id} display {$display_id} controls access by role; prefer permissions\n";
    }
    $empty = $display['display_options']['empty'] ?? [];
    if (empty($empty)) {
      echo "[empty] {$id} display {$display_id} missing No results behavior\n";
    }
  }
}
PHP

output=$(drush php:eval "$PHP_SCRIPT" || true)
if [[ -n "${output}" ]]; then
  echo "Views issues:" >&2
  echo "$output" >&2
  issues=1
fi

if [[ $issues -eq 0 ]]; then
  echo "Views align with best practices."
fi

exit $issues
