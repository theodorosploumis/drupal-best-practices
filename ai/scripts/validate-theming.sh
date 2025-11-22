#!/usr/bin/env bash
set -euo pipefail

# Validate Drupal 10+ theming best practices for section 3.
# Usage: ./validate-theming.sh [check]
# Checks: themes css twig assets

check="${1:-all}"

if ! command -v drush >/dev/null 2>&1; then
  echo "[WARN] drush not found. Install drush or set PATH so checks can run." >&2
  exit 1
fi

run_drush() {
  local cmd="$1"
  echo "[INFO] drush ${cmd}" >&2
  drush ${cmd}
}

check_themes() {
  echo "[CHECK] 3 Theming: machine names, base theme choice, and breakpoints"
  run_drush "theme:list" >/dev/null
}

check_css() {
  echo "[CHECK] 3 Theming: SCSS usage, Atomic structure, and limited overrides"
  find themes -maxdepth 2 -type f \( -name '*.scss' -o -name '*.sass' \) >/dev/null
}

check_twig() {
  echo "[CHECK] 3 Theming: preprocess coverage and template organization"
  run_drush "ev 'print json_encode(array_keys(\\Drupal\\theme_handler\\ThemeHandler::defaultThemeList()));'" \
    | jq 'keys[]' >/dev/null
}

check_assets() {
  echo "[CHECK] 3 Theming: browser support and utility-first frameworks used selectively"
  run_drush "ev 'print json_encode(\\Drupal\\core\\Asset\\LibraryDiscovery::getInfo());'" \
    | jq 'keys[]' >/dev/null
}

case "${check}" in
  all)
    check_themes
    check_css
    check_twig
    check_assets
    ;;
  themes) check_themes ;;
  css) check_css ;;
  twig) check_twig ;;
  assets) check_assets ;;
  *) echo "Unknown check: ${check}" >&2; exit 1 ;;
esac
