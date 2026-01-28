# Quick Validation Guide

Use this guide to quickly validate your changes to the release-tag skill.

## Method 1: Automated Tests (Recommended)

```bash
# Run all tests
cd tests
./run_tests.sh
```

Expected output: All tests should pass (8/8)

## Method 2: Manual Testing with Fixtures

### Setup a test fixture
```bash
cd tests/fixtures/basic
./setup.sh
```

### Test in Claude Code
1. Open Claude Code in the fixture directory
2. Run the skill: `/release-tag` or say "create a release tag"
3. Verify the output:
   - Should detect MINOR bump (v1.0.0 → v1.1.0)
   - Should show 4 commits (2 feat, 1 fix, 1 docs)
   - Should generate proper release notes

### Available test scenarios
```bash
cd tests/fixtures/basic            # MINOR bump test
cd tests/fixtures/breaking-change  # MAJOR bump test
cd tests/fixtures/first-release    # First release (v0.1.0)
```

## Method 3: Real-World Test

Test on this project itself:

```bash
# In the pitlane project root
# Use Claude Code to run: /release-tag

# Should detect version bump based on commits since last tag
# Should generate release notes from real commits
```

## What to Check

For each test, verify:
- ✓ Correct version bump type (MAJOR/MINOR/PATCH)
- ✓ Correct new version number
- ✓ Well-formatted release notes
- ✓ Safety checks pass (clean working tree)
- ✓ No git errors

## Quick Verification Checklist

After making changes to the skill:

- [ ] Run automated tests (`./tests/run_tests.sh`)
- [ ] Test at least one manual fixture
- [ ] Verify release notes quality
- [ ] Check error handling (dirty tree, no commits, etc.)
- [ ] Update version in plugin.json if needed

## Troubleshooting

### Tests fail with "git command not found"
Install git: `brew install git` (macOS) or `apt-get install git` (Linux)

### Fixture setup fails
Check git configuration:
```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### Skill doesn't load in Claude Code
1. Check SKILL.md frontmatter format
2. Verify plugin.json is valid JSON
3. Try reinstalling: `/plugin uninstall pitlane` then `/plugin install pitlane@pitlane`
