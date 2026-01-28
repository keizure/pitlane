#!/bin/bash

# Setup script for basic test fixture
# Creates a sample repository for manual testing of release-tag skill

set -e

FIXTURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up basic test fixture..."

# Initialize git repo
git init

# Configure git
git config user.name "Test User"
git config user.email "test@example.com"

# Create initial commit
echo "# Sample Project" > README.md
echo "This is a test project for validating the release-tag skill." >> README.md
git add README.md
git commit -m "chore: initial commit"

# Create first tag
git tag -a v1.0.0 -m "Release v1.0.0

Initial release of the project."

# Add some features
mkdir -p src
echo "console.log('Hello World');" > src/index.js
git add src/
git commit -m "feat: add initial implementation"

echo "export function greet(name) { return \`Hello \${name}\`; }" > src/greet.js
git add src/
git commit -m "feat: add greet function"

# Add a bug fix
echo "// Fix: handle null values" >> src/greet.js
echo "export function greet(name) { return \`Hello \${name || 'World'}\`; }" > src/greet.js
git add src/
git commit -m "fix: handle null values in greet function"

# Add some docs
echo "## API" >> README.md
echo "- \`greet(name)\` - Returns a greeting" >> README.md
git add README.md
git commit -m "docs: add API documentation"

# Add another feature
echo "export function farewell(name) { return \`Goodbye \${name || 'World'}\`; }" > src/farewell.js
git add src/
git commit -m "feat: add farewell function"

echo ""
echo "✓ Basic test fixture created successfully!"
echo ""
echo "This repo has:"
echo "  - Current tag: v1.0.0"
echo "  - New commits: 4 (2 feat, 1 fix, 1 docs)"
echo "  - Expected bump: MINOR (v1.1.0)"
echo ""
echo "To test the release-tag skill:"
echo "  1. cd to this directory"
echo "  2. Open Claude Code"
echo "  3. Run: /release-tag"
echo ""
