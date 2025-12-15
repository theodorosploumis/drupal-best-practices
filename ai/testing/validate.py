#!/usr/bin/env python3
"""
Drupal Skills Validation Script

This script validates Drupal skills against real configuration files.
It randomly selects a skill and tests it against configuration files.
"""

import argparse
import os
import random
import subprocess
import sys
import yaml
from pathlib import Path
from typing import List, Dict, Optional

class Colors:
    """ANSI color codes for output"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

def print_error(msg: str):
    """Print error message"""
    print(f"{Colors.RED}[ERROR]{Colors.NC} {msg}")

def print_warning(msg: str):
    """Print warning message"""
    print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {msg}")

def print_info(msg: str):
    """Print info message"""
    print(f"{Colors.BLUE}[INFO]{Colors.NC} {msg}")

def print_success(msg: str):
    """Print success message"""
    print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {msg}")

def find_skills() -> List[Dict[str, str]]:
    """Find all available skills in the skills directory"""
    skills_dir = Path(__file__).parent.parent / "skills"
    skills = []

    for skill_dir in skills_dir.iterdir():
        if skill_dir.is_dir() and (skill_dir / "SKILL.md").exists():
            # Parse the SKILL.md to get the ID
            with open(skill_dir / "SKILL.md", 'r') as f:
                content = f.read()

            # Extract YAML frontmatter
            if content.startswith('---'):
                _, frontmatter, _ = content.split('---', 2)
                try:
                    metadata = yaml.safe_load(frontmatter)
                    skill_id = metadata.get('id', skill_dir.name)
                    skill_title = metadata.get('title', skill_dir.name.replace('-', ' ').title())
                    skills.append({
                        'id': skill_id,
                        'title': skill_title,
                        'path': skill_dir,
                        'name': skill_dir.name
                    })
                except yaml.YAMLError:
                    print_warning(f"Could not parse SKILL.md in {skill_dir}")

    return skills

def find_config_files(config_dir: Path) -> List[Path]:
    """Find all YAML config files"""
    config_files = []
    for pattern in ['**/*.yml', '**/*.yaml']:
        config_files.extend(config_dir.glob(pattern))
    return config_files

def get_validation_script(skill_name: str) -> Optional[Path]:
    """Get the validation script for a skill"""
    # For config-parser skill, use validate-config.sh
    if skill_name == 'config-parser':
        script_path = Path(__file__).parent.parent / "scripts" / "validate-config.sh"
        if script_path.exists():
            return script_path

    # For other skills, try individual validation scripts
    script_path = Path(__file__).parent.parent / "scripts" / f"validate-{skill_name}.sh"

    if script_path.exists():
        return script_path

    # Try with alternative naming
    script_path = Path(__file__).parent.parent / "scripts" / f"validate_{skill_name}.sh"
    if script_path.exists():
        return script_path

    return None

def run_validation(script_path: Path, config_dir: Path, skill_name: str) -> tuple[int, str, str]:
    """Run a validation script"""
    env = os.environ.copy()
    env['CONFIG_PATH'] = str(config_dir)

    try:
        # Run the script in static mode
        # Try to run with static mode options
        cmd = [str(script_path)]
        if '--mode' in open(script_path).read():
            cmd.extend(['--mode', 'static'])
        if '--path' in open(script_path).read():
            cmd.extend(['--path', str(config_dir)])

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            env=env,
            timeout=30  # 30 second timeout
        )

        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return 1, "", "Validation script timed out"
    except Exception as e:
        return 1, "", f"Error running validation: {str(e)}"

def analyze_config_violations(skill_name: str, config_files: List[Path]) -> Dict[str, int]:
    """Analyze config files for expected violations based on skill type"""
    violations = {
        'errors': 0,
        'warnings': 0,
        'info': 0
    }

    # Count expected violations based on file names and content
    for config_file in config_files:
        file_name = config_file.name.lower()

        if skill_name == 'nodes':
            if 'news_articles' in file_name:
                violations['warnings'] += 1  # Plural name
                violations['errors'] += 1    # No description
            if 'pages' in file_name:
                violations['errors'] += 2    # Plural name + status false

        elif skill_name == 'views':
            if '_1' in file_name:
                violations['errors'] += 1    # _1 suffix

        elif skill_name == 'blocks':
            # Would need to analyze content for UUID patterns
            pass

        elif skill_name == 'taxonomy':
            # Check for vocabularies that should be list fields
            pass

    return violations

def main():
    parser = argparse.ArgumentParser(
        description='Validate Drupal skills against configuration files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                          # Validate random skill
  %(prog)s --skill nodes             # Validate specific skill
  %(prog)s --config-dir /path/to/config  # Use specific config directory
  %(prog)s --list                    # List all available skills
        """
    )

    parser.add_argument(
        '--skill', '-s',
        help='Specific skill to validate (default: random)'
    )

    parser.add_argument(
        '--config-dir', '-c',
        default=Path(__file__).parent / "config",
        type=Path,
        help='Directory containing config files (default: testing/config)'
    )

    parser.add_argument(
        '--list', '-l',
        action='store_true',
        help='List all available skills'
    )

    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Verbose output'
    )

    args = parser.parse_args()

    # Find all skills
    skills = find_skills()

    if not skills:
        print_error("No skills found!")
        sys.exit(1)

    # List skills if requested
    if args.list:
        print_info("Available skills:")
        for skill in skills:
            print(f"  - {skill['id']}: {skill['title']}")
        return

    # Select skill
    if args.skill:
        selected_skill = next((s for s in skills if s['id'] == args.skill or s['name'] == args.skill), None)
        if not selected_skill:
            print_error(f"Skill '{args.skill}' not found!")
            sys.exit(1)
    else:
        selected_skill = random.choice(skills)

    print_info(f"Validating skill: {selected_skill['title']} ({selected_skill['id']})")

    # Find config files
    config_dir = args.config_dir
    if not config_dir.exists():
        print_error(f"Config directory not found: {config_dir}")
        sys.exit(1)

    config_files = find_config_files(config_dir)
    if not config_files:
        print_error(f"No config files found in: {config_dir}")
        sys.exit(1)

    print_info(f"Found {len(config_files)} config files")

    # Get validation script
    script_path = get_validation_script(selected_skill['name'])
    if not script_path:
        print_warning(f"No validation script found for skill: {selected_skill['name']}")

        # Still analyze for expected violations
        violations = analyze_config_violations(selected_skill['name'], config_files)
        if violations['errors'] > 0 or violations['warnings'] > 0:
            print_warning(f"Expected violations found: {violations}")
        else:
            print_success("No obvious violations found")
        return

    # Run validation
    print_info(f"Running validation script: {script_path.name}")

    returncode, stdout, stderr = run_validation(script_path, config_dir, selected_skill['name'])

    if args.verbose:
        print("\n--- STDOUT ---")
        print(stdout)
        if stderr:
            print("\n--- STDERR ---")
            print(stderr)

    # Analyze results
    if returncode == 0:
        print_success("Validation passed")
    else:
        print_error(f"Validation failed (exit code: {returncode})")

        # Count issues from output
        error_count = stdout.lower().count('[error]') + stderr.lower().count('[error]')
        warning_count = stdout.lower().count('[warning]') + stderr.lower().count('[warning]')

        if error_count > 0:
            print_error(f"Found {error_count} errors")
        if warning_count > 0:
            print_warning(f"Found {warning_count} warnings")

    # Print summary
    print(f"\n{'='*50}")
    print(f"Skill: {selected_skill['title']}")
    print(f"Config Files: {len(config_files)}")
    print(f"Exit Code: {returncode}")
    print(f"{'='*50}")

    sys.exit(returncode)

if __name__ == "__main__":
    main()