// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrepMealForm",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PrepMealForm",
            targets: ["PrepMealForm"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pxlshpr/NamePicker", from: "0.0.19"),
        .package(url: "https://github.com/pxlshpr/SwiftHaptics", from: "0.1.3"),
        .package(url: "https://github.com/pxlshpr/SwiftSugar", from: "0.0.76"),
        .package(url: "https://github.com/pxlshpr/SwiftUISugar", from: "0.0.210"),
        .package(url: "https://github.com/pxlshpr/Timeline", from: "0.0.53"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PrepMealForm",
            dependencies: [
                .product(name: "NamePicker", package: "namepicker"),
                .product(name: "SwiftHaptics", package: "swifthaptics"),
                .product(name: "SwiftSugar", package: "swiftsugar"),
                .product(name: "SwiftUISugar", package: "swiftuisugar"),
                .product(name: "Timeline", package: "timeline"),
            ]),
        .testTarget(
            name: "PrepMealFormTests",
            dependencies: ["PrepMealForm"]),
    ]
)
