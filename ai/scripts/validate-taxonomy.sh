#!/usr/bin/env bash
set -euo pipefail

# Validate Taxonomy rules.
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
