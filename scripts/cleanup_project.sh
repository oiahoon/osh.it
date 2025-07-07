#!/usr/bin/env bash
# OSH.IT Project Cleanup Script
# Removes development and testing files that are not needed in production

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

log_info "OSH.IT Project Cleanup"
echo

# Files and directories to potentially remove
CLEANUP_CANDIDATES=(
    # Test and demo scripts
    "scripts/test_lazy_loading.sh"
    "scripts/progress_demo.sh" 
    "scripts/lazy_loading_demo.sh"
    
    # Development tools (keep for now, but list for review)
    # "tools/requirement-discussion"
    # "tools/pr-management"
    
    # Documentation build files (keep for website maintenance)
    # "docs/optimize-assets.js"
    # "docs/generate-content.js"
    # "docs/enhanced-content-generator.js"
    # "docs/package.json"
    
    # Temporary or backup files
    "*.backup"
    "*.tmp"
    ".DS_Store"
)

# Optional cleanup (commented out by default)
OPTIONAL_CLEANUP=(
    "tools/requirement-discussion"
    "tools/pr-management"
    "docs/optimize-assets.js"
    "docs/generate-content.js"
    "docs/enhanced-content-generator.js"
    "docs/package.json"
)

echo "🔍 Scanning for cleanup candidates..."
echo

# Check what exists
FOUND_FILES=()
for item in "${CLEANUP_CANDIDATES[@]}"; do
    if [[ -e "$item" ]]; then
        FOUND_FILES+=("$item")
        if [[ -d "$item" ]]; then
            log_warning "Directory: $item"
        else
            log_warning "File: $item"
        fi
    fi
done

if [[ ${#FOUND_FILES[@]} -eq 0 ]]; then
    log_success "No cleanup candidates found!"
    exit 0
fi

echo
log_info "Found ${#FOUND_FILES[@]} items that could be cleaned up"
echo

# Ask for confirmation
read -p "Do you want to remove these items? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Cleanup cancelled"
    exit 0
fi

# Perform cleanup
echo
log_info "Performing cleanup..."
REMOVED_COUNT=0

for item in "${FOUND_FILES[@]}"; do
    if [[ -e "$item" ]]; then
        if rm -rf "$item" 2>/dev/null; then
            log_success "Removed: $item"
            ((REMOVED_COUNT++))
        else
            log_error "Failed to remove: $item"
        fi
    fi
done

echo
log_success "Cleanup completed! Removed $REMOVED_COUNT items"

# Show optional cleanup suggestions
if [[ ${#OPTIONAL_CLEANUP[@]} -gt 0 ]]; then
    echo
    log_info "Optional cleanup (not performed automatically):"
    for item in "${OPTIONAL_CLEANUP[@]}"; do
        if [[ -e "$item" ]]; then
            echo "  - $item"
        fi
    done
    echo
    log_info "These files are kept for development/maintenance purposes"
    log_info "Remove manually if not needed"
fi

echo
log_success "Project cleanup completed! 🎉"
