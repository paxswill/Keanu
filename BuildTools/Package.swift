// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "BuildTools",
    platforms: [.macOS(.v10_11)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-format.git", .branch("swift-5.2-branch")),
        .package(url: "https://github.com/krzysztofzablocki/Sourcery.git", .branch("master")),
    ],
    targets: [.target(name: "BuildTools", path: "")]
)
