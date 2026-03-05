#!/usr/bin/env bash
set -euo pipefail

# Release script for linny.vim
# Usage: ./scripts/release.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$PROJECT_ROOT/VERSION"
CHANGELOG_FILE="$PROJECT_ROOT/CHANGELOG.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

error() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}$1${NC}" >&2
}

info() {
    echo -e "${YELLOW}$1${NC}" >&2
}

# Check gh CLI availability
check_gh() {
    if ! command -v gh &> /dev/null; then
        error "gh CLI is not installed. Install it from https://cli.github.com/"
    fi

    if ! gh auth status &> /dev/null; then
        error "gh CLI is not authenticated. Run 'gh auth login' first."
    fi
}

# Read current version
get_current_version() {
    if [[ ! -f "$VERSION_FILE" ]]; then
        error "VERSION file not found at $VERSION_FILE"
    fi
    cat "$VERSION_FILE"
}

# Calculate new version based on bump type
calculate_new_version() {
    local current="$1"
    local bump_type="$2"

    IFS='.' read -r major minor patch <<< "$current"

    case "$bump_type" in
        major)
            echo "$((major + 1)).0.0"
            ;;
        minor)
            echo "$major.$((minor + 1)).0"
            ;;
        patch)
            echo "$major.$minor.$((patch + 1))"
            ;;
        *)
            error "Invalid bump type: $bump_type"
            ;;
    esac
}

# Interactive version bump selection
select_bump_type() {
    local current="$1"

    echo "" >&2
    info "Current version: $current"
    echo "" >&2
    echo "Select version bump type:" >&2
    echo "  1) major  - $(calculate_new_version "$current" major)" >&2
    echo "  2) minor  - $(calculate_new_version "$current" minor)" >&2
    echo "  3) patch  - $(calculate_new_version "$current" patch)" >&2
    echo "" >&2

    read -p "Enter choice [1-3]: " choice

    case "$choice" in
        1) echo "major" ;;
        2) echo "minor" ;;
        3) echo "patch" ;;
        *) error "Invalid choice: $choice" ;;
    esac
}

# Update VERSION file
update_version_file() {
    local new_version="$1"
    printf '%s' "$new_version" > "$VERSION_FILE"
    success "Updated VERSION to $new_version"
}

# Update CHANGELOG.md
update_changelog() {
    local new_version="$1"
    local date_str
    date_str=$(date "+%d %b %Y" | sed 's/^0//')

    # Replace "## Next version" with "## X.Y.Z - DD mon YYYY"
    sed -i "s/## Next version/## $new_version - $date_str/" "$CHANGELOG_FILE"

    # Add new "## Next version" section at the top (after the title)
    sed -i '/^# Changelog/a\\n## Next version\n' "$CHANGELOG_FILE"

    success "Updated CHANGELOG.md with version $new_version"
}

# Extract changelog section for release notes
extract_changelog_section() {
    local version="$1"

    # Extract content between "## X.Y.Z" and the next "##" header
    awk "/^## $version/{flag=1; next} /^## /{flag=0} flag" "$CHANGELOG_FILE" | sed '/^$/d'
}

# Create git tag
create_git_tag() {
    local version="$1"
    local tag="v$version"

    git add "$VERSION_FILE" "$CHANGELOG_FILE"
    git commit -m "Release $version"
    git tag -a "$tag" -m "Release $version"

    success "Created git tag $tag"
}

# Create GitHub release
create_github_release() {
    local version="$1"
    local tag="v$version"
    local release_notes

    release_notes=$(extract_changelog_section "$version")

    if [[ -z "$release_notes" ]]; then
        release_notes="Release $version"
    fi

    gh release create "$tag" --title "$tag" --notes "$release_notes"

    success "Created GitHub release $tag"
}

# Main release workflow
main() {
    echo "========================================"
    echo "  linny.vim Release Script"
    echo "========================================"

    # Pre-flight checks
    check_gh

    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --staged --quiet; then
        error "Working directory has uncommitted changes. Commit or stash them first."
    fi

    # Get current version and select bump type
    current_version=$(get_current_version)
    bump_type=$(select_bump_type "$current_version")
    new_version=$(calculate_new_version "$current_version" "$bump_type")

    echo ""
    info "Will release: $current_version -> $new_version"
    read -p "Continue? [y/N]: " confirm

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi

    # Execute release steps
    echo ""
    info "Updating VERSION file..."
    update_version_file "$new_version"

    info "Updating CHANGELOG.md..."
    update_changelog "$new_version"

    info "Creating git tag..."
    create_git_tag "$new_version"

    info "Pushing to remote..."
    git push && git push --tags

    info "Creating GitHub release..."
    create_github_release "$new_version"

    echo ""
    success "========================================"
    success "  Release $new_version complete!"
    success "========================================"
}

main "$@"
