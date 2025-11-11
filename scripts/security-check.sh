#!/bin/bash
# Security check script

set -e

echo "Starting security checks..."

# Check for common security issues
echo "Checking for sensitive files..."

# Check for accidentally committed secrets
if git log --all --full-history -- "*.pem" "*.key" "*.env" | grep -q .; then
  echo "⚠ Warning: Found potential secret files in git history"
fi

# Check for hardcoded passwords or tokens in code
echo "Checking for hardcoded secrets..."
if grep -r -i "password\s*=\s*['\"]" . --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null | grep -v "password\s*=\s*['\"]['\"]" | grep -v ".sh:"; then
  echo "⚠ Warning: Potential hardcoded passwords found"
else
  echo "✓ No hardcoded passwords detected"
fi

# Check file permissions
echo "Checking file permissions..."
if find . -type f -perm /111 -name "*.sh" | grep -q .; then
  echo "✓ Script files have executable permissions"
fi

# Validate that scripts are properly formatted
echo "Validating shell scripts..."
for script in scripts/*.sh; do
  if [ -f "$script" ]; then
    if bash -n "$script"; then
      echo "✓ $script syntax is valid"
    else
      echo "✗ $script has syntax errors"
      exit 1
    fi
  fi
done

echo "✅ Security checks completed!"
