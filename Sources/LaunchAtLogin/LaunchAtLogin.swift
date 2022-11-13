import Foundation
import ServiceManagement
import Combine
import os.log

private let hasMigratedKey = "LaunchAtLogin__hasMigrated"

public enum LaunchAtLogin {
	@available(macOS 11, *)
	private static let logger = Logger(subsystem: "com.sindresorhus.LaunchAtLogin", category: "main")

	public static let kvo = KVO()

	@available(macOS 10.15, *)
	public static let observable = Observable()

	@available(macOS 10.15, *)
	private static let _publisher = CurrentValueSubject<Bool, Never>(isEnabled)
	@available(macOS 10.15, *)
	public static let publisher = _publisher.eraseToAnyPublisher()

	private static let id = "\(Bundle.main.bundleIdentifier!)-LaunchAtLoginHelper"

	private static var hasMigrated: Bool {
		get { UserDefaults.standard.bool(forKey: hasMigratedKey) }
		set {
			UserDefaults.standard.set(true, forKey: hasMigratedKey)
		}
	}

	public static func migrateIfNeeded() {
		guard
			#available(macOS 13, *),
			!hasMigrated
		else {
			return
		}

		hasMigrated = true

		if isEnabledLegacy {
			isEnabledModern = true
		}

		unregisterLegacy()
	}

	public static var isEnabled: Bool {
		get {
			if #available(macOS 13, *) {
				return isEnabledModern
			} else {
				return isEnabledLegacy
			}
		}
		set {
			if #available(macOS 10.15, *) {
				observable.objectWillChange.send()
			}

			kvo.willChangeValue(for: \.isEnabled)

			if #available(macOS 13, *) {
				isEnabledModern = newValue
			} else {
				isEnabledLegacy = newValue
			}

			kvo.didChangeValue(for: \.isEnabled)

			if #available(macOS 10.15, *) {
				_publisher.send(newValue)
			}
		}
	}

	@available(macOS 13, *)
	private static var isEnabledModern: Bool {
		get { SMAppService.mainApp.status == .enabled }
		set {
			do {
				if newValue {
					if SMAppService.mainApp.status == .enabled {
						try? SMAppService.mainApp.unregister()
					}

					try SMAppService.mainApp.register()
				} else {
					try SMAppService.mainApp.unregister()
				}
			} catch {
				logger.error("Failed to \(newValue ? "enable" : "disable") launch at login: \(error.localizedDescription)")
			}
		}
	}

	private static var isEnabledLegacy: Bool {
		get {
			guard let jobs = (LaunchAtLogin.self as DeprecationWarningWorkaround.Type).jobsDict else {
				return false
			}

			let job = jobs.first { ($0["Label"] as? String) == id }

			return job?["OnDemand"] as? Bool ?? false
		}
		set {
			SMLoginItemSetEnabled(id as CFString, newValue)
		}
	}

	@available(macOS 13, *)
	private static func unregisterLegacy() {
		isEnabledLegacy = false
		try? SMAppService.loginItem(identifier: id).unregister()
	}
}

// MARK: - LaunchAtLoginObservable
extension LaunchAtLogin {
	@available(macOS 10.15, *)
	public final class Observable: ObservableObject {
		public var isEnabled: Bool {
			get { LaunchAtLogin.isEnabled }
			set {
				LaunchAtLogin.isEnabled = newValue
			}
		}
	}
}

// MARK: - LaunchAtLoginKVO
extension LaunchAtLogin {
	public final class KVO: NSObject {
		@objc dynamic public var isEnabled: Bool {
			get { LaunchAtLogin.isEnabled }
			set {
				LaunchAtLogin.isEnabled = newValue
			}
		}
	}
}

private protocol DeprecationWarningWorkaround {
	static var jobsDict: [[String: AnyObject]]? { get }
}

extension LaunchAtLogin: DeprecationWarningWorkaround {
	// Workaround to silence "'SMCopyAllJobDictionaries' was deprecated in OS X 10.10" warning
	// Radar: https://openradar.appspot.com/radar?id=5033815495933952
	@available(*, deprecated)
	static var jobsDict: [[String: AnyObject]]? {
		SMCopyAllJobDictionaries(kSMDomainUserLaunchd)?.takeRetainedValue() as? [[String: AnyObject]]
	}
}
