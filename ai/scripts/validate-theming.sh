#!/usr/bin/env bash
set -euo pipefail

# Validate README section 3 Theming rules.

command -v drush >/dev/null 2>&1 || { echo "drush is required" >&2; exit 1; }

drush php:eval '
use Drupal\system\Entity\Theme;
$fail = 0;
$themes = Theme::loadMultiple();
foreach ($themes as $theme) {
  $id = $theme->id();
  if (preg_match("/\s/", $id) || preg_match("/[^a-z0-9_]/", $id) || preg_match("/[A-Z]/", $id)) {
    echo "[theming] Theme machine name should be one word lowercase: $id\n";
    $fail = 1;
  }
  if (strpos($id, 'theme') !== false) {
    echo "[theming] Remove redundant 'theme' substring from $id\n";
    $fail = 1;
  }
  $base = $theme->getBaseTheme();
  if ($base && strpos($id, $base) !== false) {
    echo "[theming] Subtheme machine name should not include base theme ($base): $id\n";
    $fail = 1;
  }
}
if ($fail) {
  exit(1);
}
'
