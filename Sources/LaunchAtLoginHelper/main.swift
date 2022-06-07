import AppKit

// TODO: When targeting macOS 11, convert this to use `App` protocol and remove `NSPrincipalClass` in Info.plist.

final class AppDelegate: NSObject, NSApplicationDelegate {
	let nc = DistributedNotificationCenter.default()
	
	@objc func terminateApp() {
		NSLog("LaunchAtLogin helper terminateApp called")
		nc.removeObserver(self)
		NSApp.terminate(nil)
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		let bundleIdentifier = Bundle.main.bundleIdentifier!
		let mainBundleIdentifier = bundleIdentifier.replacingOccurrences(of: #"-LaunchAtLoginHelper$"#, with: "", options: .regularExpression)

		// Ensures the app is not already running.
		guard NSRunningApplication.runningApplications(withBundleIdentifier: mainBundleIdentifier).isEmpty else {
			NSApp.terminate(nil)
			return
		}

		let pathComponents = (Bundle.main.bundlePath as NSString).pathComponents
		let mainPath = NSString.path(withComponents: Array(pathComponents[0...(pathComponents.count - 5)]))
		NSWorkspace.shared.launchApplication(mainPath)
		nc.addObserver(self, selector: #selector(terminateApp), name: NSNotification.Name("TerminateHelper"), object: nil)
		NSLog("LaunchAtLogin helper exited")
	}
}

private let app = NSApplication.shared
private let delegate = AppDelegate()
app.delegate = delegate
app.run()
