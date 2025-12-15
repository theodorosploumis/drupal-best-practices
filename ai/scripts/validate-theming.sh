#!/usr/bin/env bash
set -euo pipefail

# Validate Theming rules.
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
$fail = 0;
$themes = \Drupal::service("theme_handler")->listInfo();
foreach ($themes as $id => $theme) {
  if (preg_match("/\s/", $id) || preg_match("/[^a-z0-9_]/", $id) || preg_match("/[A-Z]/", $id)) {
    echo "[theming] Theme machine name should be one word lowercase: $id\n";
    $fail = 1;
  }
  if (strpos($id, "theme") !== false) {
    echo "[theming] Remove redundant \"theme\" substring from $id\n";
    $fail = 1;
  }
  $base = $theme->info["base theme"] ?? NULL;
  if ($base && strpos($id, $base) !== false) {
    echo "[theming] Subtheme machine name should not include base theme ($base): $id\n";
    $fail = 1;
  }
}
if ($fail) {
  exit(1);
}
'
