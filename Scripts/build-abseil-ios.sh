#!/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ABSEIL_SRC="$ROOT_DIR/Native/ThirdParty/abseil-cpp"
BUILD_DIR="$ROOT_DIR/Native/Build/abseil"
INSTALL_DIR="$ROOT_DIR/Native/ThirdParty/abseil-ios"

rm -rf "$BUILD_DIR" "$INSTALL_DIR"
mkdir -p "$BUILD_DIR" "$INSTALL_DIR"

build_abseil() {
  local PLATFORM_NAME="$1"
  local SDK_NAME="$2"
  local ARCHS="$3"
  local INSTALL_SUBDIR="$4"

  cmake -S "$ABSEIL_SRC" \
    -B "$BUILD_DIR/$INSTALL_SUBDIR" \
    -G Ninja \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT="$(xcrun --sdk $SDK_NAME --show-sdk-path)" \
    -DCMAKE_OSX_ARCHITECTURES="$ARCHS" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR/$INSTALL_SUBDIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=OFF \
    -DABSL_ENABLE_INSTALL=ON \
    -DABSL_BUILD_TESTING=OFF \
    -DABSL_PROPAGATE_CXX_STD=ON \
    -DCMAKE_CXX_STANDARD=17

  cmake --build "$BUILD_DIR/$INSTALL_SUBDIR"
  cmake --install "$BUILD_DIR/$INSTALL_SUBDIR"
}

build_abseil "iOS" "iphoneos" "arm64" "iphoneos"
build_abseil "iOS Simulator" "iphonesimulator" "arm64" "iphonesimulator"

echo "Abseil iOS build complete:"
echo "$INSTALL_DIR"