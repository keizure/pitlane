#!/bin/bash

# Setup script for breaking change test fixture
# Creates a repository with breaking changes for testing MAJOR version bump

set -e

FIXTURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up breaking change test fixture..."

git init
git config user.name "Test User"
git config user.email "test@example.com"

# Initial setup
echo "# API Project" > README.md
git add README.md
git commit -m "chore: initial commit"

mkdir -p src
echo "export const API_VERSION = 1;" > src/api.js
echo "export function getData() { return { version: 1 }; }" >> src/api.js
git add src/
git commit -m "feat: add API v1"

git tag -a v1.5.2 -m "Release v1.5.2"

# Breaking change
echo "export const API_VERSION = 2;" > src/api.js
echo "export async function getData() { return { version: 2 }; }" >> src/api.js
git add src/
git commit -m "feat!: redesign API to use async/await

BREAKING CHANGE: getData() is now async and returns a Promise.
Update all calls to use await getData() instead of getData()."

echo "# Migration Guide" > MIGRATION.md
echo "## v1 to v2" >> MIGRATION.md
echo "- \`getData()\` is now async" >> MIGRATION.md
git add MIGRATION.md
git commit -m "docs: add migration guide for v2"

echo ""
echo "✓ Breaking change test fixture created successfully!"
echo ""
echo "This repo has:"
echo "  - Current tag: v1.5.2"
echo "  - Breaking change: API redesign"
echo "  - Expected bump: MAJOR (v2.0.0)"
echo ""
