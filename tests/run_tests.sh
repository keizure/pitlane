#!/bin/bash

# Main test runner - Auto-discovers and runs all tests
# Supports hierarchical test organization by skills and commands

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Counters
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Pitlane Test Suite Runner         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Function to run a test suite
run_test_suite() {
    local test_script="$1"
    local suite_name="$2"

    TOTAL_SUITES=$((TOTAL_SUITES + 1))

    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Running: $suite_name${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if bash "$test_script"; then
        PASSED_SUITES=$((PASSED_SUITES + 1))
        echo ""
        echo -e "${GREEN}✅ $suite_name: PASSED${NC}"
    else
        FAILED_SUITES=$((FAILED_SUITES + 1))
        echo ""
        echo -e "${RED}❌ $suite_name: FAILED${NC}"
    fi

    echo ""
}

# Auto-discover and run skill tests
if [ -d "$SCRIPT_DIR/skills" ]; then
    for skill_dir in "$SCRIPT_DIR/skills"/*; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")

            # Look for test script in skill directory
            for test_file in "$skill_dir"/test_*.sh; do
                if [ -f "$test_file" ]; then
                    run_test_suite "$test_file" "Skill: $skill_name"
                fi
            done
        fi
    done
fi

# Auto-discover and run command tests
if [ -d "$SCRIPT_DIR/commands" ]; then
    for command_dir in "$SCRIPT_DIR/commands"/*; do
        if [ -d "$command_dir" ]; then
            command_name=$(basename "$command_dir")

            # Look for test script in command directory
            for test_file in "$command_dir"/test_*.sh; do
                if [ -f "$test_file" ]; then
                    run_test_suite "$test_file" "Command: $command_name"
                fi
            done
        fi
    done
fi

# Print summary
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Test Summary                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "Total test suites: ${BLUE}$TOTAL_SUITES${NC}"
echo -e "Passed: ${GREEN}$PASSED_SUITES${NC}"
echo -e "Failed: ${RED}$FAILED_SUITES${NC}"
echo ""

if [ "$FAILED_SUITES" -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   🎉 All test suites passed!         ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║   ⚠️  Some test suites failed!        ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    exit 1
fi
