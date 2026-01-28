#!/bin/bash

# Setup script for internal maintenance test fixture
# Creates a repository with only internal changes (chore, test, refactor)

set -e

FIXTURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up internal maintenance test fixture..."

git init
git config user.name "Test User"
git config user.email "test@example.com"

# Initial setup
echo "# Project" > README.md
git add README.md
git commit -m "chore: initial commit"

mkdir -p src
echo "export function main() {}" > src/index.js
git add src/
git commit -m "feat: add main function"

git tag -a v1.0.0 -m "Release v1.0.0"

# Only internal changes after v1.0.0
echo "# Tests" > tests/index.test.js
git add tests/
git commit -m "test: add test structure"

# Refactor
echo "export function main() { return 'refactored'; }" > src/index.js
git add src/
git commit -m "refactor: improve main function structure"

# Chore
echo "node_modules/" > .gitignore
git add .gitignore
git commit -m "chore: add gitignore"

# Docs
echo "## Installation" >> README.md
git add README.md
git commit -m "docs: add installation instructions"

echo ""
echo "✓ Internal maintenance test fixture created successfully!"
echo ""
echo "This repo has:"
echo "  - Current tag: v1.0.0"
echo "  - Changes: test, refactor, chore, docs (no feat/fix)"
echo "  - Expected: PATCH bump with 'No user-visible changes' note"
echo ""
