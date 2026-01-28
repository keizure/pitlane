#!/bin/bash

# Main test runner script
# Run all tests for the pitlane project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Running Pitlane Tests${NC}"
echo "======================================"
echo ""

# Run integration tests
echo -e "${YELLOW}Running integration tests...${NC}"
bash "$SCRIPT_DIR/integration/test_release_tag.sh"

echo ""
echo -e "${GREEN}All test suites completed!${NC}"
