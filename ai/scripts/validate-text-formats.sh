#!/usr/bin/env bash
set -euo pipefail

# Validate README section 2.8 Text formats and editors rules.

command -v drush >/dev/null 2>&1 || { echo "drush is required" >&2; exit 1; }

drush php:eval '
use Drupal\filter\Entity\FilterFormat;
$formats = FilterFormat::loadMultiple();
if (count($formats) > 2) {
  echo "[text formats] More than one HTML-capable format detected; aim for a single HTML format.\n";
}
foreach ($formats as $format) {
  $name = $format->id();
  $filters = $format->filters();
  if (strpos($name, "html") !== false && empty($format->getRoles())) {
    echo "[text formats] Ensure access to $name is scoped to roles, not open to all.\n";
  }
  if ($filters->has('filter_html')) {
    $allowed = $filters->get('filter_html')->getConfiguration()['allowed_html'] ?? '';
    if ($allowed === '') {
      echo "[text formats] Allowed HTML empty for $name; align toolbar buttons with allowed tags.\n";
    }
  }
}
'
