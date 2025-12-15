#!/usr/bin/env bash
set -euo pipefail

# Validate Fields rules.
#
# This script automatically detects if you're in a DDEV environment
# and will use 'ddev drush' instead of 'drush' accordingly.

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the DDEV Drush helper
source "$SCRIPT_DIR/ddev-drush-helper.sh"

# Check if Drush is available (with DDEV support)
check_drush

run_drush php:eval '
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
