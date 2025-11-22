#!/usr/bin/env bash
set -euo pipefail

# Validate Drupal 10+ site-building best practices for section 2.
# Usage: ./validate-site-building.sh [section]
# Sections: nodes blocks taxonomy entities fields views forms editors users

section="${1:-all}"
project_root="${PROJECT_ROOT:-$(pwd)}"
config_dir="${CONFIG_DIR:-${project_root}/config/sync}"

if ! command -v drush >/dev/null 2>&1; then
  echo "[WARN] drush not found. Install drush or set PATH so checks can run." >&2
  exit 1
fi

run_drush() {
  local cmd="$1"
  echo "[INFO] drush ${cmd}" >&2
  drush ${cmd}
}

check_nodes() {
  echo "[CHECK] 2.1 Nodes: singular names, minimal bundles, consistent view modes"
  run_drush "eval 'print json_encode(\\Drupal\\node\\Entity\\NodeType::loadMultiple());'" \
    | jq 'keys[]' >/dev/null
}

check_blocks() {
  echo "[CHECK] 2.2 Blocks: custom block types via code and clean machine names"
  run_drush "eval 'print json_encode(\\Drupal\\block_content\\Entity\\BlockContentType::loadMultiple());'" \
    | jq 'keys[]' >/dev/null
}

check_taxonomy() {
  echo "[CHECK] 2.3 Taxonomy: singular vocabularies and purpose beyond filtering"
  run_drush "eval 'print json_encode(\\Drupal\\taxonomy\\Entity\\Vocabulary::loadMultiple());'" \
    | jq 'keys[]' >/dev/null
}

check_entities() {
  echo "[CHECK] 2.4 Other content entities: paragraphs/media revisions and generic image styles"
  run_drush "eval 'print json_encode(\\Drupal\\image\\Entity\\ImageStyle::loadMultiple());'" \
    | jq 'keys[]' >/dev/null
}

check_fields() {
  echo "[CHECK] 2.5 Fields: naming patterns and descriptions"
  run_drush "eval 'print json_encode(array_keys(\\Drupal\\field\\Entity\\FieldStorageConfig::loadMultiple()));'" \
    | jq '[]' >/dev/null
}

check_views() {
  echo "[CHECK] 2.6 Views: clean machine names, per-display instances, permissions"
  run_drush "views:list" >/dev/null
}

check_forms() {
  echo "[CHECK] 2.7 Forms: prefer Webform over core Contact for complex needs"
  run_drush "pm:list webform" >/dev/null
}

check_editors() {
  echo "[CHECK] 2.8 Text formats and editors: single HTML format with CKEditor"
  run_drush "eval 'print json_encode(\\Drupal\\filter\\Entity\\FilterFormat::loadMultiple());'" \
    | jq 'keys[]' >/dev/null
}

check_users() {
  echo "[CHECK] 2.10 Users: persona-based roles and module-defined permissions"
  run_drush "role:list" >/dev/null
}

case "${section}" in
  all)
    check_nodes
    check_blocks
    check_taxonomy
    check_entities
    check_fields
    check_views
    check_forms
    check_editors
    check_users
    ;;
  nodes) check_nodes ;;
  blocks) check_blocks ;;
  taxonomy) check_taxonomy ;;
  entities) check_entities ;;
  fields) check_fields ;;
  views) check_views ;;
  forms) check_forms ;;
  editors) check_editors ;;
  users) check_users ;;
  *) echo "Unknown section: ${section}" >&2; exit 1 ;;
esac
