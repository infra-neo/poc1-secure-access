#!/usr/bin/env bash
# Main setup script - delegates to install_stack.sh
set -e

echo "Starting PoC1 setup..."
echo ""

# Check if .env exists, if not run init_env.sh
if [ ! -f "config/.env" ]; then
    echo "No .env file found. Running init_env.sh first..."
    bash scripts/init_env.sh
    echo ""
fi

# Run the full installation
bash scripts/install_stack.sh

