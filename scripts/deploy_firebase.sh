#!/bin/bash
# This script deploys the Flutter web application to Firebase Hosting.

set -e

# Build the Flutter web application
./scripts/build_app.sh

echo "Deploying to Firebase Hosting..."
firebase deploy --only hosting
echo "Deployment to Firebase Hosting complete."
