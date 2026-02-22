#!/bin/bash
# Release script for alarm-notify
# Usage: ./scripts/release.sh <version> "<release message>"
# Example: ./scripts/release.sh 1.2.0 "Add new feature X"

set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PKGBUILD="$PROJECT_DIR/packaging/arch/PKGBUILD"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <version> \"<release message>\""
    echo ""
    echo "Arguments:"
    echo "  version         Version number (e.g., 1.2.0)"
    echo "  release message Short description for the tag"
    echo ""
    echo "Example:"
    echo "  $0 1.2.0 \"Add batch task loading feature\""
    exit 1
}

if [ -z "$1" ] || [ -z "$2" ]; then
    usage
fi

VERSION="$1"
MESSAGE="$2"

# Validate version format
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Invalid version format. Use X.Y.Z (e.g., 1.2.0)${NC}"
    exit 1
fi

echo -e "${YELLOW}=== Releasing alarm-notify v$VERSION ===${NC}"
echo ""

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo -e "${YELLOW}You have uncommitted changes. They will be included in this release.${NC}"
    git status --short
    echo ""
    read -p "Continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Update PKGBUILD version
echo -e "${GREEN}[1/5]${NC} Updating PKGBUILD version to $VERSION..."
sed -i "s/^pkgver=.*/pkgver=$VERSION/" "$PKGBUILD"

# Stage all changes
echo -e "${GREEN}[2/5]${NC} Staging changes..."
git add -A

# Commit
echo -e "${GREEN}[3/5]${NC} Creating commit..."
git commit -m "Release v$VERSION: $MESSAGE"

# Create annotated tag
echo -e "${GREEN}[4/5]${NC} Creating tag v$VERSION..."
git tag -a "v$VERSION" -m "$MESSAGE"

# Push
echo -e "${GREEN}[5/5]${NC} Pushing to origin..."
git push origin master --tags

echo ""
echo -e "${GREEN}=== Release v$VERSION complete! ===${NC}"
echo ""
echo -e "${YELLOW}Next steps for AUR:${NC}"
echo "  cd /path/to/aur-packages/alarm-notify"
echo "  # Copy the updated PKGBUILD"
echo "  cp $PKGBUILD ."
echo "  # Generate .SRCINFO"
echo "  makepkg --printsrcinfo > .SRCINFO"
echo "  # Commit and push to AUR"
echo "  git add PKGBUILD .SRCINFO"
echo "  git commit -m \"Update to v$VERSION\""
echo "  git push"
