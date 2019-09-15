// swift-tools-version:5.1
import PackageDescription

let package = Package(
	name: "LaunchAtLogin",
	platforms: [
		.macOS(.v10_12)
	],
	products: [
		.library(
			name: "LaunchAtLogin",
			targets: [
				"LaunchAtLogin"
			]
		),
		.executable(
			name: "LaunchAtLoginHelper",
			targets: [
				"LaunchAtLoginHelper"
			]
		)
	],
	targets: [
		.target(
			name: "LaunchAtLogin"
		),
		.target(
			name: "LaunchAtLoginHelper"
		)
	]
)
