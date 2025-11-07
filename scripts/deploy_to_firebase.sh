#!/bin/bash

# Firebase App Distribution Deployment Script
# This script builds and deploys the app to Firebase App Distribution for wireless testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Firebase configuration
FIREBASE_PROJECT="plombipro-devlpt"
ANDROID_APP_ID="1:268663350911:android:d84cfcc42f6b4b9a66014a"
IOS_APP_ID="1:268663350911:ios:93817ef0f50de33b66014a"
TESTER_GROUP="testers"

# Parse command line arguments
PLATFORM=""
RELEASE_NOTES=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --platform)
      PLATFORM="$2"
      shift 2
      ;;
    --notes)
      RELEASE_NOTES="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 --platform [android|ios|both] --notes \"Release notes\""
      echo ""
      echo "Options:"
      echo "  --platform    Platform to deploy (android, ios, or both)"
      echo "  --notes       Release notes for testers"
      echo "  --help        Show this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

# Validate platform
if [[ "$PLATFORM" != "android" && "$PLATFORM" != "ios" && "$PLATFORM" != "both" ]]; then
  echo -e "${RED}Error: --platform must be 'android', 'ios', or 'both'${NC}"
  exit 1
fi

# Set default release notes if not provided
if [[ -z "$RELEASE_NOTES" ]]; then
  RELEASE_NOTES="Test build from $(date '+%Y-%m-%d %H:%M:%S')"
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Firebase App Distribution Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Platform: ${GREEN}$PLATFORM${NC}"
echo -e "Release Notes: ${GREEN}$RELEASE_NOTES${NC}"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
  echo -e "${RED}Error: Firebase CLI is not installed${NC}"
  echo -e "Install it with: ${YELLOW}curl -sL https://firebase.tools | bash${NC}"
  exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
  echo -e "${RED}Error: Flutter is not installed${NC}"
  exit 1
fi

# Get dependencies
echo -e "${YELLOW}Installing Flutter dependencies...${NC}"
flutter pub get

# Deploy Android
if [[ "$PLATFORM" == "android" || "$PLATFORM" == "both" ]]; then
  echo ""
  echo -e "${BLUE}Building Android APK...${NC}"
  flutter build apk --release

  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✓ Android build successful${NC}"

    echo -e "${YELLOW}Deploying to Firebase App Distribution...${NC}"
    firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
      --app "$ANDROID_APP_ID" \
      --groups "$TESTER_GROUP" \
      --release-notes "$RELEASE_NOTES"

    if [[ $? -eq 0 ]]; then
      echo -e "${GREEN}✓ Android deployment successful${NC}"
      echo -e "${GREEN}Testers will receive an email notification${NC}"
    else
      echo -e "${RED}✗ Android deployment failed${NC}"
      exit 1
    fi
  else
    echo -e "${RED}✗ Android build failed${NC}"
    exit 1
  fi
fi

# Deploy iOS
if [[ "$PLATFORM" == "ios" || "$PLATFORM" == "both" ]]; then
  echo ""
  echo -e "${BLUE}Building iOS IPA...${NC}"
  flutter build ipa --release --export-options-plist=ios/ExportOptions.plist

  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✓ iOS build successful${NC}"

    echo -e "${YELLOW}Deploying to Firebase App Distribution...${NC}"
    firebase appdistribution:distribute build/ios/ipa/*.ipa \
      --app "$IOS_APP_ID" \
      --groups "$TESTER_GROUP" \
      --release-notes "$RELEASE_NOTES"

    if [[ $? -eq 0 ]]; then
      echo -e "${GREEN}✓ iOS deployment successful${NC}"
      echo -e "${GREEN}Testers will receive an email notification${NC}"
    else
      echo -e "${RED}✗ iOS deployment failed${NC}"
      exit 1
    fi
  else
    echo -e "${RED}✗ iOS build failed${NC}"
    echo -e "${YELLOW}Note: iOS builds require code signing configuration${NC}"
    exit 1
  fi
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "View your deployment at:"
echo -e "${YELLOW}https://console.firebase.google.com/project/$FIREBASE_PROJECT/appdistribution${NC}"
