# Scripts Directory

This directory contains utility scripts for the poc1-secure-access project.

## Available Scripts

### validate.sh
Validates the repository structure and configuration.

**Purpose**: Ensures that all required directories and files are present and properly configured.

**Usage**:
```bash
bash scripts/validate.sh
```

**Checks**:
- Required directories exist (`.github/workflows`, `.github/agents`, `scripts`, `config`)
- Required files exist (`LICENSE`, `.gitignore`, `README.md`)
- Configuration files are valid JSON

### security-check.sh
Performs security checks on the repository.

**Purpose**: Identifies potential security issues in the codebase.

**Usage**:
```bash
bash scripts/security-check.sh
```

**Checks**:
- Sensitive files in git history
- Hardcoded passwords or tokens
- File permissions
- Shell script syntax validation

## Adding New Scripts

1. Create your script in this directory
2. Make it executable: `chmod +x scripts/your-script.sh`
3. Add documentation to this README
4. Include it in the CI pipeline if needed

## Best Practices

- Always use `set -e` to exit on errors
- Include clear echo messages for progress tracking
- Validate inputs when accepting parameters
- Document usage and purpose clearly
