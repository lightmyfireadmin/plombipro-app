#!/bin/bash

# PlombiPro Firebase Distribution Script
# Builds and distributes APK to Firebase App Distribution

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  PlombiPro Firebase Distribution${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Configuration
FIREBASE_APP_ID="1:268663350911:android:d84cfcc42f6b4b9a66014a"
TESTER_GROUP="internal-testers"
VERSION=${1:-"0.5.0"}
RELEASE_NOTES=${2:-"PlombiPro v${VERSION} - Test build"}

# Build the APK
echo -e "${YELLOW}Step 1: Building release APK...${NC}"
./build-release.sh

if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed. Aborting distribution.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Step 2: Distributing to Firebase...${NC}"

firebase appdistribution:distribute \
  build/app/outputs/flutter-apk/app-release.apk \
  --app "$FIREBASE_APP_ID" \
  --groups "$TESTER_GROUP" \
  --release-notes "$RELEASE_NOTES"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Distribution Successful! ✓${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Testers in group '$TESTER_GROUP' will receive an email"
    echo "with download instructions."
else
    echo ""
    echo -e "${RED}Distribution failed!${NC}"
    exit 1
fi
