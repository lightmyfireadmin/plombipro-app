#!/bin/bash

# PlombiPro Release Build Script
# This script builds the release APK with proper environment variables

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  PlombiPro Release Build${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if .env file exists
if [ ! -f "lib/.env" ]; then
    echo -e "${RED}Error: lib/.env file not found!${NC}"
    echo ""
    echo "Please create lib/.env with your credentials:"
    echo "  cp lib/.env.example lib/.env"
    echo "  # Then edit lib/.env with your actual values"
    echo ""
    exit 1
fi

# Source the .env file
echo -e "${YELLOW}Loading environment variables...${NC}"
export $(cat lib/.env | grep -v '^#' | xargs)

# Verify required variables
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo -e "${RED}Error: SUPABASE_URL or SUPABASE_ANON_KEY not set in lib/.env${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Environment variables loaded${NC}"
echo ""

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "${YELLOW}Getting dependencies...${NC}"
flutter pub get

# Build release APK
echo -e "${YELLOW}Building release APK...${NC}"
flutter build apk --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=SENTRY_DSN="${SENTRY_DSN:-}"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Build Successful! ✓${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "APK location:"
    echo "  build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    ls -lh build/app/outputs/flutter-apk/app-release.apk
else
    echo ""
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi
