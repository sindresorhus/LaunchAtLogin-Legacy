// swift-tools-version:4.0

import PackageDescription

let package = Package(
	name: "LaunchAtLogin",
	products: [
		.library(
			name: "LaunchAtLogin",
			targets: [
				"LaunchAtLogin",
			]
		)
	],
	targets: [
		.target(
			name: "LaunchAtLogin",
			path: "LaunchAtLogin"
		)
	]
)
