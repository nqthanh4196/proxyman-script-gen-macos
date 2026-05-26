// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ProxymanScriptGen",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ProxymanScriptGen",
            path: "Sources"
        )
    ]
)
