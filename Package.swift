// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorApplyPay",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "CapacitorApplyPay",
            targets: ["CapacitorApplyPayPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "CapacitorApplyPayPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/CapacitorApplyPayPlugin"),
        .testTarget(
            name: "CapacitorApplyPayPluginTests",
            dependencies: ["CapacitorApplyPayPlugin"],
            path: "ios/Tests/CapacitorApplyPayPluginTests")
    ]
)
