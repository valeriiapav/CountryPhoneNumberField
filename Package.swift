// swift-tools-version: 6.2

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

        .target(
            name: "CountryPhoneNumberField",
            dependencies: [
                "PhoneNumberBridge"
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
