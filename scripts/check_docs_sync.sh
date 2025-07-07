#!/usr/bin/env bash
# OSH.IT Documentation Sync Checker
# Ensures README.md and website are in sync

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ️  $*${NC}"; }
log_success() { echo -e "${GREEN}✅ $*${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $*${NC}"; }
log_error() { echo -e "${RED}❌ $*${NC}"; }

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

log_info "OSH.IT Documentation Sync Check"
echo

# Check version consistency
VERSION_FILE="VERSION"
README_FILE="README.md"
INDEX_FILE="docs/index.html"

if [[ ! -f "$VERSION_FILE" ]]; then
    log_error "VERSION file not found"
    exit 1
fi

CURRENT_VERSION=$(cat "$VERSION_FILE" | tr -d '\n\r')
log_info "Current version: $CURRENT_VERSION"

# Check README.md version
if grep -q "v$CURRENT_VERSION (Latest)" "$README_FILE"; then
    log_success "README.md version is up to date"
else
    log_warning "README.md version may be outdated"
    echo "  Expected: v$CURRENT_VERSION (Latest)"
    echo "  Found: $(grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+ (Latest)' "$README_FILE" || echo 'Not found')"
fi

# Check index.html version
if grep -q "\"version\": \"$CURRENT_VERSION\"" "$INDEX_FILE"; then
    log_success "Website structured data version is up to date"
else
    log_warning "Website structured data version may be outdated"
    echo "  Expected: \"version\": \"$CURRENT_VERSION\""
    echo "  Found: $(grep -o '"version": "[^"]*"' "$INDEX_FILE" || echo 'Not found')"
fi

if grep -q "OSH.IT v$CURRENT_VERSION" "$INDEX_FILE"; then
    log_success "Website terminal title version is up to date"
else
    log_warning "Website terminal title version may be outdated"
    echo "  Expected: OSH.IT v$CURRENT_VERSION"
    echo "  Found: $(grep -o 'OSH.IT v[0-9]\+\.[0-9]\+\.[0-9]\+' "$INDEX_FILE" || echo 'Not found')"
fi

echo

# Check for common inconsistencies
log_info "Checking for common inconsistencies..."

# Check if CHANGELOG.md mentions unreleased features that should be in a version
if grep -q "## \[Unreleased\]" "CHANGELOG.md"; then
    UNRELEASED_CONTENT=$(sed -n '/## \[Unreleased\]/,/## \[/p' "CHANGELOG.md" | head -n -1 | tail -n +2)
    if [[ -n "$UNRELEASED_CONTENT" ]] && [[ "$UNRELEASED_CONTENT" != *"No changes"* ]]; then
        log_warning "CHANGELOG.md has unreleased content that might need to be versioned"
    fi
fi

# Check if all fix scripts are documented
SCRIPTS_DIR="scripts"
FIX_SCRIPTS=$(find "$SCRIPTS_DIR" -name "fix_*.sh" -type f | wc -l)
README_FIX_MENTIONS=$(grep -c "fix_.*\.sh" "$README_FILE" || echo 0)

if [[ $FIX_SCRIPTS -gt $README_FIX_MENTIONS ]]; then
    log_warning "Some fix scripts may not be documented in README.md"
    echo "  Fix scripts found: $FIX_SCRIPTS"
    echo "  README mentions: $README_FIX_MENTIONS"
fi

echo
log_success "Documentation sync check completed!"

# Suggestions
echo
log_info "💡 Suggestions:"
echo "  • Run this script before each release"
echo "  • Update VERSION file first, then sync other files"
echo "  • Use 'git grep' to find all version references"
echo "  • Consider automating version updates with a release script"
