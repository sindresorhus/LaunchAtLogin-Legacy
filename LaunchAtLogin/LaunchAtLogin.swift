import Combine
import Foundation
import ServiceManagement

public class LaunchAtLogin: NSObject {
    public static let shared = LaunchAtLogin()

    public static var isEnabled: Bool {
        get { shared.isEnabled }
        set { shared.isEnabled = newValue }
    }

    @available(OSX 10.15, *)
    public static var publisher: AnyPublisher<Bool, Never> = {
        shared
            .publisher(for: \.isEnabled)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }()

    private let id = "\(Bundle.main.bundleIdentifier!)-LaunchAtLoginHelper"

    @objc dynamic public var isEnabled: Bool {
        get {
            guard let jobs = (SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]]) else {
                return false
            }

            let job = jobs.first { $0["Label"] as! String == id }

            return job?["OnDemand"] as? Bool ?? false
        }
        set {
            if #available(OSX 10.15, *) {
                objectWillChange.send()
            }

            willChangeValue(for: \.isEnabled)
            SMLoginItemSetEnabled(id as CFString, newValue)
            didChangeValue(for: \.isEnabled)
        }
    }
}

@available(OSX 10.15, *)
extension LaunchAtLogin: ObservableObject { }
