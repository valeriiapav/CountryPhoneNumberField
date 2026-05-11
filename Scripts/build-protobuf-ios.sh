#!/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

PROTOBUF_SRC="$ROOT_DIR/Native/ThirdParty/protobuf"
ABSEIL_IOS="$ROOT_DIR/Native/ThirdParty/abseil-ios"

BUILD_DIR="$ROOT_DIR/Native/Build/protobuf"
INSTALL_DIR="$ROOT_DIR/Native/ThirdParty/protobuf-ios"

rm -rf "$BUILD_DIR" "$INSTALL_DIR"
mkdir -p "$BUILD_DIR" "$INSTALL_DIR"

build_protobuf() {
  local SDK_NAME="$1"
  local ARCHS="$2"
  local INSTALL_SUBDIR="$3"

  cmake -S "$PROTOBUF_SRC" \
    -B "$BUILD_DIR/$INSTALL_SUBDIR" \
    -G Ninja \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT="$(xcrun --sdk $SDK_NAME --show-sdk-path)" \
    -DCMAKE_OSX_ARCHITECTURES="$ARCHS" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR/$INSTALL_SUBDIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -Dprotobuf_BUILD_TESTS=OFF \
    -Dprotobuf_BUILD_SHARED_LIBS=OFF \
    -Dprotobuf_ABSL_PROVIDER=package \
    -DCMAKE_PREFIX_PATH="$ABSEIL_IOS/$INSTALL_SUBDIR" \
    -DCMAKE_CXX_STANDARD=17

  cmake --build "$BUILD_DIR/$INSTALL_SUBDIR"
  cmake --install "$BUILD_DIR/$INSTALL_SUBDIR"
}

build_protobuf "iphoneos" "arm64" "iphoneos"
build_protobuf "iphonesimulator" "arm64" "iphonesimulator"

echo "protobuf iOS build complete:"
echo "$INSTALL_DIR"