// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "openpanel_flutter",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(
            name: "openpanel-flutter",
            targets: ["openpanel_flutter"]
        )
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/Openpanel-dev/swift-sdk", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "openpanel_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "OpenPanel", package: "swift-sdk")
            ]
        )
    ]
)
