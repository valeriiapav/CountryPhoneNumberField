#!/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

RE2_SRC="$ROOT_DIR/Native/ThirdParty/re2"
BUILD_DIR="$ROOT_DIR/Native/Build/re2"
INSTALL_DIR="$ROOT_DIR/Native/ThirdParty/re2-ios"

rm -rf "$BUILD_DIR" "$INSTALL_DIR"
mkdir -p "$BUILD_DIR" "$INSTALL_DIR"

build_re2() {
  local SDK_NAME="$1"
  local ARCHS="$2"
  local INSTALL_SUBDIR="$3"

cmake -S "$RE2_SRC" \
  -B "$BUILD_DIR/$INSTALL_SUBDIR" \
  -G Ninja \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_SYSROOT="$(xcrun --sdk "$SDK_NAME" --show-sdk-path)" \
  -DCMAKE_OSX_ARCHITECTURES="$ARCHS" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR/$INSTALL_SUBDIR" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DRE2_BUILD_TESTING=OFF \
  -DCMAKE_PREFIX_PATH="$ROOT_DIR/Native/ThirdParty/abseil-ios/$INSTALL_SUBDIR" \
  -Dabsl_DIR="$ROOT_DIR/Native/ThirdParty/abseil-ios/$INSTALL_SUBDIR/lib/cmake/absl" \
  -DCMAKE_CXX_STANDARD=17

  cmake --build "$BUILD_DIR/$INSTALL_SUBDIR"
  cmake --install "$BUILD_DIR/$INSTALL_SUBDIR"
}

build_re2 "iphoneos" "arm64" "iphoneos"
build_re2 "iphonesimulator" "arm64" "iphonesimulator"

echo "RE2 iOS build complete:"
echo "$INSTALL_DIR"
