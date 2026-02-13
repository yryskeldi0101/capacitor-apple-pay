// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorApplePay",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "CapacitorApplePay",
            targets: ["CapacitorApplePayPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "CapacitorApplePayPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/CapacitorApplePayPlugin"),
        .testTarget(
            name: "CapacitorApplePayPluginTests",
            dependencies: ["CapacitorApplePayPlugin"],
            path: "ios/Tests/CapacitorApplePayPluginTests")
    ]
)
