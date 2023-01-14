// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Permissions",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "Permissions", targets: ["Permissions"]),
    ],
    targets: [.target(name: "Permissions", dependencies: [])]
)
