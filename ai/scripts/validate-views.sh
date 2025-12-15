#!/usr/bin/env bash
set -euo pipefail

# Validate Views rules.
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
use Drupal\views\Views;
$fail = 0;
$storage = \Drupal::entityTypeManager()->getStorage("view");
foreach ($storage->loadMultiple() as $view) {
  $id = $view->id();
  $human = $view->label();
  if (preg_match("/\s/", $id) || preg_match("/[^a-z0-9_]/", $id) || preg_match("/[A-Z]/", $id)) {
    echo "[views] Machine name needs cleanup: $id\n";
    $fail = 1;
  }
  if ($human === $id || $human === '') {
    echo "[views] Missing descriptive label for $id\n";
    $fail = 1;
  }
  foreach ($view->get('display') as $display_id => $display) {
    if (substr($display_id, -2) === '_1') {
      echo "[views] Rename default _1 display id in $id ($display_id)\n";
      $fail = 1;
    }
    if (empty($display['display_title'])) {
      echo "[views] Missing display title for $id::$display_id\n";
      $fail = 1;
    }
  }
}
if ($fail) {
  exit(1);
}
'
