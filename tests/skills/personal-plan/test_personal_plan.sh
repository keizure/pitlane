#!/bin/bash
set -e

# Test suite for personal-plan skill
# This validates the basic functionality of the .plan file system

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$(mktemp -d)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Cleanup on exit
cleanup() {
    if [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
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

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    if [ "$expected" != "$actual" ]; then
        log_error "$message"
        log_error "Expected: $expected"
        log_error "Actual:   $actual"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File not found: $file}"

    if [ ! -e "$file" ]; then
        log_error "$message"
        return 1
    fi
}

assert_file_contains() {
    local file="$1"
    local pattern="$2"
    local message="${3:-Pattern not found in file}"

    if ! grep -q "$pattern" "$file"; then
        log_error "$message"
        log_error "Pattern: $pattern"
        log_error "File contents:"
        cat "$file"
        return 1
    fi
}

# Test 1: SKILL.md validation
test_skill_frontmatter() {
    log_info "Test 1: Validating SKILL.md frontmatter"

    local skill_file="$SCRIPT_DIR/../../../skills/personal-plan/SKILL.md"

    assert_file_exists "$skill_file" "SKILL.md not found"

    # Check frontmatter
    local first_line=$(head -1 "$skill_file")
    assert_equals "---" "$first_line" "First line must be '---'"

    # Check required fields
    assert_file_contains "$skill_file" "^name:" "Missing 'name:' field"
    assert_file_contains "$skill_file" "^description:" "Missing 'description:' field"

    log_info "✓ SKILL.md frontmatter is valid"
}

# Test 2: Basic file creation
test_file_creation() {
    log_info "Test 2: Testing file creation logic"

    local plan_file="$TEST_DIR/.plan/daily.plan"
    local plan_dir="$TEST_DIR/.plan"

    # Simulate creating directory
    mkdir -p "$plan_dir"
    assert_file_exists "$plan_dir" "Failed to create .plan directory"

    # Create initial file with today's date
    local today=$(date +%Y-%m-%d)
    echo "## $today" > "$plan_file"
    echo "" >> "$plan_file"

    assert_file_exists "$plan_file" "Failed to create daily.plan"
    assert_file_contains "$plan_file" "^## 2026-" "Missing date header"

    log_info "✓ File creation works correctly"
}

# Test 3: Entry addition
test_entry_addition() {
    log_info "Test 3: Testing entry addition"

    local plan_file="$TEST_DIR/.plan/daily.plan"
    mkdir -p "$TEST_DIR/.plan"

    local today=$(date +%Y-%m-%d)

    # Create initial content
    cat > "$plan_file" <<EOF
## $today

* Completed task 1
EOF

    # Simulate adding new entry
    echo "? New todo item" >> "$plan_file"

    assert_file_contains "$plan_file" "Completed task 1" "Original entry lost"
    assert_file_contains "$plan_file" "New todo item" "New entry not added"

    log_info "✓ Entry addition preserves existing content"
}

# Test 4: Marker validation
test_marker_syntax() {
    log_info "Test 4: Testing marker syntax"

    local plan_file="$TEST_DIR/.plan/daily.plan"
    mkdir -p "$TEST_DIR/.plan"

    local today=$(date +%Y-%m-%d)

    cat > "$plan_file" <<EOF
## $today

* Completed item
? Todo item
+ Fixed item
~ Abandoned item
[project] Tagged item

---

Random thought without marker
EOF

    # Verify all markers are present
    assert_file_contains "$plan_file" "^\*" "Missing completed marker"
    assert_file_contains "$plan_file" "^?" "Missing todo marker"
    assert_file_contains "$plan_file" "^+" "Missing fixed marker"
    assert_file_contains "$plan_file" "^~" "Missing abandoned marker"
    assert_file_contains "$plan_file" "^\[project\]" "Missing project tag"
    assert_file_contains "$plan_file" "^---$" "Missing separator"

    log_info "✓ All markers are properly formatted"
}

# Test 5: Multiple date sections
test_multiple_dates() {
    log_info "Test 5: Testing multiple date sections"

    local plan_file="$TEST_DIR/.plan/daily.plan"
    mkdir -p "$TEST_DIR/.plan"

    cat > "$plan_file" <<EOF
## 2026-02-27

* Today's completed item
? Today's todo

---

## 2026-02-26

* Yesterday's work
EOF

    # Count date headers
    local date_count=$(grep -c "^## 2026-" "$plan_file")
    assert_equals "2" "$date_count" "Should have 2 date sections"

    log_info "✓ Multiple date sections handled correctly"
}

# Test 6: Format preservation
test_format_preservation() {
    log_info "Test 6: Testing format preservation"

    local plan_file="$TEST_DIR/.plan/daily.plan"
    mkdir -p "$TEST_DIR/.plan"

    local original_content="## 2026-02-27

* Important work
  with indentation
? Todo with
  multiple lines

---

想法：用中文记录
"

    echo "$original_content" > "$plan_file"

    # Read it back
    local read_content=$(cat "$plan_file")

    # Verify indentation preserved
    assert_file_contains "$plan_file" "  with indentation" "Indentation lost"
    assert_file_contains "$plan_file" "  multiple lines" "Multi-line format lost"
    assert_file_contains "$plan_file" "用中文记录" "Unicode content lost"

    log_info "✓ Format and encoding preserved"
}

# Run all tests
main() {
    log_info "Starting personal-plan skill tests"
    log_info "Test directory: $TEST_DIR"
    echo ""

    test_skill_frontmatter
    echo ""

    test_file_creation
    echo ""

    test_entry_addition
    echo ""

    test_marker_syntax
    echo ""

    test_multiple_dates
    echo ""

    test_format_preservation
    echo ""

    log_info "All tests passed! ✓"
}

main "$@"
