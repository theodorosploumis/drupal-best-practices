#!/usr/bin/env bash
set -euo pipefail

# Validate Text formats and editors rules.
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
