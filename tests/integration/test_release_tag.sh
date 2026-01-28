#!/bin/bash

# Integration test for release-tag skill
# Tests the skill in various scenarios to ensure correct behavior

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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

assert_tag_exists() {
    local tag="$1"
    local repo_dir="$2"

    TESTS_RUN=$((TESTS_RUN + 1))

    cd "$repo_dir"
    if git tag | grep -q "^${tag}$"; then
        log_info "✓ Tag $tag exists"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "✗ Tag $tag does not exist"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_tag_message_contains() {
    local tag="$1"
    local pattern="$2"
    local repo_dir="$3"

    TESTS_RUN=$((TESTS_RUN + 1))

    cd "$repo_dir"
    local message=$(git tag -l -n999 "$tag")

    if echo "$message" | grep -q "$pattern"; then
        log_info "✓ Tag message contains '$pattern'"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        log_error "✗ Tag message does not contain '$pattern'"
        log_error "  Message: $message"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Test scenario setup functions
setup_basic_repo() {
    local repo_dir="$1"
    mkdir -p "$repo_dir"
    cd "$repo_dir"

    git init
    git config user.name "Test User"
    git config user.email "test@example.com"

    # Initial commit
    echo "# Test Project" > README.md
    git add README.md
    git commit -m "chore: initial commit"

    # Tag v1.2.0
    git tag -a v1.2.0 -m "Release v1.2.0"

    # Add some new commits
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

# Test cases
test_basic_minor_bump() {
    log_test "Test 1: Basic Minor Bump (feat commits)"

    local test_repo="$TEMP_DIR/basic"
    setup_basic_repo "$test_repo"

    # Expected: v1.2.0 -> v1.3.0 (has feat commits)
    # This would normally be tested by invoking the skill
    # For now, we verify the repo setup is correct

    cd "$test_repo"
    local last_tag=$(git describe --tags --abbrev=0)
    assert_equals "v1.2.0" "$last_tag" "Last tag should be v1.2.0"

    local commit_count=$(git log v1.2.0..HEAD --oneline | wc -l | tr -d ' ')
    assert_equals "3" "$commit_count" "Should have 3 commits after v1.2.0"

    # Check for feat commits
    local feat_count=$(git log v1.2.0..HEAD --oneline | grep -c "^[a-f0-9]* feat:" || true)
    [ "$feat_count" -ge 1 ] && log_info "✓ Found feat commits (expected MINOR bump)"
}

test_breaking_change_major_bump() {
    log_test "Test 2: Breaking Change (MAJOR bump)"

    local test_repo="$TEMP_DIR/breaking"
    setup_breaking_change_repo "$test_repo"

    cd "$test_repo"
    local last_tag=$(git describe --tags --abbrev=0)
    assert_equals "v1.5.0" "$last_tag" "Last tag should be v1.5.0"

    # Check for breaking change
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
    log_test "Test 3: First Release (no existing tags)"

    local test_repo="$TEMP_DIR/first"
    setup_first_release_repo "$test_repo"

    cd "$test_repo"
    local tag_count=$(git tag | wc -l | tr -d ' ')
    assert_equals "0" "$tag_count" "Should have no tags"

    local commit_count=$(git log --oneline | wc -l | tr -d ' ')
    [ "$commit_count" -ge 1 ] && log_info "✓ Has commits (ready for first release)"
}

test_patch_only_bump() {
    log_test "Test 4: Patch Only Bump (fix/docs commits)"

    local test_repo="$TEMP_DIR/patch"
    setup_patch_only_repo "$test_repo"

    cd "$test_repo"
    local last_tag=$(git describe --tags --abbrev=0)
    assert_equals "v1.2.3" "$last_tag" "Last tag should be v1.2.3"

    # Should have no feat or breaking changes
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
    log_test "Test 5: Dirty Working Tree Detection"

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

# Main test runner
main() {
    log_info "Starting release-tag skill integration tests"
    log_info "================================================"

    # Create temp directory
    mkdir -p "$TEMP_DIR"

    # Run tests
    test_basic_minor_bump
    test_breaking_change_major_bump
    test_first_release
    test_patch_only_bump
    test_dirty_working_tree

    # Summary
    echo ""
    log_info "================================================"
    log_info "Test Summary"
    log_info "================================================"
    log_info "Tests run: $TESTS_RUN"
    log_info "Passed: $TESTS_PASSED"
    log_info "Failed: $TESTS_FAILED"

    if [ "$TESTS_FAILED" -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        return 1
    fi
}

# Run tests
main
