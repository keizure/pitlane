# Testing Guide

## Overview

This directory contains tests for pitlane skills and commands. Tests are organized hierarchically by component type for easy maintenance and scalability.

## Directory Structure

```
tests/
├── README.md                        # This file
├── SUMMARY.md                       # Test summary and status
├── run_tests.sh                     # Main test runner (auto-discovery)
│
├── skills/                          # Skill tests
│   └── release-tag/                # release-tag skill
│       ├── test_release_tag.sh     # Comprehensive test suite
│       └── fixtures/               # Test scenarios
│           ├── basic/              # MINOR bump scenario
│           ├── breaking-change/    # MAJOR bump scenario
│           ├── first-release/      # First release scenario
│           └── internal-maintenance/ # Internal changes only
│
└── commands/                        # Command tests (future)
    └── (future command tests)
```

## Running Tests

### Run All Tests (Recommended)

The test runner automatically discovers and runs all tests:

```bash
cd tests
./run_tests.sh
```

### Run Specific Skill/Command Tests

```bash
# Run release-tag tests only
bash skills/release-tag/test_release_tag.sh

# Future: Run specific command tests
bash commands/some-command/test_some_command.sh
```

### Manual Testing with Fixtures

```bash
# Set up a test fixture
cd skills/release-tag/fixtures/basic
./setup.sh

# Then test the skill in Claude Code
# Navigate to the fixture directory and invoke: /release-tag
```

## Test Organization

### Skills Tests

Each skill has its own directory under `tests/skills/`:
- `test_<skill-name>.sh` - Main test script
- `fixtures/` - Test scenarios for manual testing

### Commands Tests

Each command has its own directory under `tests/commands/`:
- `test_<command-name>.sh` - Main test script
- Test data as needed

## Adding New Tests

### 1. Adding Tests for a New Skill

```bash
# Create skill test directory
mkdir -p tests/skills/your-skill/fixtures

# Create test script
cat > tests/skills/your-skill/test_your_skill.sh << 'EOF'
#!/bin/bash
# Test suite for your-skill

set -e

# Your tests here
# ...

# The runner will auto-discover this file
EOF

chmod +x tests/skills/your-skill/test_your_skill.sh

# Run tests
./run_tests.sh
```

### 2. Adding Tests for a New Command

```bash
# Create command test directory
mkdir -p tests/commands/your-command

# Create test script
cat > tests/commands/your-command/test_your_command.sh << 'EOF'
#!/bin/bash
# Test suite for your-command

set -e

# Your tests here
# ...
EOF

chmod +x tests/commands/your-command/test_your_command.sh

# Run tests
./run_tests.sh
```

### 3. Adding Manual Test Fixtures

```bash
# Create fixture directory
mkdir -p tests/skills/your-skill/fixtures/scenario-name

# Create setup script
cat > tests/skills/your-skill/fixtures/scenario-name/setup.sh << 'EOF'
#!/bin/bash
# Setup for scenario-name test fixture

set -e

# Setup code here
# ...

echo "✓ Fixture created. Test with Claude Code."
EOF

chmod +x tests/skills/your-skill/fixtures/scenario-name/setup.sh
```

## Test Coverage

### release-tag Skill

**Test Suites:** 1 comprehensive suite with 16 test cases

**Integration Tests (5):**
- Basic minor version bump detection
- Breaking change (major bump) detection
- First release scenario
- Patch-only bump detection
- Dirty working tree validation

**Format Validation Tests (8):**
- Valid format with user-visible changes
- Detection of commit prefixes in highlights
- Detection of emotional/subjective language
- Minimum bullet point requirement
- Internal maintenance format validation
- Signature line detection
- Upgrade notes handling
- Raw commit message detection

**Manual Test Fixtures (4):**
- `basic/` - Standard feature release
- `breaking-change/` - API breaking change
- `first-release/` - New project initialization
- `internal-maintenance/` - Internal changes only

## Test Runner Features

The `run_tests.sh` script provides:

✅ **Auto-discovery**: Automatically finds all `test_*.sh` files
✅ **Hierarchical organization**: Separates skills and commands
✅ **Clean output**: Colored, formatted test results
✅ **Suite-level reporting**: Shows pass/fail per test suite
✅ **Summary statistics**: Overall pass/fail counts
✅ **Exit codes**: Non-zero on failure for CI/CD

## Validation Checklist

For each test, verify:
- [ ] Correct behavior for the scenario
- [ ] Error handling works properly
- [ ] Output format is correct
- [ ] Edge cases are handled
- [ ] No false positives/negatives

## CI/CD Integration

Tests run automatically via GitHub Actions on:
- Pull requests
- Pushes to main/master/develop
- Manual workflow dispatch

See `.github/workflows/test.yml` for configuration.

## Best Practices

### Writing Tests

1. **Atomic tests**: Each test should verify one thing
2. **Clear naming**: Use descriptive test names
3. **Cleanup**: Always clean up temporary files
4. **Isolation**: Tests should not depend on each other
5. **Documentation**: Comment complex test logic

### Test Structure

```bash
#!/bin/bash
set -e

# Setup
setup() {
    # Prepare test environment
}

# Test cases
test_something() {
    # Arrange
    # Act
    # Assert
}

# Cleanup
cleanup() {
    # Remove temporary files
}

trap cleanup EXIT

# Main
main() {
    setup
    test_something
    # More tests...
}

main
```

### Fixture Guidelines

- Keep fixtures minimal and focused
- Document expected behavior
- Provide setup scripts for reproducibility
- Clean up after tests

## Troubleshooting

### Tests not discovered

Ensure test files:
- Are named `test_*.sh`
- Are in `skills/*/` or `commands/*/` directories
- Are executable (`chmod +x`)

### Fixtures don't work

Check:
- Setup script is executable
- Git is configured (user.name, user.email)
- Required tools are installed

### CI/CD failures

Review:
- GitHub Actions logs
- Test output in CI
- Environment differences

## Documentation

- [SUMMARY.md](SUMMARY.md) - Current test status and coverage
- [VALIDATION.md](../VALIDATION.md) - Quick validation guide
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Contribution guidelines

## Future Improvements

- [ ] Parallel test execution
- [ ] Test coverage reporting
- [ ] Performance benchmarks
- [ ] E2E tests with actual Claude Code invocation
- [ ] Snapshot testing for output validation
