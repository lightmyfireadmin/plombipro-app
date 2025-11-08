#!/bin/bash
# This script deploys the Flutter web application to Cloudflare Pages.

set -e

# Branch to deploy to (e.g., 'main', 'development')
BRANCH="main"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --branch)
      BRANCH="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 --branch [branch_name]"
      echo ""
      echo "Options:"
      echo "  --branch      The branch to deploy to (defaults to 'main')"
      echo "  --help        Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Build the Flutter web application
./scripts/build_app.sh

echo "Deploying to Cloudflare Pages branch '$BRANCH'..."
wrangler pages deploy build/web --branch "$BRANCH"

echo "Deployment to Cloudflare Pages complete."
