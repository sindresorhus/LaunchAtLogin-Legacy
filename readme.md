# LaunchAtLogin

> Add "Launch at Login" functionality to your sandboxed macOS app in seconds

It's usually quite a convoluted and error-prone process to add this. **No more!**

```diff
-  1. Create a new target that will be the helper app that launches your app
-  2. Set `LSBackgroundOnly` to true in the `Info.plist` file
-  3. Set `Skip Install` to `YES` in the build settings for the helper app
-  4. Enable sandboxing for the helper app
-  5. Add a new `Copy Files` build phase to the main app
-  6. Select `Wrapper` as destination
-  7. Enter `Contents/Library/LoginItems` as subpath
-  8. Add the helper build product to the build phase
-  9. Copy-paste some boilerplate code into the helper app
- 10. Remember to replace `bundleid.of.main.app` and `MainExectuableName` with your own values
- 11. Copy-paste some code to register the helper app into your main app
- 12. Make sure the main app and helper app use the same code signing certificate
- 13. Manually verify that you did everything correctly
+  1. Install this package
+  2. Add a new "Run Script Phase"
```

It's App Store compatible and used in my [Lungo](https://blog.sindresorhus.com/lungo-b364a6c2745f) and [Battery Indicator](https://sindresorhus.com/battery-indicator) app.

You might also find my [`create-dmg`](https://github.com/sindresorhus/create-dmg) project useful.


## Requirements

- macOS 10.12+
- Xcode 9.3+
- Swift 4.1+


## Install with [Carthage](https://github.com/Carthage/Carthage#getting-started)

```
github "sindresorhus/LaunchAtLogin"
```

<a href="https://www.patreon.com/sindresorhus">
	<img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" width="160">
</a>


## Usage

Add a new ["Run Script Phase"](http://stackoverflow.com/a/39633955/64949) below "Embed Frameworks" in "Build Phases" with the following:

```sh
./Carthage/Build/Mac/LaunchAtLogin.framework/Resources/copy-helper.sh
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


## Related

- [DockProgress](https://github.com/sindresorhus/DockProgress) - Show progress in your app's Dock icon


## License

MIT © [Sindre Sorhus](https://sindresorhus.com)
