# Application Configuration

This directory contains configuration files for the poc1-secure-access project.

## Files

- `app-config.json` - Main application configuration
  - Application metadata (name, version, description)
  - Security settings
  - Pipeline configuration
  - Environment configuration

## Usage

Configuration files are used by:
- GitHub Actions workflows
- Validation scripts
- Application runtime (when deployed)

## Modifying Configuration

1. Edit the appropriate configuration file
2. Validate JSON syntax (e.g., using `jq` or online validators)
3. Commit and push changes
4. The CI pipeline will validate the configuration

## Security Notes

- Never commit sensitive data (passwords, tokens, API keys) in configuration files
- Use GitHub Secrets for sensitive values
- Configuration files are part of the repository and visible to all with access
