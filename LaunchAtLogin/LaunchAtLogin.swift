import Combine
import Foundation
import ServiceManagement

public class LaunchAtLogin {
    public static let observable = LaunchAtLogin()
    public static let kvo = observable.kvo

    public static var isEnabled: Bool {
        get { observable.isEnabled }
        set { observable.isEnabled = newValue }
    }

    @available(macOS 10.15, *)
    public static var publisher: AnyPublisher<Bool, Never> = {
        LaunchAtLogin
            .kvo
            .publisher(for: \.isEnabled)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }()

    private let id = "\(Bundle.main.bundleIdentifier!)-LaunchAtLoginHelper"

    public lazy var kvo = LaunchAtLoginKVO(launchAtLogin: self)

    public var isEnabled: Bool {
        get {
            guard let jobs = (SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]]) else {
                return false
            }

            let job = jobs.first { $0["Label"] as! String == id }

            return job?["OnDemand"] as? Bool ?? false
        }
        set {
            if #available(macOS 10.15, *) {
                objectWillChange.send()
            }

            kvo.willChangeValue(for: \.isEnabled)
            SMLoginItemSetEnabled(id as CFString, newValue)
            kvo.didChangeValue(for: \.isEnabled)
        }
    }
}

public class LaunchAtLoginKVO: NSObject {
    private let launchAtLogin: LaunchAtLogin

    init(launchAtLogin: LaunchAtLogin) {
        self.launchAtLogin = launchAtLogin
    }

    @objc dynamic public var isEnabled: Bool {
        get { launchAtLogin.isEnabled }
        set { launchAtLogin.isEnabled = newValue }
    }
}

@available(macOS 10.15, *)
extension LaunchAtLogin: ObservableObject { }
