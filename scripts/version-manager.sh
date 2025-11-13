#!/bin/bash

################################################################################
# PlombiPro Version Manager
# Purpose: Manage and increment version numbers in pubspec.yaml
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

PUBSPEC_FILE="pubspec.yaml"

# Function to get current version
get_current_version() {
    if [ ! -f "$PUBSPEC_FILE" ]; then
        echo -e "${RED}Error: pubspec.yaml not found${NC}" >&2
        exit 1
    fi

    local version_line=$(grep "^version:" "$PUBSPEC_FILE" | head -1)
    echo "$version_line" | awk '{print $2}'
}

# Function to parse version components
parse_version() {
    local version=$1
    # Split version into version_name+build_number
    local version_name=$(echo "$version" | cut -d'+' -f1)
    local build_number=$(echo "$version" | cut -d'+' -f2)

    # Split version_name into major.minor.patch
    local major=$(echo "$version_name" | cut -d'.' -f1)
    local minor=$(echo "$version_name" | cut -d'.' -f2)
    local patch=$(echo "$version_name" | cut -d'.' -f3)

    echo "$major $minor $patch $build_number"
}

# Function to increment patch version
increment_patch() {
    local current_version=$(get_current_version)
    read major minor patch build <<< $(parse_version "$current_version")

    patch=$((patch + 1))
    local new_version="${major}.${minor}.${patch}+$((build + 1))"

    echo "$new_version"
}

# Function to increment minor version
increment_minor() {
    local current_version=$(get_current_version)
    read major minor patch build <<< $(parse_version "$current_version")

    minor=$((minor + 1))
    patch=0
    local new_version="${major}.${minor}.${patch}+$((build + 1))"

    echo "$new_version"
}

# Function to increment major version
increment_major() {
    local current_version=$(get_current_version)
    read major minor patch build <<< $(parse_version "$current_version")

    major=$((major + 1))
    minor=0
    patch=0
    local new_version="${major}.${minor}.${patch}+$((build + 1))"

    echo "$new_version"
}

# Function to update version in pubspec.yaml
update_version() {
    local new_version=$1
    local current_version=$(get_current_version)

    # Update pubspec.yaml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/^version: .*/version: $new_version/" "$PUBSPEC_FILE"
    else
        # Linux
        sed -i "s/^version: .*/version: $new_version/" "$PUBSPEC_FILE"
    fi

    echo -e "${GREEN}✅ Version updated: ${current_version} → ${new_version}${NC}"
}

# Main script
show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Commands:
    get             Get current version
    patch           Increment patch version (0.7.0 → 0.7.1)
    minor           Increment minor version (0.7.0 → 0.8.0)
    major           Increment major version (0.7.0 → 1.0.0)
    set VERSION     Set specific version (e.g., 0.7.5+10)

Examples:
    $0 get                  # Show current version
    $0 patch                # Increment patch version
    $0 minor                # Increment minor version
    $0 set 0.8.0+15         # Set specific version

EOF
}

case "${1:-}" in
    get)
        echo $(get_current_version)
        ;;
    patch)
        new_version=$(increment_patch)
        update_version "$new_version"
        ;;
    minor)
        new_version=$(increment_minor)
        update_version "$new_version"
        ;;
    major)
        new_version=$(increment_major)
        update_version "$new_version"
        ;;
    set)
        if [ -z "${2:-}" ]; then
            echo -e "${RED}Error: Version number required${NC}" >&2
            show_usage
            exit 1
        fi
        update_version "$2"
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
