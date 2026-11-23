// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "OpenBox",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(name: "OpenBoxCore", targets: ["OpenBoxCore"]),
        .executable(name: "OpenBoxDemo", targets: ["OpenBoxDemo"])
    ],
    targets: [
        .target(name: "OpenBoxCore"),
        .executableTarget(name: "OpenBoxDemo", dependencies: ["OpenBoxCore"])
    ]
)
