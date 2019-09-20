# LaunchAtLogin

> Add "Launch at Login" functionality to your macOS app in seconds

It's usually quite a [convoluted and error-prone process](before-after.md) to add this. **No more!**

This package works with both sandboxed and non-sandboxed apps and it's App Store compatible and used in my [Lungo](https://blog.sindresorhus.com/lungo-b364a6c2745f) and [Battery Indicator](https://sindresorhus.com/battery-indicator) apps.

*You might also find my [`create-dmg`](https://github.com/sindresorhus/create-dmg) project useful if you're publishing your app outside the App Store.*


## Requirements

- macOS 10.12+
- Xcode 10.2+
- Swift 5+


## Install

#### Carthage

```
github "sindresorhus/LaunchAtLogin"
```


## Usage

Add a new ["Run Script Phase"](http://stackoverflow.com/a/39633955/64949) below "Embed Frameworks" in "Build Phases" with the following:

```sh
"${PROJECT_DIR}/Carthage/Build/Mac/LaunchAtLogin.framework/Resources/copy-helper.sh"
```

Use it in your app:

```swift
import LaunchAtLogin

print(LaunchAtLogin.isEnabled)
//=> false

LaunchAtLogin.isEnabled = true

print(LaunchAtLogin.isEnabled)
//=> true
```

*Note that the [Mac App Store guidelines](https://developer.apple.com/app-store/review/guidelines/) requires "launch at login" functionality to be enabled in response to a user action. This is usually solved by making it a preference that is disabled by default.*


## How does it work?

The framework bundles the helper app needed to launch your app and copies it into your app at build time.


## FAQ

#### Can you support CocoaPods?

CocoaPods used to be supported, but [it did not work well](https://github.com/sindresorhus/LaunchAtLogin/issues/22) and there was no easy way to fix it, so support was dropped. Even though you mainly use CocoaPods, you can still use Carthage just for this package without any problems.

#### I'm getting a `'SMCopyAllJobDictionaries' was deprecated in OS X 10.10` warning

Apple deprecated that API without providing an alternative. Apple engineers have [stated that it's still the preferred API to use](https://github.com/alexzielenski/StartAtLoginController/issues/12#issuecomment-307525807). I plan to use it as long as it's available. There are workarounds I can implement if Apple ever removes the API, so rest assured, this module will be made to work even then. If you want to see this resolved, submit a [Feedback Assistant](https://feedbackassistant.apple.com) report with [the following text](https://github.com/feedback-assistant/reports/issues/16). There's unfortunately still [no way to supress warnings in Swift](https://stackoverflow.com/a/32861678/64949).


## Related

- [Defaults](https://github.com/sindresorhus/Defaults) - Swifty and modern UserDefaults
- [Preferences](https://github.com/sindresorhus/Preferences) - Add a preferences window to your macOS app in minutes
- [DockProgress](https://github.com/sindresorhus/DockProgress) - Show progress in your app's Dock icon
- [More…](https://github.com/search?q=user%3Asindresorhus+language%3Aswift)


## License

MIT © [Sindre Sorhus](https://sindresorhus.com)
