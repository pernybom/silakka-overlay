// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Silakka54Overlay",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "silakka54-overlay", targets: ["Silakka54Overlay"])
    ],
    targets: [
        .executableTarget(
            name: "Silakka54Overlay",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("IOKit"),
                .linkedFramework("CoreFoundation"),
            ]
        )
    ]
)

