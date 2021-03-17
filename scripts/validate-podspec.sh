#!/bin/sh

set -e

# EXTRA_FLAGS="--include-podspecs='RxSwift.podspec'"

TARGET=$1
SWIFT_VERSION=5.0

case $TARGET in
"GDSwift"*)
    pod lib lint --verbose --no-clean --swift-version=$SWIFT_VERSION --allow-warnings GDSwift.podspec
    ;;
esac

# Not sure why this isn't working ¯\_(ツ)_/¯, will figure it out some other time
# pod lib lint --verbose --no-clean --swift-version=${SWIFT_VERSION} ${EXTRA_FLAGS} ${TARGET}.podspec