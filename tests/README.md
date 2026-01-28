# Testing Guide

## Overview

This directory contains tests for the pitlane skills and commands. Since skills are prompt-driven workflows, we use integration tests to validate their behavior in realistic scenarios.

## Test Structure

```
tests/
├── README.md                 # This file
├── fixtures/                 # Test repository fixtures
│   ├── basic/               # Basic repo with conventional commits
│   ├── breaking-change/     # Repo with breaking changes
│   ├── first-release/       # Repo with no tags
│   └── monorepo/            # Multi-package repo
├── integration/             # Integration tests
│   └── test_release_tag.sh  # Test release-tag skill
└── utils/                   # Test utilities
    └── setup_fixture.sh     # Script to create test repos

```

## Running Tests

### Quick Test
```bash
# Run all tests
./tests/run_tests.sh

# Run specific test
./tests/integration/test_release_tag.sh
```

### Manual Testing
```bash
# 1. Set up a test fixture
cd tests/fixtures/basic
./setup.sh

# 2. Test the skill manually in Claude Code
# Navigate to the test fixture directory and invoke the skill
```

## Test Scenarios

### Scenario 1: Basic Minor Release
- **Setup**: Repo with existing tags and new features
- **Expected**: Correctly identifies MINOR bump, creates v1.3.0

### Scenario 2: Breaking Change (Major)
- **Setup**: Repo with BREAKING CHANGE commit
- **Expected**: Correctly identifies MAJOR bump, creates v2.0.0

### Scenario 3: First Release
- **Setup**: Repo with no existing tags
- **Expected**: Creates v0.1.0 as first tag

### Scenario 4: Patch Release
- **Setup**: Repo with only bug fixes
- **Expected**: Correctly identifies PATCH bump, creates v1.2.4

### Scenario 5: Dirty Working Tree
- **Setup**: Repo with uncommitted changes
- **Expected**: Stops and asks user to commit/stash

## Validation Checklist

For each test, verify:
- [ ] Correct version bump type identified
- [ ] Correct new version calculated
- [ ] Tag created with proper annotation
- [ ] Release notes are well-formatted
- [ ] No git errors occurred
- [ ] Safety checks passed (no force push, no dirty tree)

## Adding New Tests

1. Create a new fixture in `tests/fixtures/`
2. Add setup script that creates the test scenario
3. Add test case to `tests/integration/test_release_tag.sh`
4. Document expected behavior in this README

## CI/CD Integration

Tests run automatically on:
- Pull requests
- Pushes to main/master
- Manual workflow dispatch

See `.github/workflows/test.yml` for details.
