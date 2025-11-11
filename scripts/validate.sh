#!/bin/bash
# Validation script for repository structure and configuration

set -e

echo "Starting validation..."

# Check required directories
echo "Checking directory structure..."
required_dirs=(".github/workflows" ".github/agents" "scripts" "config")
for dir in "${required_dirs[@]}"; do
  if [ -d "$dir" ]; then
    echo "✓ $dir exists"
  else
    echo "✗ $dir missing"
    exit 1
  fi
done

# Check required files
echo "Checking required files..."
required_files=("LICENSE" ".gitignore" "README.md")
for file in "${required_files[@]}"; do
  if [ -f "$file" ]; then
    echo "✓ $file exists"
  else
    echo "✗ $file missing"
    exit 1
  fi
done

# Validate configuration files
echo "Validating configuration files..."
if [ -f "config/app-config.json" ]; then
  echo "✓ Configuration file found"
  # Basic JSON validation
  if command -v jq &> /dev/null; then
    jq empty config/app-config.json && echo "✓ Configuration is valid JSON"
  else
    echo "  (jq not available, skipping JSON validation)"
  fi
fi

echo "✅ All validations passed!"
