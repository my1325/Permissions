// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Permissions",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "PermissionsCore", targets: ["PermissionsCore"]),
        .library(name: "AVDevice", targets: ["AVDevice"]),
        .library(name: "Notification", targets: ["Notification"]),
        .library(name: "PhotoLibrary", targets: ["PhotoLibrary"]),
        .library(name: "AppTracking", targets: ["AppTracking"]),
        .library(name: "Location", targets: ["Location"]),
        .library(name: "Contact", targets: ["Contact"]),
        .library(name: "Event", targets: ["Event"]),
    ],
    targets: [
        .target(name: "PermissionsCore", dependencies: []),
        .target(name: "AVDevice", dependencies: ["PermissionsCore"]),
        .target(name: "Notification", dependencies: ["PermissionsCore"]),
        .target(name: "PhotoLibrary", dependencies: ["PermissionsCore"]),
        .target(name: "AppTracking", dependencies: ["PermissionsCore"]),
        .target(name: "Location", dependencies: ["PermissionsCore"]),
        .target(name: "Contact", dependencies: ["PermissionsCore"]),
        .target(name: "Event", dependencies: ["PermissionsCore"]),
    ]
)
