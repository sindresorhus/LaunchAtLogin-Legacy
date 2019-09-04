import PackageDescription

let package = Package(name: "LaunchAtLogin",
                      platforms: [.macOS(.v10_12)],
                      products: [.library(name: "LaunchAtLogin",
                                          targets: ["LaunchAtLogin", "LaunchAtLoginHelper"])],
                      targets: [.target(name: "LaunchAtLogin",
                                        path: "LaunchAtLogin"),
                                        .target(name: "LaunchAtLoginHelper",
                                        path: "LaunchAtLoginHelper")],
                      swiftLanguageVersions: [.v5])
