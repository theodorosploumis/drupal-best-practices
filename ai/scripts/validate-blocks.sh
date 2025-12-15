#!/usr/bin/env bash
set -euo pipefail

# Validate README section 2.2 Blocks rules.

command -v drush >/dev/null 2>&1 || { echo "drush is required" >&2; exit 1; }

drush php:eval '
use Drupal\block_content\Entity\BlockContentType;
$fail = 0;
$storage = \Drupal::entityTypeManager()->getStorage("block_content_type");
foreach ($storage->loadMultiple() as $type) {
  $id = $type->id();
  $desc = trim((string) $type->getDescription());
  if (preg_match("/\s/", $id) || preg_match("/[^a-z0-9_]/", $id) || preg_match("/[A-Z]/", $id)) {
    echo "[blocks] Machine name needs cleanup: $id\n";
    $fail = 1;
  }
  if (strpos($id, 'block_') === 0) {
    echo "[blocks] Remove redundant block_ prefix from $id\n";
    $fail = 1;
  }
  if ($desc === '') {
    echo "[blocks] Missing description for $id\n";
    $fail = 1;
  }
}
if ($fail) {
  exit(1);
}
'
