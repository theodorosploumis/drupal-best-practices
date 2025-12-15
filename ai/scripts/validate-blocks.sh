#!/usr/bin/env bash
set -euo pipefail

# Validate Blocks rules.
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
