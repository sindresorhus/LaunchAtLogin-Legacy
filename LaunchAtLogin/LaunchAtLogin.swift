import Combine
import Foundation
import ServiceManagement

public class LaunchAtLogin {
    public static let observable = LaunchAtLogin()
    public static let kvo = observable.kvo

    @available(macOS 10.15, *)
    public static var publisher = observable.publisher

    public static var isEnabled: Bool {
        get { observable.isEnabled }
        set { observable.isEnabled = newValue }
    }

    private let id = "\(Bundle.main.bundleIdentifier!)-LaunchAtLoginHelper"

    public lazy var kvo = LaunchAtLoginKVO(launchAtLogin: self)

    @available(macOS 10.15, *)
    private lazy var _publisher = CurrentValueSubject<Bool, Never>(isEnabled)
    @available(macOS 10.15, *)
    public lazy var publisher = _publisher.eraseToAnyPublisher()

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

            if #available(macOS 10.15, *) {
                _publisher.send(newValue)
            }
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
