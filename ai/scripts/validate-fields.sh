#!/usr/bin/env bash
set -euo pipefail

# Validate README section 2.5 Fields rules.

command -v drush >/dev/null 2>&1 || { echo "drush is required" >&2; exit 1; }

drush php:eval '
use Drupal\field\Entity\FieldStorageConfig;
$fail = 0;
$storage = \Drupal::entityTypeManager()->getStorage("field_storage_config");
foreach ($storage->loadMultiple() as $field) {
  $id = $field->getName();
  $desc = trim((string) $field->getDescription());
  if (strpos($id, "field_") !== 0) {
    echo "[fields] Field name should start with field_: $id\n";
    $fail = 1;
  }
  if (preg_match("/\s/", $id) || preg_match("/[^a-z0-9_]/", $id) || preg_match("/[A-Z]/", $id)) {
    echo "[fields] Machine name needs cleanup: $id\n";
    $fail = 1;
  }
  if ($desc === '') {
    echo "[fields] Missing description for $id\n";
    $fail = 1;
  }
}
if ($fail) {
  exit(1);
}
'
