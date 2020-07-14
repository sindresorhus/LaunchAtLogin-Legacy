import Foundation
import ServiceManagement

public class LaunchAtLogin {
    public static let shared = LaunchAtLogin()

    public static var isEnabled: Bool {
        get { shared.isEnabled }
        set { shared.isEnabled = newValue }
    }
    private let id = "\(Bundle.main.bundleIdentifier!)-LaunchAtLoginHelper"

	public var isEnabled: Bool {
		get {
			guard let jobs = (SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]]) else {
				return false
			}

			let job = jobs.first { $0["Label"] as! String == id }

			return job?["OnDemand"] as? Bool ?? false
		}
		set {
			SMLoginItemSetEnabled(id as CFString, newValue)
		}
	}
}
