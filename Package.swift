// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "PagingNavigation",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "PagingNavigation", targets: ["PagingNavigation"]),
    ],
    targets: [
        .target(name: "PagingNavigation")
    ]
)