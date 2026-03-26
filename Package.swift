// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TiltBrew",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "TiltBrew",
            path: "TiltBrew",
            linkerSettings: [
                .linkedFramework("IOKit"),
                .linkedFramework("AVFoundation"),
            ]
        )
    ]
)
