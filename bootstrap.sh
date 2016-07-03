#!/usr/bin/env bash
#
# A provision script for Vagrant to setup a Swift-ready development environment.
# Author: Nikolai Vazquez (https://github.com/nvzqz)
# Platform: Ubuntu 14.04  (ubuntu/trusty64)

set -e

SWIFT_DIR="swift-3.0-PREVIEW-1-ubuntu14.04"
SWIFT_TAR="$SWIFT_DIR.tar.gz"
SWIFT_URL="https://swift.org/builds/swift-3.0-preview-1/ubuntu1404/swift-3.0-PREVIEW-1/$SWIFT_TAR"

apt-get update
apt-get install -y git clang libicu-dev

curl -O $SWIFT_URL
tar zxf $SWIFT_TAR
echo "export PATH=/home/vagrant/$SWIFT_DIR/usr/bin:$PATH" >> .profile
chown -R vagrant $SWIFT_DIR
rm $SWIFT_TAR
