#!/bin/bash

# Comprehensive test suite for release-tag skill
# Combines integration tests and format validation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES_DIR="$TEST_DIR/fixtures"
TEMP_DIR="$TEST_DIR/.temp"

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Cleanup function
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

log_section() {
    echo -e "${BLUE}[====]${NC} $1"
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [ "$expected" = "$actual" ]; then
        log_info "✓ $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "✗ $message"
        log_error "  Expected: $expected"
        log_error "  Actual: $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# ============================================================================
# PART 1: Integration Tests - Git Repository Scenarios
# ============================================================================

setup_basic_repo() {
    local repo_dir="$1"
    mkdir -p "$repo_dir"
    cd "$repo_dir"

    git init
    git config user.name "Test User"
    git config user.email "test@example.com"

    echo "# Test Project" > README.md
    git add README.md
    git commit -m "chore: initial commit"

    git tag -a v1.2.0 -m "Release v1.2.0"

    echo "feature1" > feature1.txt
    git add feature1.txt
    git commit -m "feat: add feature 1"

    echo "feature2" > feature2.txt
    git add feature2.txt
    git commit -m "feat: add feature 2"

    echo "fix" > fix.txt
    git add fix.txt
    git commit -m "fix: fix a bug"

    log_info "Created basic test repo at $repo_dir"
}

setup_breaking_change_repo() {
    local repo_dir="$1"
    mkdir -p "$repo_dir"
    cd "$repo_dir"

    git init
    git config user.name "Test User"
    git config user.email "test@example.com"

    echo "# Test Project" > README.md
    git add README.md
    git commit -m "chore: initial commit"

    git tag -a v1.5.0 -m "Release v1.5.0"

    echo "breaking" > breaking.txt
    git add breaking.txt
    git commit -m "feat!: redesign API

BREAKING CHANGE: The API has been completely redesigned"

    log_info "Created breaking change test repo at $repo_dir"
}

setup_first_release_repo() {
    local repo_dir="$1"
    mkdir -p "$repo_dir"
    cd "$repo_dir"

    git init
    git config user.name "Test User"
    git config user.email "test@example.com"

    echo "# New Project" > README.md
    git add README.md
    git commit -m "feat: initial implementation"

    echo "feature" > feature.txt
    git add feature.txt
    git commit -m "feat: add first feature"

    log_info "Created first release test repo at $repo_dir"
}

setup_patch_only_repo() {
    local repo_dir="$1"
    mkdir -p "$repo_dir"
    cd "$repo_dir"

    git init
    git config user.name "Test User"
    git config user.email "test@example.com"

    echo "# Test Project" > README.md
    git add README.md
    git commit -m "chore: initial commit"

    git tag -a v1.2.3 -m "Release v1.2.3"

    echo "fix1" > fix1.txt
    git add fix1.txt
    git commit -m "fix: fix bug 1"

    echo "fix2" > fix2.txt
    git add fix2.txt
    git commit -m "fix: fix bug 2"

    echo "docs" > CHANGELOG.md
    git add CHANGELOG.md
    git commit -m "docs: update changelog"

    log_info "Created patch-only test repo at $repo_dir"
}

test_basic_minor_bump() {
    log_test "Integration Test 1: Basic Minor Bump"

    local test_repo="$TEMP_DIR/basic"
    setup_basic_repo "$test_repo"

    cd "$test_repo"
    local last_tag=$(git describe --tags --abbrev=0)
    assert_equals "v1.2.0" "$last_tag" "Last tag should be v1.2.0"

    local commit_count=$(git log v1.2.0..HEAD --oneline | wc -l | tr -d ' ')
    assert_equals "3" "$commit_count" "Should have 3 commits after v1.2.0"

    local feat_count=$(git log v1.2.0..HEAD --oneline | grep -c "^[a-f0-9]* feat:" || true)
    [ "$feat_count" -ge 1 ] && log_info "✓ Found feat commits (expected MINOR bump)"
}

test_breaking_change_major_bump() {
    log_test "Integration Test 2: Breaking Change (MAJOR)"

    local test_repo="$TEMP_DIR/breaking"
    setup_breaking_change_repo "$test_repo"

    cd "$test_repo"
    local last_tag=$(git describe --tags --abbrev=0)
    assert_equals "v1.5.0" "$last_tag" "Last tag should be v1.5.0"

    if git log v1.5.0..HEAD --format=%B | grep -q "BREAKING CHANGE"; then
        log_info "✓ Found BREAKING CHANGE (expected MAJOR bump)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_error "✗ BREAKING CHANGE not found"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_RUN=$((TESTS_RUN + 1))
}

test_first_release() {
    log_test "Integration Test 3: First Release"

    local test_repo="$TEMP_DIR/first"
    setup_first_release_repo "$test_repo"

    cd "$test_repo"
    local tag_count=$(git tag | wc -l | tr -d ' ')
    assert_equals "0" "$tag_count" "Should have no tags"

    local commit_count=$(git log --oneline | wc -l | tr -d ' ')
    [ "$commit_count" -ge 1 ] && log_info "✓ Has commits (ready for first release)"
}

test_patch_only_bump() {
    log_test "Integration Test 4: Patch Only Bump"

    local test_repo="$TEMP_DIR/patch"
    setup_patch_only_repo "$test_repo"

    cd "$test_repo"
    local last_tag=$(git describe --tags --abbrev=0)
    assert_equals "v1.2.3" "$last_tag" "Last tag should be v1.2.3"

    local feat_count=$(git log v1.2.3..HEAD --oneline | grep -c "feat" || true)
    local breaking_count=$(git log v1.2.3..HEAD --format=%B | grep -c "BREAKING CHANGE" || true)

    if [ "$feat_count" -eq 0 ] && [ "$breaking_count" -eq 0 ]; then
        log_info "✓ No feat or breaking changes (expected PATCH bump)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_error "✗ Found feat or breaking changes"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_RUN=$((TESTS_RUN + 1))
}

test_dirty_working_tree() {
    log_test "Integration Test 5: Dirty Working Tree Detection"

    local test_repo="$TEMP_DIR/dirty"
    setup_basic_repo "$test_repo"

    cd "$test_repo"
    echo "uncommitted" > uncommitted.txt
    git add uncommitted.txt

    if ! git diff-index --quiet HEAD --; then
        log_info "✓ Working tree is dirty (should prevent tag creation)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        log_error "✗ Working tree appears clean"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    TESTS_RUN=$((TESTS_RUN + 1))
}

# ============================================================================
# PART 2: Format Validation Tests - Release Notes Format
# ============================================================================

validate_format() {
    local notes="$1"
    local test_name="$2"
    local should_pass="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    local errors=()

    # Check 1: Must have exact section headings
    if ! echo "$notes" | grep -q "^## Overview$"; then
        errors+=("Missing '## Overview' heading")
    fi

    if ! echo "$notes" | grep -q "^## Highlights$"; then
        errors+=("Missing '## Highlights' heading")
    fi

    if ! echo "$notes" | grep -q "^## Upgrade / Behavior Notes$"; then
        errors+=("Missing '## Upgrade / Behavior Notes' heading")
    fi

    # Check 2: Overview must be 1-2 sentences (not just commit messages)
    local overview=$(echo "$notes" | sed -n '/^## Overview$/,/^## [^O]/p' | sed '1d;$d')
    if echo "$overview" | grep -qE "^(feat:|fix:|chore:|docs:|refactor:|test:|ci:)"; then
        errors+=("Overview contains raw commit message format")
    fi

    # Check 3: Highlights must have at least 2 bullets
    local highlights=$(echo "$notes" | sed -n '/^## Highlights$/,/^## [^H]/p' | sed '1d;$d')
    local bullet_count=$(echo "$highlights" | grep -c "^- " || true)
    if [ "$bullet_count" -lt 2 ]; then
        errors+=("Highlights must have at least 2 bullet points (found: $bullet_count)")
    fi

    # Check 4: Highlight bullets must NOT start with commit prefixes
    if echo "$highlights" | grep -qE "^- (feat:|fix:|chore:|docs:|refactor:|test:|ci:)"; then
        errors+=("Highlights contain commit message prefixes")
    fi

    # Check 5: No signature lines
    if echo "$notes" | grep -qiE "(Generated with|Co-Authored-By|🤖)"; then
        errors+=("Contains signature/generator lines")
    fi

    # Check 6: No emotional/subjective language
    if echo "$notes" | grep -qiE "(great|awesome|excellent|amazing|fantastic|huge|significant|impressive)"; then
        errors+=("Contains emotional/subjective language")
    fi

    # Evaluate result
    if [ ${#errors[@]} -eq 0 ]; then
        if [ "$should_pass" = "pass" ]; then
            log_info "✓ $test_name - Valid format"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            log_error "✗ $test_name - Should have failed but passed"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        if [ "$should_pass" = "fail" ]; then
            log_info "✓ $test_name - Correctly detected invalid format"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            log_error "✗ $test_name - Format validation failed:"
            for error in "${errors[@]}"; do
                log_error "  - $error"
            done
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    fi
}

test_valid_format() {
    log_test "Format Test 1: Valid Format"

    local notes='Release v1.3.0

## Overview
This release adds OAuth authentication support and fixes session handling issues.

## Highlights
- Users can now authenticate using Google and GitHub OAuth providers
- Session management improved to handle high-concurrency scenarios
- Authentication errors now display user-friendly messages

## Upgrade / Behavior Notes
- None.
'

    validate_format "$notes" "Valid format with user-visible changes" "pass"
}

test_invalid_commit_prefixes() {
    log_test "Format Test 2: Invalid Commit Prefixes"

    local notes='Release v1.3.0

## Overview
This release adds new features and bug fixes.

## Highlights
- feat: add OAuth support
- fix: handle edge case in session management

## Upgrade / Behavior Notes
- None.
'

    validate_format "$notes" "Invalid: commit prefixes in highlights" "fail"
}

test_invalid_emotional_language() {
    log_test "Format Test 3: Invalid Emotional Language"

    local notes='Release v1.3.0

## Overview
This amazing release brings awesome new features to the project.

## Highlights
- Great OAuth integration for seamless authentication
- Fantastic session management improvements

## Upgrade / Behavior Notes
- None.
'

    validate_format "$notes" "Invalid: emotional language" "fail"
}

test_invalid_insufficient_bullets() {
    log_test "Format Test 4: Insufficient Bullets"

    local notes='Release v1.3.0

## Overview
This release adds OAuth support.

## Highlights
- OAuth authentication added

## Upgrade / Behavior Notes
- None.
'

    validate_format "$notes" "Invalid: only 1 bullet point" "fail"
}

test_valid_internal_maintenance() {
    log_test "Format Test 5: Valid Internal Maintenance"

    local notes='Release v1.3.1

## Overview
No user-visible changes; internal maintenance only.

## Highlights
- Refactored authentication module for improved code maintainability
- Updated test suite to cover edge cases in session handling
- Removed deprecated internal APIs

## Upgrade / Behavior Notes
- None.
'

    validate_format "$notes" "Valid: internal maintenance format" "pass"
}

test_invalid_signature_lines() {
    log_test "Format Test 6: Invalid Signature Lines"

    local notes='Release v1.3.0

## Overview
This release adds OAuth support and fixes bugs.

## Highlights
- OAuth authentication for users
- Improved session handling

## Upgrade / Behavior Notes
- None.

🤖 Generated with Claude Code
'

    validate_format "$notes" "Invalid: contains signature line" "fail"
}

test_valid_with_upgrade_notes() {
    log_test "Format Test 7: Valid With Upgrade Notes"

    local notes='Release v2.0.0

## Overview
This release redesigns the authentication API to use async/await patterns.

## Highlights
- Authentication API now uses async/await for improved error handling
- All authentication methods return Promises instead of callbacks
- New migration guide added to documentation

## Upgrade / Behavior Notes
- Breaking change: getData() is now async. Update all calls to use await getData().
- Old callback-based API has been removed.
'

    validate_format "$notes" "Valid: with upgrade notes" "pass"
}

test_invalid_raw_commit_overview() {
    log_test "Format Test 8: Invalid Raw Commits in Overview"

    local notes='Release v1.3.0

## Overview
feat: add OAuth support
fix: handle session edge case

## Highlights
- Users can authenticate with OAuth
- Session handling improved

## Upgrade / Behavior Notes
- None.
'

    validate_format "$notes" "Invalid: raw commit messages in overview" "fail"
}

# ============================================================================
# Main Test Runner
# ============================================================================

main() {
    log_info "Starting release-tag Skill Test Suite"
    log_info "================================================"

    mkdir -p "$TEMP_DIR"

    # Part 1: Integration Tests
    log_section "PART 1: Integration Tests (Git Repository Scenarios)"
    test_basic_minor_bump
    test_breaking_change_major_bump
    test_first_release
    test_patch_only_bump
    test_dirty_working_tree

    echo ""

    # Part 2: Format Validation Tests
    log_section "PART 2: Format Validation Tests (Release Notes Format)"
    test_valid_format
    test_invalid_commit_prefixes
    test_invalid_emotional_language
    test_invalid_insufficient_bullets
    test_valid_internal_maintenance
    test_invalid_signature_lines
    test_valid_with_upgrade_notes
    test_invalid_raw_commit_overview

    # Summary
    echo ""
    log_info "================================================"
    log_info "Test Summary"
    log_info "================================================"
    log_info "Tests run: $TESTS_RUN"
    log_info "Passed: $TESTS_PASSED"
    log_info "Failed: $TESTS_FAILED"

    if [ "$TESTS_FAILED" -eq 0 ]; then
        echo -e "${GREEN}✅ All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ Some tests failed!${NC}"
        return 1
    fi
}

# Run tests
main
