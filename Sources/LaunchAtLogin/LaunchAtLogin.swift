import Foundation
import ServiceManagement
import Combine

public enum LaunchAtLogin {
	public static let kvo = KVO()

	@available(macOS 10.15, *)
	public static let observable = Observable()

	@available(macOS 10.15, *)
	private static let _publisher = CurrentValueSubject<Bool, Never>(isEnabled)
	@available(macOS 10.15, *)
	public static let publisher = _publisher.eraseToAnyPublisher()

	private static let id = "\(Bundle.main.bundleIdentifier!)-LaunchAtLoginHelper"

	public static var isEnabled: Bool {
		get {
			guard let jobs = (SMCopyAllJobDictionaries(kSMDomainUserLaunchd)?.takeRetainedValue() as? [[String: AnyObject]]) else {
				return false
			}

			let job = jobs.first { ($0["Label"] as? String) == id }

			return job?["OnDemand"] as? Bool ?? false
		}
		set {
			if #available(macOS 10.15, *) {
				observable.objectWillChange.send()
			}

			kvo.willChangeValue(for: \.isEnabled)
			Self._SMLoginItemSetEnabled(id: id, isEnabled: newValue)
			kvo.didChangeValue(for: \.isEnabled)

			if #available(macOS 10.15, *) {
				_publisher.send(newValue)
			}
		}
	}
	
	private static func _SMLoginItemSetEnabled(id: String, isEnabled: Bool) {
		let handle = dlopen(nil, RTLD_LAZY)
		let sym = dlsym(handle, "SMLoginItemSetEnabled")
		typealias Prototype = @convention(c) (_ identifier: CFString, _ enabled: Bool) -> Bool
		let _SMLoginItemSetEnabled = unsafeBitCast(sym, to: Prototype.self)
		
		_SMLoginItemSetEnabled(id as CFString, isEnabled)
		
		dlclose(handle)
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
