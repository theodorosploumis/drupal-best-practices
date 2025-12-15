#!/usr/bin/env bash
set -euo pipefail

# Validate Nodes rules against a Drupal 10+ site.
# Requires: drush, Drupal bootstrap.

command -v drush >/dev/null 2>&1 || { echo "drush is required" >&2; exit 1; }

drush php:eval '
use Drupal\node\Entity\NodeType;
$fail = 0;
$storage = \Drupal::entityTypeManager()->getStorage("node_type");
foreach ($storage->loadMultiple() as $type) {
  $id = $type->id();
  $label = $type->label();
  $desc = trim((string) $type->getDescription());
  if (preg_match("/\s/", $id) || preg_match("/[^a-z0-9_]/", $id) || preg_match("/[A-Z]/", $id)) {
    echo "[nodes] Machine name needs cleanup: $id\n";
    $fail = 1;
  }
  if (preg_match("/s$/", $label)) {
    echo "[nodes] Label looks plural; prefer singular: $label ($id)\n";
    $fail = 1;
  }
  if ($desc === '') {
    echo "[nodes] Missing description for $id\n";
    $fail = 1;
  }
  if ($type->isNewRevision()) {
    echo "[nodes] Revisions enabled by default; confirm workflow need: $id\n";
  }
}
if ($fail) {
  exit(1);
}
'
