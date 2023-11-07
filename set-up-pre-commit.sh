#!/bin/sh

chmod +x check-credentials.py

# Copy the pre-commit hook to the .git/hooks directory
cp -f pre-commit .git/hooks/pre-commit

chmod +x .git/hooks/pre-commit

echo "Pre-commit hook installed."
