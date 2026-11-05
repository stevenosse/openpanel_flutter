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
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "OpenPanel",
            path: "Vendor/OpenPanel/Sources/OpenPanel"
        ),
        .target(
            name: "openpanel_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .target(name: "OpenPanel")
            ]
        )
    ]
)
