#!/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

ABSEIL_SRC="$ROOT_DIR/Native/ThirdParty/abseil-cpp"
PROTOBUF_SRC="$ROOT_DIR/Native/ThirdParty/protobuf"

ABSEIL_BUILD="$ROOT_DIR/Native/Build/abseil-macos-build"
ABSEIL_INSTALL="$ROOT_DIR/Native/Build/abseil-macos"

PROTOBUF_BUILD="$ROOT_DIR/Native/Build/protobuf-macos-build"
PROTOBUF_INSTALL="$ROOT_DIR/Native/Build/protobuf-macos-install"
PROTOC_DIR="$ROOT_DIR/Native/Build/protobuf-macos"

# ── Build Abseil for macOS ─────────────────────────────────────────────────────
echo "Building Abseil for macOS..."
rm -rf "$ABSEIL_BUILD" "$ABSEIL_INSTALL"

cmake -S "$ABSEIL_SRC" \
  -B "$ABSEIL_BUILD" \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$ABSEIL_INSTALL" \
  -DABSL_BUILD_TESTING=OFF \
  -DCMAKE_CXX_STANDARD=17

cmake --build "$ABSEIL_BUILD"
cmake --install "$ABSEIL_BUILD"

# ── Build protoc for macOS ─────────────────────────────────────────────────────
echo "Building protoc for macOS..."
rm -rf "$PROTOBUF_BUILD" "$PROTOBUF_INSTALL"
mkdir -p "$PROTOC_DIR"

cmake -S "$PROTOBUF_SRC" \
  -B "$PROTOBUF_BUILD" \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -Dprotobuf_BUILD_TESTS=OFF \
  -Dprotobuf_BUILD_SHARED_LIBS=OFF \
  -Dprotobuf_ABSL_PROVIDER=package \
  -DCMAKE_PREFIX_PATH="$ABSEIL_INSTALL" \
  -Dabsl_DIR="$ABSEIL_INSTALL/lib/cmake/absl" \
  -DCMAKE_CXX_STANDARD=17

cmake --build "$PROTOBUF_BUILD"
cmake --install "$PROTOBUF_BUILD" --prefix "$PROTOBUF_INSTALL"

cp "$PROTOBUF_INSTALL/bin/protoc" "$PROTOC_DIR/protoc"

echo "✅ macOS protoc built at:"
echo "$PROTOC_DIR/protoc"
