import Cocoa

public extension NSMenu {
	private class LaunchAtLoginMenuItem: NSMenuItem {
		convenience init() {
			self.init(
				title: "Launch at Login",
				action: #selector(toggleLaunchAtLogin(_:)),
				keyEquivalent: ""
			)

			state = LaunchAtLogin.isEnabled ? .on : .off
		}

		@objc func toggleLaunchAtLogin(_: NSMenuItem) {
			LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
		}
	}

	func launchAtLoginItem() -> NSMenuItem {
		return LaunchAtLoginMenuItem()
	}

	func addLaunchAtLoginItem() {
		self.addItem(LaunchAtLoginMenuItem())
	}
}
