#!/usr/bin/env bash
set -euo pipefail

# Validate README section 2.3 Taxonomy rules.

command -v drush >/dev/null 2>&1 || { echo "drush is required" >&2; exit 1; }

drush php:eval '
use Drupal\taxonomy\Entity\Vocabulary;
$fail = 0;
$storage = \Drupal::entityTypeManager()->getStorage("taxonomy_vocabulary");
foreach ($storage->loadMultiple() as $vocab) {
  $id = $vocab->id();
  $label = $vocab->label();
  if (preg_match("/\s/", $id) || preg_match("/[^a-z0-9_]/", $id) || preg_match("/[A-Z]/", $id)) {
    echo "[taxonomy] Machine name needs cleanup: $id\n";
    $fail = 1;
  }
  if (preg_match("/s$/", $label)) {
    echo "[taxonomy] Label looks plural; prefer singular: $label ($id)\n";
    $fail = 1;
  }
}
if ($fail) {
  exit(1);
}
'
