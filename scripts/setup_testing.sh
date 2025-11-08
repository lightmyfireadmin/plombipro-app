#!/bin/bash

# Testing Environment Setup Script
# This script sets up everything needed for wireless testing and automated deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  PlombiPro Testing Environment Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1"
        return 1
    fi
}

echo -e "${CYAN}Checking prerequisites...${NC}"
echo ""

# Check Flutter
if command_exists flutter; then
    FLUTTER_VERSION=$(flutter --version | head -n 1)
    echo -e "${GREEN}✓${NC} Flutter: $FLUTTER_VERSION"
else
    echo -e "${RED}✗${NC} Flutter not found"
    echo -e "${YELLOW}  Install from: https://docs.flutter.dev/get-started/install${NC}"
    exit 1
fi

# Check Dart
if command_exists dart; then
    DART_VERSION=$(dart --version 2>&1 | head -n 1)
    echo -e "${GREEN}✓${NC} Dart: $DART_VERSION"
fi

# Check Java
if command_exists java; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    echo -e "${GREEN}✓${NC} Java: $JAVA_VERSION"
else
    echo -e "${YELLOW}⚠${NC} Java not found (required for Android builds)"
fi

# Check Firebase CLI
if command_exists firebase; then
    FIREBASE_VERSION=$(firebase --version)
    echo -e "${GREEN}✓${NC} Firebase CLI: $FIREBASE_VERSION"
else
    echo -e "${YELLOW}⚠${NC} Firebase CLI not found"
    echo -e "${YELLOW}  Install? (y/n)${NC}"
    read -r install_firebase
    if [ "$install_firebase" = "y" ]; then
        echo -e "${CYAN}Installing Firebase CLI...${NC}"
        curl -sL https://firebase.tools | bash
        print_status "Firebase CLI installed"
    fi
fi

# Check Fastlane
if command_exists fastlane; then
    FASTLANE_VERSION=$(fastlane --version | head -n 1)
    echo -e "${GREEN}✓${NC} Fastlane: $FASTLANE_VERSION"
else
    echo -e "${YELLOW}⚠${NC} Fastlane not found (required for iOS/Android automation)"
    echo -e "${YELLOW}  Install? (y/n)${NC}"
    read -r install_fastlane
    if [ "$install_fastlane" = "y" ]; then
        echo -e "${CYAN}Installing Fastlane...${NC}"
        sudo gem install fastlane -NV
        print_status "Fastlane installed"
    fi
fi

# Check CocoaPods (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command_exists pod; then
        POD_VERSION=$(pod --version)
        echo -e "${GREEN}✓${NC} CocoaPods: $POD_VERSION"
    else
        echo -e "${YELLOW}⚠${NC} CocoaPods not found (required for iOS)"
        echo -e "${YELLOW}  Install? (y/n)${NC}"
        read -r install_cocoapods
        if [ "$install_cocoapods" = "y" ]; then
            echo -e "${CYAN}Installing CocoaPods...${NC}"
            sudo gem install cocoapods
            print_status "CocoaPods installed"
        fi
    fi
fi

# Check ADB
if command_exists adb; then
    echo -e "${GREEN}✓${NC} Android Debug Bridge (adb)"
else
    echo -e "${YELLOW}⚠${NC} ADB not found (required for Android wireless debugging)"
fi

echo ""
echo -e "${CYAN}Setting up project...${NC}"
echo ""

# Install Flutter dependencies
echo -e "${YELLOW}Installing Flutter dependencies...${NC}"
flutter pub get
print_status "Flutter dependencies installed"

# Setup iOS (macOS only)
if [[ "$OSTYPE" == "darwin"* ]] && [ -d "ios" ]; then
    echo -e "${YELLOW}Setting up iOS dependencies...${NC}"
    cd ios
    if [ -f "Podfile" ]; then
        pod repo update --silent
        pod install
        print_status "iOS dependencies installed"
    fi
    cd ..
fi

echo ""
echo -e "${CYAN}Configuring Firebase...${NC}"
echo ""

# Check if Firebase is logged in
if command_exists firebase; then
    echo -e "${YELLOW}Checking Firebase authentication...${NC}"
    if firebase projects:list >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Firebase authenticated"

        # Check if plombipro-devlpt exists
        if firebase projects:list | grep -q "plombipro-devlpt"; then
            echo -e "${GREEN}✓${NC} Firebase project found: plombipro-devlpt"
        else
            echo -e "${YELLOW}⚠${NC} Project 'plombipro-devlpt' not found"
        fi
    else
        echo -e "${YELLOW}Firebase login required${NC}"
        echo -e "${YELLOW}Login now? (y/n)${NC}"
        read -r login_firebase
        if [ "$login_firebase" = "y" ]; then
            firebase login
            print_status "Firebase authenticated"
        fi
    fi

    # Offer to add user as tester
    echo ""
    echo -e "${YELLOW}Add yourself as a tester? (y/n)${NC}"
    read -r add_tester
    if [ "$add_tester" = "y" ]; then
        echo -e "${YELLOW}Enter your email:${NC}"
        read -r tester_email

        # Create testers group if it doesn't exist
        firebase appdistribution:group:create testers --project plombipro-devlpt 2>/dev/null || true

        # Add tester
        firebase appdistribution:testers:add "$tester_email" --project plombipro-devlpt
        firebase appdistribution:group:add-testers testers "$tester_email" --project plombipro-devlpt

        print_status "Added $tester_email as tester"
    fi
fi

echo ""
echo -e "${CYAN}Running Flutter Doctor...${NC}"
echo ""
flutter doctor

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo ""
echo -e "1. ${YELLOW}Quick Start Testing:${NC}"
echo -e "   See: ${BLUE}QUICK_START_TESTING.md${NC}"
echo ""
echo -e "2. ${YELLOW}iOS Testing (Wireless):${NC}"
echo -e "   flutter run -d \"iPhone\""
echo ""
echo -e "3. ${YELLOW}Android Testing (Wireless):${NC}"
echo -e "   ./scripts/deploy_to_firebase.sh --platform android"
echo ""
echo -e "4. ${YELLOW}Deploy to Both Platforms:${NC}"
echo -e "   ./scripts/deploy_to_firebase.sh --platform both --notes \"Test build\""
echo ""
echo -e "5. ${YELLOW}Setup Automated CI/CD:${NC}"
echo -e "   See: ${BLUE}TESTING.md${NC} (GitHub Actions section)"
echo ""
echo -e "6. ${YELLOW}Configure Android Signing:${NC}"
echo -e "   See: ${BLUE}docs/ANDROID_SIGNING_SETUP.md${NC}"
echo ""
echo -e "${CYAN}Resources:${NC}"
echo -e "  • Quick Start: ${BLUE}QUICK_START_TESTING.md${NC}"
echo -e "  • Full Guide: ${BLUE}TESTING.md${NC}"
echo -e "  • Android Signing: ${BLUE}docs/ANDROID_SIGNING_SETUP.md${NC}"
echo -e "  • Firebase Console: ${BLUE}https://console.firebase.google.com/project/plombipro-devlpt${NC}"
echo ""
echo -e "${GREEN}Happy testing! 🚀${NC}"
