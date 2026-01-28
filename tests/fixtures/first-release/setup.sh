#!/bin/bash

# Setup script for first release test fixture
# Creates a repository with no tags for testing initial version

set -e

FIXTURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up first release test fixture..."

git init
git config user.name "Test User"
git config user.email "test@example.com"

# Create initial project
echo "# New Project" > README.md
echo "A brand new project ready for its first release." >> README.md
git add README.md
git commit -m "feat: initial project setup"

mkdir -p src
echo "export function main() { console.log('Hello'); }" > src/index.js
git add src/
git commit -m "feat: add main function"

echo "export function helper() { return 'helper'; }" > src/utils.js
git add src/
git commit -m "feat: add utility functions"

# Add tests
mkdir -p tests
echo "// TODO: Add tests" > tests/index.test.js
git add tests/
git commit -m "test: add test structure"

echo ""
echo "✓ First release test fixture created successfully!"
echo ""
echo "This repo has:"
echo "  - Current tag: (none)"
echo "  - New commits: 4 (3 feat, 1 test)"
echo "  - Expected version: v0.1.0 (first release)"
echo ""
