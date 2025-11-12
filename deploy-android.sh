#!/bin/bash

################################################################################
# PlombiPro Android Deployment Script
# Date: 2025-11-12
# Purpose: Build and deploy Android APK to Firebase App Distribution
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
APP_ID="${FIREBASE_APP_ID:-1:268663350911:android:e3f69147ff7c8bcd66014a}"
BUILD_TYPE="debug"
RELEASE_NOTES_FILE=""

# Supabase credentials (read from project or environment)
SUPABASE_URL="${SUPABASE_URL:-https://itugqculhbghypclhyfb.supabase.co}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml0dWdxY3VsaGJnaHlwY2xoeWZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3MTAxODEsImV4cCI6MjA3ODI4NjE4MX0.eSNzgh3pMHaPYCkzJ8L1UcoqzMSgHTJvg4c9IOGv4eI}"

################################################################################
# Functions
################################################################################

print_header() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                   ║${NC}"
    echo -e "${CYAN}║   🚀 PlombiPro Android Deployment Script                         ║${NC}"
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
    -e, --email EMAIL           Tester email address (required)
    -a, --app-id APP_ID         Firebase app ID (default: from env or hardcoded)
    -t, --type TYPE             Build type: debug or release (default: debug)
    -n, --notes FILE            Path to release notes file (optional)
    -c, --clean                 Clean build before building (recommended)
    -h, --help                  Show this help message

Environment Variables:
    FIREBASE_APP_ID            Default Firebase app ID

Examples:
    # Simple deployment with email
    $0 --email test@example.com

    # With custom app ID
    $0 --email test@example.com --app-id 1:123456789:android:abcdef123456

    # Release build with notes
    $0 --email test@example.com --type release --notes release_notes.txt

    # Clean build
    $0 --email test@example.com --clean

EOF
}

check_prerequisites() {
    print_step "Checking prerequisites..."

    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    print_success "Flutter found: $(flutter --version | head -1)"

    # Check Firebase CLI
    if ! command -v firebase &> /dev/null; then
        print_error "Firebase CLI is not installed or not in PATH"
        print_info "Install with: npm install -g firebase-tools"
        exit 1
    fi
    print_success "Firebase CLI found: $(firebase --version)"

    # Check if in Flutter project
    if [ ! -f "pubspec.yaml" ]; then
        print_error "Not in a Flutter project directory (pubspec.yaml not found)"
        exit 1
    fi
    print_success "Flutter project detected"
}

generate_default_release_notes() {
    local version=$(grep "version:" pubspec.yaml | awk '{print $2}' | head -1)
    local build_date=$(date "+%Y-%m-%d %H:%M")

    cat << EOF
🚀 PlombiPro Build - v${version}
Build Date: ${build_date}

📱 This is an automated build from the deployment script.

✅ What to test:
- App launches successfully
- Dashboard displays data
- Quote creation wizard works
- Client creation wizard works
- Navigation flows correctly

🐛 Report Issues:
- Check logs for crashes
- Note any unexpected behavior
- Test all critical user flows
EOF
}

clean_build() {
    print_step "Cleaning previous build..."
    flutter clean
    print_success "Clean completed"
}

build_apk() {
    local build_type=$1
    print_step "Building Android APK (${build_type})..."

    print_info "Using Supabase URL: $SUPABASE_URL"

    if [ "$build_type" == "release" ]; then
        flutter build apk --release \
            --dart-define=SUPABASE_URL="$SUPABASE_URL" \
            --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
    else
        flutter build apk --debug \
            --dart-define=SUPABASE_URL="$SUPABASE_URL" \
            --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
    fi

    if [ $? -eq 0 ]; then
        print_success "APK built successfully"

        # Get APK path
        if [ "$build_type" == "release" ]; then
            APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
        else
            APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
        fi

        if [ -f "$APK_PATH" ]; then
            local apk_size=$(ls -lh "$APK_PATH" | awk '{print $5}')
            print_info "APK location: $APK_PATH"
            print_info "APK size: $apk_size"
        else
            print_error "APK file not found at expected location: $APK_PATH"
            exit 1
        fi
    else
        print_error "APK build failed"
        exit 1
    fi
}

deploy_to_firebase() {
    local app_id=$1
    local email=$2
    local notes=$3

    print_step "Deploying to Firebase App Distribution..."

    print_info "App ID: $app_id"
    print_info "Tester: $email"
    print_info "APK: $APK_PATH"

    # Prepare release notes
    local notes_arg=""
    if [ -n "$notes" ]; then
        if [ -f "$notes" ]; then
            notes_arg="--release-notes-file $notes"
            print_info "Using release notes from: $notes"
        else
            print_warning "Release notes file not found: $notes"
            print_info "Using default release notes"
            notes=$(mktemp)
            generate_default_release_notes > "$notes"
            notes_arg="--release-notes-file $notes"
        fi
    else
        print_info "Generating default release notes"
        notes=$(mktemp)
        generate_default_release_notes > "$notes"
        notes_arg="--release-notes-file $notes"
    fi

    # Deploy
    firebase appdistribution:distribute "$APK_PATH" \
        --app "$app_id" \
        --testers "$email" \
        $notes_arg

    if [ $? -eq 0 ]; then
        print_success "Successfully deployed to Firebase App Distribution"
        print_success "Invite sent to: $email"
        echo ""
        print_info "The tester will receive an email with download instructions"
    else
        print_error "Firebase deployment failed"
        exit 1
    fi
}

################################################################################
# Main Script
################################################################################

main() {
    print_header

    # Parse arguments
    TESTER_EMAIL=""
    DO_CLEAN=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--email)
                TESTER_EMAIL="$2"
                shift 2
                ;;
            -a|--app-id)
                APP_ID="$2"
                shift 2
                ;;
            -t|--type)
                BUILD_TYPE="$2"
                shift 2
                ;;
            -n|--notes)
                RELEASE_NOTES_FILE="$2"
                shift 2
                ;;
            -c|--clean)
                DO_CLEAN=true
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

    # Validate required parameters
    if [ -z "$TESTER_EMAIL" ]; then
        print_error "Tester email is required"
        echo ""
        show_usage
        exit 1
    fi

    if [ -z "$APP_ID" ]; then
        print_error "Firebase app ID is required"
        echo ""
        show_usage
        exit 1
    fi

    # Validate build type
    if [ "$BUILD_TYPE" != "debug" ] && [ "$BUILD_TYPE" != "release" ]; then
        print_error "Build type must be 'debug' or 'release'"
        exit 1
    fi

    # Start deployment
    print_info "Configuration:"
    echo "  App ID: $APP_ID"
    echo "  Tester: $TESTER_EMAIL"
    echo "  Build Type: $BUILD_TYPE"
    echo "  Clean Build: $DO_CLEAN"
    echo ""

    # Execute steps
    check_prerequisites

    if [ "$DO_CLEAN" = true ]; then
        clean_build
    fi

    build_apk "$BUILD_TYPE"
    deploy_to_firebase "$APP_ID" "$TESTER_EMAIL" "$RELEASE_NOTES_FILE"

    # Success summary
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}║   ✅ DEPLOYMENT SUCCESSFUL!                                       ║${NC}"
    echo -e "${GREEN}║                                                                   ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    print_success "APK deployed to Firebase App Distribution"
    print_success "Invite sent to: $TESTER_EMAIL"
    echo ""
    print_info "Next steps:"
    echo "  1. Tester will receive email from Firebase"
    echo "  2. Tester clicks download link in email"
    echo "  3. Tester installs APK on Android device"
    echo "  4. Tester tests and provides feedback"
    echo ""
}

# Run main function with all arguments
main "$@"
