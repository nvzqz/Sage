#!/usr/bin/env bash
#
# A provision script for Vagrant to setup a Swift-ready development environment.
# Author: Nikolai Vazquez (https://github.com/nvzqz)
# Platform: Ubuntu 14.04  (ubuntu/trusty64)

set -e

# Variables
SWIFT_SNAPSHOT="swift-2.2.1-RELEASE"
SWIFT_SNAPSHOT_TAR="$SWIFT_SNAPSHOT-ubuntu14.04.tar.gz"
SWIFT_SNAPSHOT_URL="https://swift.org/builds/swift-2.2.1-release/ubuntu1404/$SWIFT_SNAPSHOT/$SWIFT_SNAPSHOT_TAR"
SWIFT_SNAPSHOT_DIR="swift"
SWIFT_TAR_FILE="swift_snapshot.tar.gz"

# Update package list
echo "Updating package list..."
apt-get update

# Install packages
echo "Installing packages..."
apt-get install -y git clang libicu-dev

# Download the snapshot
echo "Downloading Swift snapshot from $SWIFT_SNAPSHOT_URL"
wget -q -O $SWIFT_TAR_FILE $SWIFT_SNAPSHOT_URL

# Extract the snapshot
echo "Extracting '$SWIFT_TAR_FILE' to '$SWIFT_SNAPSHOT_DIR'..."
mkdir -p $SWIFT_SNAPSHOT_DIR && tar xzf $SWIFT_TAR_FILE -C $SWIFT_SNAPSHOT_DIR --strip-components=1

# Set directory permissions
echo "Setting permissions for '$SWIFT_SNAPSHOT_DIR'"
chown -R vagrant $SWIFT_SNAPSHOT_DIR

# Export swift to $PATH
echo "Adding '$SWIFT_SNAPSHOT_DIR' directory to \$PATH..."
echo "export PATH=/home/vagrant/$SWIFT_SNAPSHOT_DIR/usr/bin:$PATH" >> .profile

# Remove swift snapshot archive
echo "Cleaning up..."
rm $SWIFT_TAR_FILE

# Finished
echo "Successfully installed Swift!"
