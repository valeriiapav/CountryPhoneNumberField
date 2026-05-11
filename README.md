# CountryPhoneNumberField

`CountryPhoneNumberField` uses Google's `libphonenumber` through a prebuilt native XCFramework:

```text
Binary/PhoneNumberBridge.xcframework
```

The XCFramework is built from native C++ sources using:

- Google libphonenumber
- protobuf
- abseil
- CMake
- custom Objective-C++ bridge

Consumers of this Swift package do **not** need to install protobuf, CMake, Abseil, or libphonenumber manually.

---

# Project structure

```text
CountryPhoneNumberField/
├── Package.swift
├── Sources/
│   └── CountryPhoneNumberField/
├── Binary/
│   └── PhoneNumberBridge.xcframework
├── Native/
│   ├── PhoneNumberBridge/
│   │   ├── CMakeLists.txt
│   │   ├── PhoneNumberBridge.mm
│   │   └── include/
│   │       ├── PhoneNumberBridge.h
│   │       └── module.modulemap
│   │
│   ├── Build/
│   │
│   └── ThirdParty/
│       ├── abseil-cpp/
│       ├── abseil-ios/
│       ├── protobuf/
│       └── protobuf-ios/
│
├── Vendor/
│   └── libphonenumber/
│
└── Scripts/
    ├── build-abseil-ios.sh
    ├── build-protobuf-ios.sh
    └── build-phone-bridge-cmake.sh
```

---

# First-time setup

After cloning the repository:

```bash
git submodule update --init --recursive
```

Install required build tools:

```bash
brew install cmake ninja protobuf
```

Point Xcode CLI tools to the full Xcode installation:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

Verify iOS SDK availability:

```bash
xcrun --sdk iphoneos --show-sdk-path
xcrun --sdk iphonesimulator --show-sdk-path
```

---

# Full rebuild

Run from repository root:

```bash
./Scripts/build-abseil-ios.sh
./Scripts/build-protobuf-ios.sh
./Scripts/build-phone-bridge-cmake.sh
```

Successful output:

```text
Binary/PhoneNumberBridge.xcframework
```

Commit rebuilt binary:

```bash
git add Binary/PhoneNumberBridge.xcframework
git commit -m "Rebuild PhoneNumberBridge.xcframework"
```

---

# Updating Google libphonenumber

Check available versions:

```bash
cd Vendor/libphonenumber
git fetch --tags
git tag --sort=-v:refname | head
```

Checkout desired version:

```bash
git checkout <new-libphonenumber-tag>
```

Example:

```bash
git checkout v8.13.55
```

Return to repository root:

```bash
cd ../..
```

Rebuild bridge:

```bash
./Scripts/build-phone-bridge-cmake.sh
```

If protobuf-generated files or dependencies changed significantly, rebuild everything:

```bash
./Scripts/build-abseil-ios.sh
./Scripts/build-protobuf-ios.sh
./Scripts/build-phone-bridge-cmake.sh
```

Then commit:

```bash
git add Vendor/libphonenumber Binary/PhoneNumberBridge.xcframework
git commit -m "Update libphonenumber and rebuild PhoneNumberBridge"
```

---

# Updating protobuf or Abseil

Usually unnecessary when only updating libphonenumber.

If required:

## Update Abseil

```bash
cd Native/ThirdParty/abseil-cpp
git fetch --tags
git tag --sort=-v:refname | head
git checkout <new-abseil-tag>
cd ../../..
```

## Update protobuf

```bash
cd Native/ThirdParty/protobuf
git fetch --tags
git tag --sort=-v:refname | head
git checkout <new-protobuf-tag>
cd ../../..
```

Rebuild:

```bash
./Scripts/build-abseil-ios.sh
./Scripts/build-protobuf-ios.sh
./Scripts/build-phone-bridge-cmake.sh
```

Commit:

```bash
git add Native/ThirdParty/abseil-cpp Native/ThirdParty/protobuf Binary/PhoneNumberBridge.xcframework
git commit -m "Update native dependencies and rebuild PhoneNumberBridge"
```

---

# What the scripts do

## build-abseil-ios.sh

Builds Abseil for:

```text
iphoneos
iphonesimulator
```

Output:

```text
Native/ThirdParty/abseil-ios/
```

---

## build-protobuf-ios.sh

Builds protobuf for:

```text
iphoneos
iphonesimulator
```

Output:

```text
Native/ThirdParty/protobuf-ios/
```

---

## build-phone-bridge-cmake.sh

This script:

1. Regenerates protobuf-generated files
2. Builds native Objective-C++ bridge
3. Builds libphonenumber C++ sources
4. Packages everything into:

```text
Binary/PhoneNumberBridge.xcframework
```

The script automatically regenerates:

```text
Vendor/libphonenumber/cpp/src/phonenumbers/phonenumber.pb.h
Vendor/libphonenumber/cpp/src/phonenumbers/phonenumber.pb.cc
Vendor/libphonenumber/cpp/src/phonenumbers/phonemetadata.pb.h
Vendor/libphonenumber/cpp/src/phonenumbers/phonemetadata.pb.cc
```

These files must exist inside:

```text
Vendor/libphonenumber/cpp/src/phonenumbers/
```

because Google source files include them as:

```cpp
#include "phonenumbers/phonenumber.pb.h"
#include "phonenumbers/phonemetadata.pb.h"
```

---

# Swift Package integration

`Package.swift` uses a binary target:

```swift
.binaryTarget(
    name: "PhoneNumberBridge",
    path: "Binary/PhoneNumberBridge.xcframework"
)
```

The Swift target depends on it:

```swift
.target(
    name: "CountryPhoneNumberField",
    dependencies: [
        "PhoneNumberBridge"
    ]
)
```

Consumers simply add the package normally:

```swift
.package(url: "...", from: "1.0.0")
```

No native setup required.

---

# ICU note

This build intentionally avoids ICU.

ICU is a large C/C++ dependency used by libphonenumber for:

- advanced Unicode handling
- regex matching
- text scanning
- `PhoneNumberMatcher`

Current bridge API only supports:

```objc
- isValidNumber:regionCode:
- formatE164:regionCode:
```

These do not require ICU.

If future functionality requires scanning arbitrary text for phone numbers, ICU support may need to be added.

---

# Troubleshooting

## No such module 'PhoneNumberBridge'

Verify:

```text
Binary/PhoneNumberBridge.xcframework
```

exists.

Verify `Package.swift` contains:

```swift
.binaryTarget(
    name: "PhoneNumberBridge",
    path: "Binary/PhoneNumberBridge.xcframework"
)
```

Verify module map exists:

```text
Native/PhoneNumberBridge/include/module.modulemap
```

Content:

```modulemap
module PhoneNumberBridge {
    header "PhoneNumberBridge.h"
    export *
}
```

Rebuild:

```bash
./Scripts/build-phone-bridge-cmake.sh
```

Then reset Xcode caches:

```text
File → Packages → Reset Package Caches
Product → Clean Build Folder
```

---

## phonenumber.pb.h file not found

Generated protobuf files are missing.

Run:

```bash
./Scripts/build-phone-bridge-cmake.sh
```

Generated files must exist inside:

```text
Vendor/libphonenumber/cpp/src/phonenumbers/
```

---

## unicode/unistr.h file not found

ICU-only source files are being compiled.

Check:

```text
Native/PhoneNumberBridge/CMakeLists.txt
```

Avoid compiling:

```text
regexp_adapter_icu.cc
phonenumbermatcher.cc
string_byte_sink.cc
```

unless ICU support is intentionally added.

---

## protoc killed

An iOS-built `protoc` binary was accidentally executed on macOS.

Use the macOS-built protobuf compiler.

The build script handles this automatically.

---

## Submodules are empty after clone

Run:

```bash
git submodule update --init --recursive
```

---

# Release checklist

Before tagging a release:

```bash
git submodule status
./Scripts/build-abseil-ios.sh
./Scripts/build-protobuf-ios.sh
./Scripts/build-phone-bridge-cmake.sh
swift package resolve
swift build
```

Commit:

```bash
git add .
git commit -m "Prepare release"
```

Tag and push:

```bash
git tag <version>
git push origin main --tags
```
