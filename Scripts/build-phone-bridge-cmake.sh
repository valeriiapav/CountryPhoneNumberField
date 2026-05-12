#!/bin/bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

BRIDGE_SRC="$ROOT_DIR/Native/PhoneNumberBridge"
BUILD_DIR="$ROOT_DIR/Native/Build/PhoneNumberBridge"
OUTPUT_DIR="$ROOT_DIR/Binary"

PROTOC="$ROOT_DIR/Native/Build/protobuf-macos/protoc"

mkdir -p "$OUTPUT_DIR"

if [ ! -f "$PROTOC" ]; then
  echo "❌ Missing macOS protoc at:"
  echo "$PROTOC"
  echo "Build it first."
  exit 1
fi

echo "Regenerating protobuf files..."

rm -f "$ROOT_DIR/Vendor/libphonenumber/cpp/src/phonenumbers/phonenumber.pb."*
rm -f "$ROOT_DIR/Vendor/libphonenumber/cpp/src/phonenumbers/phonemetadata.pb."*

"$PROTOC" \
  --cpp_out="$ROOT_DIR/Vendor/libphonenumber/cpp/src/phonenumbers" \
  -I "$ROOT_DIR/Vendor/libphonenumber/resources" \
  "$ROOT_DIR/Vendor/libphonenumber/resources/phonenumber.proto"

"$PROTOC" \
  --cpp_out="$ROOT_DIR/Vendor/libphonenumber/cpp/src/phonenumbers" \
  -I "$ROOT_DIR/Vendor/libphonenumber/resources" \
  "$ROOT_DIR/Vendor/libphonenumber/resources/phonemetadata.proto"

build_bridge() {
  local SDK_NAME="$1"
  local PLATFORM_NAME="$2"
  local ARCHS="$3"

  local SDK_PATH
  SDK_PATH="$(xcrun --sdk "$SDK_NAME" --show-sdk-path)"

  cmake -S "$BRIDGE_SRC" \
    -B "$BUILD_DIR/$PLATFORM_NAME" \
    -G Ninja \
    -DCMAKE_SYSTEM_NAME=iOS \
    -DCMAKE_OSX_SYSROOT="$SDK_PATH" \
    -DCMAKE_OSX_ARCHITECTURES="$ARCHS" \
    -DCMAKE_BUILD_TYPE=Release \
    -DPROTOBUF_INCLUDE_DIR="$ROOT_DIR/Native/ThirdParty/protobuf-ios/$PLATFORM_NAME/include" \
    -DPROTOBUF_LIB_DIR="$ROOT_DIR/Native/ThirdParty/protobuf-ios/$PLATFORM_NAME/lib" \
    -DABSEIL_INCLUDE_DIR="$ROOT_DIR/Native/ThirdParty/abseil-ios/$PLATFORM_NAME/include" \
    -DABSEIL_LIB_DIR="$ROOT_DIR/Native/ThirdParty/abseil-ios/$PLATFORM_NAME/lib"

  cmake --build "$BUILD_DIR/$PLATFORM_NAME"
  
  libtool -static -o "$BUILD_DIR/$PLATFORM_NAME/libPhoneNumberBridgeMerged.a" \
    "$BUILD_DIR/$PLATFORM_NAME/libPhoneNumberBridge.a" \
    "$ROOT_DIR/Native/ThirdParty/protobuf-ios/$PLATFORM_NAME/lib/"*.a \
    "$ROOT_DIR/Native/ThirdParty/abseil-ios/$PLATFORM_NAME/lib/"*.a
}

rm -rf "$BUILD_DIR"

build_bridge "iphoneos" "iphoneos" "arm64"
build_bridge "iphonesimulator" "iphonesimulator" "arm64"

rm -rf "$OUTPUT_DIR/PhoneNumberBridge.xcframework"

xcodebuild -create-xcframework \
  -library "$BUILD_DIR/iphoneos/libPhoneNumberBridgeMerged.a" \
  -headers "$BRIDGE_SRC/include" \
  -library "$BUILD_DIR/iphonesimulator/libPhoneNumberBridgeMerged.a" \
  -headers "$BRIDGE_SRC/include" \
  -output "$OUTPUT_DIR/PhoneNumberBridge.xcframework"

echo "✅ Created:"
echo "$OUTPUT_DIR/PhoneNumberBridge.xcframework"
