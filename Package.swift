// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CountryPhoneNumberField",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "CountryPhoneNumberField",
            targets: ["CountryPhoneNumberField"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "PhoneNumberBridge",
            path: "Binary/PhoneNumberBridge.xcframework"
        ),

        // ObjC libPhoneNumber-iOS — used for as-you-type formatting only.
        // Validation stays in the C++ PhoneNumberBridge.
        .target(
            name: "NBPhoneNumber",
            path: "Sources/NBPhoneNumber",
            exclude: ["Internal"],          // empty stub dir — kept by filesystem
            publicHeadersPath: "include",   // umbrella header lives here, away from Internal/
            linkerSettings: [
                .linkedFramework("CoreTelephony")
            ]
        ),

        .target(
            name: "CountryPhoneNumberField",
            dependencies: [
                "PhoneNumberBridge",
                "NBPhoneNumber"
            ],
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedLibrary("icucore")
            ]
        )

        // .testTarget(
        //     name: "CountryPhoneNumberFieldTests",
        //     dependencies: ["CountryPhoneNumberField"]
        // )
    ]
)
