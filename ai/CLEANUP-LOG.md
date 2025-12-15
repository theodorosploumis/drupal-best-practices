# AI Directory Cleanup Log

This document tracks the cleanup performed on `/ai/` directory to remove stale, duplicate, and outdated files.

## Removed Files (December 2025)

### Duplicate Scripts
Removed older underscore-named versions that lacked DDEV support and dual-mode validation:
- `scripts/validate_nodes.sh`
- `scripts/validate_fields.sh`
- `scripts/validate_blocks.sh`
- `scripts/validate_taxonomy.sh`
- `scripts/validate_views.sh`
- `scripts/validate_theming.sh`
- `scripts/validate_text_formats.sh`

**Reason**: These were superseded by hyphenated versions with enhanced features including:
- DDEV environment detection
- Static YAML validation support
- Better error handling
- More comprehensive validation

### Duplicate Root Files
- `commands.md` (kept only in `commands/` subdirectory)
- `rules.md` (kept only in `rules/` subdirectory)
- `claude-skills/` directory (merged into `skills/`)

**Reason**: Consolidated to single locations to avoid confusion

### Redundant Documentation
- All `skills/*/scripts/README.md` files (12 files removed)

**Reason**: These were brief, single-line files pointing to specific scripts. The new dual-mode validation scripts make these obsolete.

### Empty Directories
- `skills/config-parser/scripts/`

**Reason**: Empty after removing README.md

## Renamed Files
- `claude-code-skills.md` → `SKILLS-INDEX.md` (root level)

**Reason**: Distinguish from the skills-specific documentation in `skills/claude-code-skills.md`

## Current Structure After Cleanup

```
ai/
├── AGENTS.md                    # Authoring guidelines (updated)
├── README.md                    # Main documentation (updated)
├── SKILLS-INDEX.md              # Skills index (renamed)
├── claude.json                  # Claude Code manifest
├── skills/                      # Unified skills directory
│   ├── claude-code-skills.md    # Skills documentation
│   ├── blocks/                  # Skill directories
│   ├── config-parser/
│   ├── fields/
│   ├── forms/
│   ├── nodes/
│   ├── other-content-entities/
│   ├── taxonomy/
│   ├── text-formats-editors/
│   ├── theming/
│   └── views/
├── scripts/                     # Validation scripts (cleaned)
│   ├── ddev-drush-helper.sh
│   ├── validate-blocks.sh
│   ├── validate-config.sh       # New config parser
│   ├── validate-fields.sh
│   ├── validate-nodes.sh        # Enhanced with dual-mode
│   ├── validate-taxonomy.sh
│   ├── validate-text-formats.sh
│   ├── validate-theming.sh
│   └── validate-views.sh
├── commands/                    # Slash commands
│   └── commands.md
├── rules/                       # AI rules
│   └── general-rules.md
└── utils/                       # Helper scripts
    ├── DDEV-SUPPORT.md
    ├── README.md
    ├── release.sh
    └── validate.sh
```

## Benefits Achieved

1. **No Duplicates**: Removed all duplicate scripts and documentation
2. **Consistent Naming**: All scripts use hyphenated naming convention
3. **Clear Structure**: Single location for each type of content
4. **Enhanced Functionality**: All remaining scripts support dual-mode validation
5. **Better Documentation**: Updated to reflect current structure and capabilities