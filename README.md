# Hybrid Stack Manager

Make embedding Flutter as easy as a **WebView**, but with **Native Performance**.

A plugin designed for **Add-to-App** scenarios that manages hybrid navigation stacks efficiently using `FlutterEngineGroup`.

![](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

## Why use this?

**Hybrid Stack Manager** solves the "heavyweight" problem of integrating Flutter.

1.  **Lightweight**: New Flutter pages cost only **~180kB** RAM (vs ~19MB traditionally).
2.  **Fast**: Instant startup (milliseconds) by sharing AOT resources.
3.  **Simple**: API designed to feel just like opening a WebView or a Native Controller.

| Goal | Capability | Description | Performance Benchmark |
| --- | --- | --- | --- |
| Native Integration | Engine Group | Use `FlutterEngineGroup` to manage engines | Memory usage reduced from ~19MB to **~180kB** per engine |
| Startup Performance | Fast Warm-up | Reuse pre-loaded AOT code & resources | Startup speed improved by approx **10x** |
| Hybrid Navigation | Bi-directional | Push/Pop between Flutter & Native | Native-like smoothness with shared stack |
| Router Agnostic | Seamless Plugin | Works with `GoRouter`, `AutoRoute`, etc. | Zero interference with existing app routing |
| Type-safe Bridge | Pigeon | Auto-generated communication bridge | Better performance and safety than MethodChannel |

## Features

- 🚀 **Type-Safe Communication**: Powered by [Pigeon](https://pub.dev/packages/pigeon), eliminating stringly-typed MethodChannels.
- 🔀 **Unified Navigation**: Treat Flutter pages and Native pages as a single navigation stack.
- 🧠 **Engine Management Ready**: Designed to work with `FlutterEngineGroup` for memory-efficient multi-engine support.
- 📱 **Platform Agnostic API**: Simple `pushNative` and `popNative` from Dart; `pushFlutter` and `popFlutter` from Native.
- 🧩 **Router-Agnostic**: Works with `Navigator`, `go_router`, `auto_route`, or custom routing.

## ⚖️ Comparison with Alternatives

| Feature | **Hybrid Stack Manager** | **Flutter Boost** | **Thrio** | **Official Naive Multi-Engine** |
| :--- | :--- | :--- | :--- | :--- |
| **Architecture** | `FlutterEngineGroup` (Multi-Engine) | Single Engine | Single Engine | Multiple Engines |
| **Memory Usage** | ✅ Low (~180kB/page) | ✅ Low (Shared) | ✅ Low (Shared) | ❌ High (~19MB/page) |
| **Integration** | ✅ **Non-Invasive** (Standard API) | ❌ Invasive (Hooks into Engine) | ⚠️ Complex | ✅ Standard |
| **State Isolation**| ✅ **High** (Separate Isolates) | ❌ Low (Shared Isolate) | ❌ Low (Shared Isolate) | ✅ High |
| **Complexity** | 🟢 **Simple** | 🔴 High | 🔴 High | 🟡 Medium |
| **Router Support**| ✅ **Any** (GoRouter, etc.) | ⚠️ Custom Router Required | ⚠️ Custom Router Required | ✅ Any |

**Why choose Hybrid Stack Manager?**
- **Isolation**: True isolation between pages (a crash in one Flutter page doesn't kill the entire Flutter stack).
- **Simplicity**: No complex setup or engine hacking. Just "Start Activity" or "Push ViewController".
- **Flexibility**: Use whatever Dart router you love (GoRouter, AutoRoute, etc.).

## Getting Started

## Add-to-App Integration Checklist

Use this when embedding Flutter into an existing Native app.

### Android

1. Add the Flutter module as a dependency in your native app (recommended via `settings.gradle` + `implementation project(...)`).
   - settings.gradle
     ```gradle
     // include Flutter module
     include ':flutter_module'
     project(':flutter_module').projectDir = new File(rootProject.projectDir, '../flutter_module')
     ```
   - app/build.gradle
     ```gradle
     dependencies {
         implementation project(':flutter_module')
     }
     ```
2. Initialize the engine group once in `Application.onCreate()` via `HybridStack.init(this)`.
3. Decide your container strategy:
  - Use `HybridFlutterActivity.withNewEngine(...)` for new Flutter pages.
  - Or host in a custom `FlutterActivity` / `FlutterFragment` with `HybridStack.createEngine(...)`.
4. Register your navigation bridge:
  - Set `HybridStackManagerPlugin.onPushNative` to handle `pushNative()` requests.

### iOS

1. Add the Flutter module as a dependency in your native app (CocoaPods or Xcode build settings).
   - Podfile
     ```ruby
     flutter_application_path = '../flutter_module'
     load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

     target 'YourApp' do
       install_all_flutter_pods(flutter_application_path)
     end
     ```
2. Configure the engine group once in `AppDelegate`:
  - Call `HybridStack.shared.configure { GeneratedPluginRegistrant.register(with: $0) }`.
3. Decide your container strategy:
  - Use `HybridStack.shared.makeFlutterViewController(...)` for new Flutter pages.
4. Register your navigation bridge:
  - Set `HybridStackManagerPlugin.onPushNative` to handle `pushNative()` requests.

### 1. Add Dependency

```yaml
dependencies:
  hybrid_stack_manager:
    path: ../hybrid_stack_manager # or git url
```

### 2. Dart Setup

Initialize the manager and set your router delegate (e.g., using GoRouter):

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Listen to navigation requests from Native
    HybridStackManager.instance.setDelegate(
      onPush: (routeName, args) {
        // e.g., context.push(routeName, extra: args);
        print("Native requested push: $routeName");
      },
      onPop: () {
        // e.g., context.pop();
        print("Native requested pop");
      },
    );
  }
  // ...
}
```

### 3. Android Setup

In your `Application` class:

```kotlin
import com.aegislabs.hybrid_stack_manager.HybridStack
import com.aegislabs.hybrid_stack_manager.HybridStackManagerPlugin

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        // 1. Initialize HybridStack (creates FlutterEngineGroup)
        HybridStack.init(this)
        
        // 2. Set up native navigation handler
        HybridStackManagerPlugin.onPushNative = { activity, routeName, args ->
            // Handle navigation commands from Flutter
            if (routeName == "profile") {
                // Example: Launching a NEW Flutter Activity using the Engine Group
                val intent = HybridFlutterActivity.withNewEngine(activity, initialRoute = "/profile")
                activity.startActivity(intent)
            } else if (routeName == "settings") {
                // Example: Launching a pure Native Activity
                activity.startActivity(Intent(activity, SettingsActivity::class.java))
            }
        }
    }
}
```

### 4. iOS Setup

In your `AppDelegate.swift`:

```swift
import hybrid_stack_manager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    // (Optional) Hold a reference if you want, but HybridStack.shared is a singleton
    // let engineGroup = FlutterEngineGroup(name: "my_group", project: nil)

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // 1. Configure HybridStack with Plugin Registration
        // CRITICAL: You must pass GeneratedPluginRegistrant.register so new engines work!
        HybridStack.shared.configure(engineGroup: nil) { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }
        
        // 2. Handle requests from Flutter
        HybridStackManagerPlugin.onPushNative = { [weak self] routeName, args in
            guard let self = self else { return }
            
            // Getting the current navigation controller (Example implementation)
            let rootNav = self.window?.rootViewController as? UINavigationController
            
            if routeName == "profile" {
                // Example: Open a NEW Flutter Page efficiently
                let vc = HybridStack.shared.makeFlutterViewController(
                    initialRoute: "/profile"
                )
                rootNav?.pushViewController(vc, animated: true)
                
            } else if routeName == "camera" {
                 // Example: Open Native Page
                 let vc = MyNativeCameraViewController()
                 rootNav?.pushViewController(vc, animated: true)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```


## Architecture

This plugin acts as a bridge. It does not enforce a specific routing library (like GoRouter or AutoRoute) but provides the necessary hooks to connect them with the Native world.

- **Dart -> Native**: `HybridStackManager.instance.pushNative("profile")`
- **Native -> Dart**: Use the generated `FlutterStackApi` class to message Flutter.

## Performance

Leveraging `FlutterEngineGroup`, this library provides significant advantages over traditional multi-engine approaches:

- **Memory Efficiency**: Subsequent engines consume only about **180kB** of memory (compared to ~19MB+ in traditional multi-engine setups), allowing for a large number of Flutter containers without hitting memory limits.
- **Startup Time**: Since resources and AOT code segments are shared, the startup time for new engines is reduced to milliseconds, ensuring a seamless user transition.
- **Rendering Consistency**: All engine instances share common raster and I/O threads, maintaining UI consistency across the app.

## Multiple Flutter Modules / Entrypoints

If you have multiple Flutter **features** inside a single Flutter module, the recommended approach is:

- Use **different entrypoints** (e.g. `main_profile`, `main_settings`) or
- Use **different routes** (e.g. `/profile`, `/settings`) under one entrypoint.

Then choose the entrypoint/route from Native:

- **Android**: `HybridFlutterActivity.withNewEngine(context, entrypoint: "main_profile", initialRoute: "/profile")`
- **iOS**: `HybridStack.shared.makeFlutterViewController(entrypoint: "main_profile", initialRoute: "/profile")`

If you truly have **multiple independent Flutter modules** (separate build outputs), those are different artifacts. You must integrate them separately in the host app. This library currently supports **one Flutter module per host**. A multi‑module registry (moduleId -> engineGroup/project) can be added if needed.

## ⚠️ Troubleshooting & Common Pitfalls

### Android: "ActivityNotFoundException"
- **Reason**: The plugin's Android manifest isn't being merged automatically, or the Activity isn't registered.
- **Fix**: Ensure your `settings.gradle` has `repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)` so the plugin is correctly resolved. If that fails, manually add `<activity android:name="com.aegislabs.hybrid_stack_manager.HybridFlutterActivity" ... />` to your host app's `AndroidManifest.xml`.

### iOS: "Sandbox: dartvm(...) deny(1) file-read-data"
- **Reason**: Xcode 15+ enables "User Script Sandboxing" by default, preventing Flutter build scripts from running.
- **Fix**: In Xcode, go to **Build Settings** -> **Build Options** -> **User Script Sandboxing** and set it to **NO**.

### iOS: "No such module 'hybrid_stack_manager'"
- **Reason**: CocoaPods setup might be incomplete or Xcode indexing is stale.
- **Fix**:
    1. Ensure `Podfile` is correctly set up with `install_all_flutter_pods`.
    2. Always open `.xcworkspace` instead of `.xcodeproj`.
    3. Run `pod deintegrate && pod install`.

### iOS: "Method cannot be declared public because its parameter uses an internal type"
- **Reason**: Pigeon generated Swift code (`Messages.g.swift`) uses `internal` structs by default, but your plugin API is `public`.
- **Fix**: Manually change `struct` to `public struct` and `protocol` to `public protocol` in `Messages.g.swift`.

### iOS: "Cannot find 'GeneratedPluginRegistrant'"
- **Reason**: Missing import for the generated plugin registry.
- **Fix**: Add `import FlutterPluginRegistrant` to your `AppDelegate.swift`.

