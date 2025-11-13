#!/bin/bash

################################################################################
# PlombiPro Automated Build & Deploy Script
# Purpose: Automatically increment version, build, and deploy to Firebase
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
TESTER_EMAIL="editionsrevel@gmail.com"
APP_ID="1:268663350911:android:e3f69147ff7c8bcd66014a"
BUILD_TYPE="release"
VERSION_INCREMENT="patch"  # patch, minor, or major
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_MANAGER="$SCRIPT_DIR/scripts/version-manager.sh"
DEPLOY_SCRIPT="$SCRIPT_DIR/deploy-android.sh"

################################################################################
# Functions
################################################################################

print_header() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                   ║${NC}"
    echo -e "${CYAN}║   🚀 PlombiPro Auto Build & Deploy                               ║${NC}"
    echo -e "${CYAN}║                                                                   ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_step() {
    echo ""
    echo -e "${CYAN}▶ $1${NC}"
    echo ""
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -i, --increment TYPE    Version increment type: patch, minor, major (default: patch)
    -t, --type TYPE         Build type: debug or release (default: release)
    -e, --email EMAIL       Tester email (default: editionsrevel@gmail.com)
    --skip-version          Skip version increment (use current version)
    --skip-commit           Skip git commit after version update
    -h, --help              Show this help message

Examples:
    # Auto increment patch version (0.7.0 → 0.7.1), build and deploy
    $0

    # Increment minor version (0.7.0 → 0.8.0)
    $0 --increment minor

    # Debug build with custom email
    $0 --type debug --email test@example.com

    # Deploy current version without incrementing
    $0 --skip-version

EOF
}

check_prerequisites() {
    print_step "Checking prerequisites..."

    # Check if version manager exists
    if [ ! -f "$VERSION_MANAGER" ]; then
        print_error "Version manager script not found: $VERSION_MANAGER"
        exit 1
    fi

    # Check if deploy script exists
    if [ ! -f "$DEPLOY_SCRIPT" ]; then
        print_error "Deploy script not found: $DEPLOY_SCRIPT"
        exit 1
    fi

    # Make scripts executable
    chmod +x "$VERSION_MANAGER"
    chmod +x "$DEPLOY_SCRIPT"

    print_success "All prerequisites met"
}

increment_version() {
    local increment_type=$1
    print_step "Incrementing version (${increment_type})..."

    local old_version=$("$VERSION_MANAGER" get)
    print_info "Current version: $old_version"

    "$VERSION_MANAGER" "$increment_type"

    local new_version=$("$VERSION_MANAGER" get)
    print_success "New version: $new_version"

    echo "$new_version"
}

commit_version_change() {
    local version=$1
    print_step "Committing version change to git..."

    # Check if there are changes to commit
    if git diff --quiet pubspec.yaml; then
        print_info "No version changes to commit"
        return
    fi

    git add pubspec.yaml

    git commit -m "chore: bump version to $version

🤖 Automated version increment for Firebase App Distribution deployment

Co-Authored-By: Claude <noreply@anthropic.com>"

    if [ $? -eq 0 ]; then
        print_success "Version change committed"
        print_info "Run 'git push' to push the version change to remote"
    else
        print_warning "Git commit failed (may already be committed)"
    fi
}

create_release_notes() {
    local version=$1
    local build_date=$(date "+%Y-%m-%d %H:%M")

    local notes_file=$(mktemp)

    cat > "$notes_file" << EOF
🚀 PlombiPro v${version}
📅 Build: ${build_date}

✨ Automated Release
This build was automatically generated from the main branch.

✅ What to test:
• App launches and authentication works
• Dashboard displays correctly
• Quote creation and editing
• Client management features
• PDF generation and exports
• Navigation and UI responsiveness

🐛 Found a bug?
Contact: ${TESTER_EMAIL}

🔧 Built with Flutter & Firebase
EOF

    echo "$notes_file"
}

deploy_build() {
    local build_type=$1
    local email=$2
    local version=$3

    print_step "Deploying to Firebase App Distribution..."

    # Create release notes
    local notes_file=$(create_release_notes "$version")

    # Run deployment script
    "$DEPLOY_SCRIPT" \
        --email "$email" \
        --app-id "$APP_ID" \
        --type "$build_type" \
        --notes "$notes_file" \
        --clean

    # Clean up temp file
    rm -f "$notes_file"
}

################################################################################
# Main Script
################################################################################

main() {
    print_header

    # Parse arguments
    SKIP_VERSION=false
    SKIP_COMMIT=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--increment)
                VERSION_INCREMENT="$2"
                shift 2
                ;;
            -t|--type)
                BUILD_TYPE="$2"
                shift 2
                ;;
            -e|--email)
                TESTER_EMAIL="$2"
                shift 2
                ;;
            --skip-version)
                SKIP_VERSION=true
                shift
                ;;
            --skip-commit)
                SKIP_COMMIT=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Validate increment type
    if [ "$VERSION_INCREMENT" != "patch" ] && [ "$VERSION_INCREMENT" != "minor" ] && [ "$VERSION_INCREMENT" != "major" ]; then
        print_error "Invalid increment type: $VERSION_INCREMENT"
        print_info "Valid types: patch, minor, major"
        exit 1
    fi

    # Validate build type
    if [ "$BUILD_TYPE" != "debug" ] && [ "$BUILD_TYPE" != "release" ]; then
        print_error "Build type must be 'debug' or 'release'"
        exit 1
    fi

    # Display configuration
    print_info "Configuration:"
    echo "  Tester Email: $TESTER_EMAIL"
    echo "  App ID: $APP_ID"
    echo "  Build Type: $BUILD_TYPE"
    echo "  Version Increment: $VERSION_INCREMENT"
    echo "  Skip Version: $SKIP_VERSION"
    echo "  Skip Commit: $SKIP_COMMIT"
    echo ""

    # Check prerequisites
    check_prerequisites

    # Increment version (unless skipped)
    if [ "$SKIP_VERSION" = false ]; then
        NEW_VERSION=$(increment_version "$VERSION_INCREMENT")

        # Commit version change (unless skipped)
        if [ "$SKIP_COMMIT" = false ]; then
            commit_version_change "$NEW_VERSION"
        fi
    else
        NEW_VERSION=$("$VERSION_MANAGER" get)
        print_info "Using current version: $NEW_VERSION"
    fi

    # Deploy
    deploy_build "$BUILD_TYPE" "$TESTER_EMAIL" "$NEW_VERSION"

    # Success summary
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}║   ✅ AUTO BUILD & DEPLOY COMPLETE!                               ║${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    print_success "Version: $NEW_VERSION"
    print_success "Build Type: $BUILD_TYPE"
    print_success "Deployed to: $TESTER_EMAIL"
    echo ""
    print_info "Next steps:"
    echo "  1. Push version change: git push"
    echo "  2. Check Firebase App Distribution console"
    echo "  3. Tester will receive email with download link"
    echo ""
}

# Run main function
main "$@"
