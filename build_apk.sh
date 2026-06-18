#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

PUBSPEC_FILE="pubspec.yaml"

if [ ! -f "$PUBSPEC_FILE" ]; then
    echo "Error: pubspec.yaml not found in current directory."
    exit 1
fi

# Find the version line in pubspec.yaml (e.g. version: 1.0.0+1)
VERSION_LINE=$(grep "^version:" "$PUBSPEC_FILE")

if [ -z "$VERSION_LINE" ]; then
    echo "Error: version line not found in pubspec.yaml."
    exit 1
fi

# Extract the full version string (e.g. 1.0.0+1)
FULL_VERSION=$(echo "$VERSION_LINE" | cut -d' ' -f2)

# Split by '+' to get version name and build number
VERSION_NAME=$(echo "$FULL_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$FULL_VERSION" | cut -d'+' -f2)

if [ -z "$BUILD_NUMBER" ]; then
    BUILD_NUMBER=0
fi

# Increment build number
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))
NEW_FULL_VERSION="${VERSION_NAME}+${NEW_BUILD_NUMBER}"

echo "--------------------------------------------------"
echo "Current Version : $FULL_VERSION"
echo "New Version     : $NEW_FULL_VERSION"
echo "--------------------------------------------------"

# Replace the version in pubspec.yaml (using sed)
# On macOS, sed -i needs an empty extension argument
sed -i '' "s/^version:.*/version: ${NEW_FULL_VERSION}/" "$PUBSPEC_FILE"

echo "Updated $PUBSPEC_FILE successfully."
echo "Building release APK..."
echo "--------------------------------------------------"

flutter build apk --release

echo "--------------------------------------------------"
echo "Build complete! The APK has been built with version $NEW_FULL_VERSION"
echo "--------------------------------------------------"
