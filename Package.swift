// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "LaunchAtLogin",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
        .library(
            name: "LaunchAtLogin",
            targets: ["LaunchAtLogin"]
        ),
        .executable(
            name: "LaunchAtLoginHelper.app",
            targets: ["LaunchAtLoginHelper"]
        )
    ],
    targets: [
        .target(
            name: "LaunchAtLogin",
            path: "LaunchAtLogin",
            exclude: [
                "Info.plist",
                "copy-helper.sh"
            ],
            resources: [
                .copy("LaunchAtLogin.entitlements"),
                .copy("copy-helper-swiftpm.sh")
            ]
        ),
        .target(
            name: "LaunchAtLoginHelper",
            path: "LaunchAtLoginHelper",
            exclude: [
                "Info.plist",
                "LaunchAtLoginHelper.entitlements"
            ]
        )
    ]
)
