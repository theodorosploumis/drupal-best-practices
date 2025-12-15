# DDEV Support for Validation Scripts

All validation scripts in the `ai/scripts/` directory now support DDEV environments automatically.

## How It Works

The scripts use a helper function (`ddev-drush-helper.sh`) that:

1. **Detects DDEV environment** by checking for:
   - DDEV CLI availability
   - Presence of `.ddev/config.yaml` file
   - Successful `ddev describe` command

2. **Chooses the appropriate Drush command**:
   - In DDEV environment: uses `ddev drush`
   - Outside DDEV: uses local `drush` or `./vendor/bin/drush`

3. **Provides fallback options**:
   - Checks for global Drush installation
   - Looks for project-specific Drush in `vendor/bin/drush`

## Usage

### In a DDEV Project
```bash
# From the project root (where .ddev/ directory exists)
./ai/scripts/validate_nodes.sh
# The script will automatically use 'ddev drush' commands
```

### Outside DDEV
```bash
# From any Drupal project with Drush installed
./ai/scripts/validate_nodes.sh
# The script will use 'drush' or './vendor/bin/drush'
```

### Manual Override
If you need to explicitly use DDEV or local Drush, you can:
```bash
# Force DDEV usage
ddev exec ./ai/scripts/validate_nodes.sh

# Use local Drush in a DDEV project
DRUSH_SKIP_DDEV=1 ./ai/scripts/validate_nodes.sh
```

## Implementation Details

### The DDEV Drush Helper

The `ddev-drush-helper.sh` script provides these functions:

- `is_ddev_environment()` - Returns 0 if in DDEV, 1 otherwise
- `get_drush_command()` - Returns the appropriate Drush command string
- `run_drush()` - Executes Drush with the correct command and arguments
- `check_drush()` - Validates Drush availability with DDEV support

### Integration in Scripts

Each validation script:
1. Sources the helper at the top
2. Uses `check_drush` for validation
3. Replaces `drush` calls with `run_drush`

Example:
```bash
# Before:
if ! command -v drush >/dev/null 2>&1; then
  echo "[error] drush not found"
  exit 1
fi
drush php:eval "$code"

# After:
check_drush
run_drush php:eval "$code"
```

## Benefits

1. **Seamless DDEV integration** - No configuration required
2. **Backward compatibility** - Works with traditional Drush setups
3. **Automatic detection** - Scripts adapt to the environment
4. **Clear error messages** - Helpful feedback when Drush isn't available

## Troubleshooting

### "Drush not found" error
- In DDEV: Ensure DDEV is running (`ddev start`)
- Outside DDEV: Install Drush globally or ensure it's in `vendor/bin`

### Scripts using wrong Drush
- Check if you're in the correct directory
- Verify DDEV project is initialized
- Ensure `.ddev/config.yaml` exists

### DDEV not detected
```bash
# Check if DDEV is properly configured
ddev describe

# Verify you're in the right directory
ls -la .ddev/
```

## Best Practices

1. **Run scripts from project root** - This ensures proper DDEV detection
2. **Keep DDEV running** - Scripts work faster when DDEV is already started
3. **Use consistent Drush version** - Ensure DDEV and local Drush versions are compatible when switching environments
4. **Test in both environments** - Validate scripts work both with and without DDEV