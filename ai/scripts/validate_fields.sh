#!/usr/bin/env bash
set -euo pipefail

# Validate field configurations against README section 2.5.
# Usage: ./ai/scripts/validate_fields.sh

if ! command -v drush >/dev/null 2>&1; then
  echo "[error] drush not found. Install drush or run within a Drupal project." >&2
  exit 1
fi

issues=0

read -r -d '' PHP_SCRIPT <<'PHP'
use Drupal\field\Entity\FieldStorageConfig;
use Drupal\field\Entity\FieldConfig;

$storages = FieldStorageConfig::loadMultiple();
foreach ($storages as $storage) {
  $id = $storage->id();
  $field_name = $storage->getName();
  $machine_valid = preg_match('/^field_[a-z0-9_]+$/', $field_name);
  $shared_prefix = preg_match('/^field_(shared|common|srd)_/', $field_name);

  if (!$machine_valid) {
    echo "[machine-name] {$id} should follow field_[entity]_short pattern\n";
  }
  if ($storage->isShared() && !$shared_prefix) {
    echo "[shared-prefix] {$id} is reused but lacks a shared/common prefix\n";
  }
}

$field_configs = FieldConfig::loadMultiple();
foreach ($field_configs as $config) {
  $name = $config->getName();
  $label = $config->label();
  $description = trim((string) $config->getDescription());
  $settings = $config->getSettings();

  if ($description === '') {
    echo "[description] {$name} on {$config->getTargetEntityTypeId()}.{$config->getTargetBundle()} is missing a description\n";
  }

  if ($config->getType() === 'image') {
    $dir = $settings['file_directory'] ?? '';
    if ($dir === '' || str_contains($dir, '[date:custom')) {
      echo "[image-directory] {$name} uses default or date-based directories; set a meaningful folder name\n";
    }
    $extensions = $settings['file_extensions'] ?? '';
    if (preg_match('/\bgif\b/i', $extensions)) {
      echo "[image-extension] {$name} allows gif; remove unless explicitly required\n";
    }
  }
}
PHP

output=$(drush php:eval "$PHP_SCRIPT" || true)
if [[ -n "${output}" ]]; then
  echo "Field configuration issues:" >&2
  echo "$output" >&2
  issues=1
fi

if [[ $issues -eq 0 ]]; then
  echo "Fields align with best practices."
fi

exit $issues
