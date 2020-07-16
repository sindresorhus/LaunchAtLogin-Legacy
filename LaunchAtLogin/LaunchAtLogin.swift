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

@available(macOS 10.15, *)
extension LaunchAtLogin: ObservableObject { }

// MARK: - LaunchAtLoginKVO
extension LaunchAtLogin {
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
}

// MARK: - Toggle
#if canImport(SwiftUI)
  import SwiftUI
#endif

@available(macOS 10.15, *)
extension LaunchAtLogin {
    /// A control that toggles launch at login between on and off states.
    ///
    /// You create a toggle by providing a label. Set the label to a view
    /// that visually describes the purpose of switching between
    /// launch at login states. For example:
    ///
    ///     var body: some View {
    ///         LaunchAtLogin.Toggle {
    ///             Text("Launch at login")
    ///         }
    ///     }
    ///
    /// For the common case of text-only labels, you can use the convenience
    /// initializer that takes a title string (or localized string key) as its first
    /// parameter, instead of a trailing closure:
    ///
    ///     var body: some View {
    ///         LaunchAtLogin.Toggle("Launch at login")
    ///     }
    ///
    /// Default initializer will use "Launch at login" as a title.
    ///
    ///     var body: some View {
    ///         LaunchAtLogin.Toggle()
    ///     }
    ///
    public struct Toggle<Label>: View where Label: View {
        @ObservedObject private var launchAtLogin = LaunchAtLogin.observable

        public let label: Label

        /// Creates a launch at login toggle that displays a custom label.
        ///
        /// - Parameters:
        ///   - label: A view that describes the purpose of the toggle.
        public init(@ViewBuilder label: () -> Label) {
            self.label = label()
        }

        public var body: some View {
            SwiftUI.Toggle(isOn: $launchAtLogin.isEnabled) {
                label
            }
            .toggleStyle(CheckboxToggleStyle())
        }
    }
}

@available(macOS 10.15, *)
extension LaunchAtLogin.Toggle where Label == Text {
    /// Creates a launch at login toggle that generates its label from a localized string key.
    ///
    /// This initializer creates a ``Text`` view on your behalf with provided `titleKey`
    ///
    /// - Parameters:
    ///   - titleKey: The key for the toggle's localized title, that describes
    ///     the purpose of the toggle.
    public init(_ titleKey: LocalizedStringKey) {
        label = Text(titleKey)
    }

    /// Creates a launch at login toggle that generates its label from a string.
    ///
    /// This initializer creates a ``Text`` view on your behalf with provided `title`.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the toggle.
    public init<S>(_ title: S) where S: StringProtocol {
        label = Text(title)
    }

    /// Creates a launch at login toggle with default title.
    ///
    /// This initializer creates a ``Text`` view on your behalf with ``Launch at login``
    /// default title.
    public init() {
        self.init("Launch at login")
    }
}
