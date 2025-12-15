#!/usr/bin/env bash
set -euo pipefail

# Validate text formats and editors against README section 2.8.
# Usage: ./ai/scripts/validate_text_formats.sh

if ! command -v drush >/dev/null 2>&1; then
  echo "[error] drush not found. Install drush or run within a Drupal project." >&2
  exit 1
fi

issues=0

read -r -d '' PHP_SCRIPT <<'PHP'
use Drupal\filter\Entity\FilterFormat;
use Drupal\editor\Entity\Editor;

$formats = FilterFormat::loadMultiple();
$html_formats = [];
foreach ($formats as $format) {
  $id = $format->id();
  $name = $format->label();
  $filters = $format->filters();
  $is_plain = $id === 'plain_text';
  $allows_php = $filters->has('php_code') && $filters->get('php_code')->status;
  $has_html_filter = $filters->has('filter_html') && $filters->get('filter_html')->status;
  if (!$is_plain && $has_html_filter) {
    $html_formats[] = $id;
  }
  if ($allows_php) {
    echo "[unsafe] {$id} allows PHP input; keep unsafe content in code only\n";
  }
  $editor = Editor::load($id);
  if (!$is_plain) {
    if (!$editor) {
      echo "[editor] {$id} has no editor config; prefer CKEditor\n";
    } elseif ($editor->getEditor() !== 'ckeditor5') {
      echo "[editor] {$id} uses {$editor->getEditor()}; prefer CKEditor\n";
    }
  }
}

if (count($html_formats) > 1) {
  echo "[formats] Multiple HTML formats detected (" . implode(', ', $html_formats) . "); prefer a single HTML format\n";
}
PHP

output=$(drush php:eval "$PHP_SCRIPT" || true)
if [[ -n "${output}" ]]; then
  echo "Text format issues:" >&2
  echo "$output" >&2
  issues=1
fi

if [[ $issues -eq 0 ]]; then
  echo "Text formats align with best practices."
fi

exit $issues
