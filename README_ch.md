# Hybrid Stack Manager（中文）

让嵌入 Flutter 像接入 **WebView** 一样简单，但拥有 **原生级的性能**。

这是一个面向 **Add‑to‑App** 的基础库，用于将 Flutter 模块嵌入现有原生 App，并通过 **FlutterEngineGroup** 管理多页面/多引擎，降低内存占用。

![](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

## 为什么要用这个？

传统方式下，在现有 App 中混编 Flutter 往往很重：要么用一个巨大的单引擎（页面栈难管理），要么用多个普通引擎（内存爆炸）。

**Hybrid Stack Manager** 改变了这一切：

1.  **极轻量**：新开一个 Flutter 页面仅消耗 **~180kB** 内存（传统方式约 19MB）。
2.  **秒开**：通过复用 AOT 资源，启动速度是毫秒级的。
3.  **极简 API**：调用方式设计得就像打开原生的 ViewController 或 Activity 一样自然。

| 目标 | 能力 | 说明 | 性能基准 (参考) |
| --- | --- | --- | --- |
| 原生接入 Flutter | 引擎组管理 | 使用 `FlutterEngineGroup` 复用引擎 | 内存消耗从 ~19MB/引擎 降至 **~180kB/引擎** |
| 启动性能 | 快速热启动 | 复用已加载的 AOT 代码和资源 | 启动速度提升约 **10x** |
| 混合导航 | 双向跳转 | Flutter ↔ Native 可互相跳转 | 保持原生主导航栈，体验丝滑 |
| 路由自由 | 不绑定框架 | 兼容 `Navigator` / `GoRouter` | 零代码侵入现有路由库 |
| 通信安全 | Pigeon | 类型安全的跨端调用 | 性能优于普通 MethodChannel，且更安全 |

## 特性

- 🚀 **类型安全通信**：基于 Pigeon，避免字符串通道错误
- 🔀 **混合导航**：Native 与 Flutter 可相互跳转
- 🧠 **引擎管理**：使用 `FlutterEngineGroup` 复用引擎
- 🧩 **路由无关**：兼容 `Navigator` / `go_router` / `auto_route`

## ⚖️ 与其他库的对比

| 特性 | **Hybrid Stack Manager** | **Flutter Boost** | **Thrio** | **官方原生多引擎** |
| :--- | :--- | :--- | :--- | :--- |
| **架构模式** | `FlutterEngineGroup` (多引擎复用) | 单引擎 (Single Engine) | 单引擎 (Single Engine) | 朴素多引擎 (Multi-Engine) |
| **内存占用** | ✅ 低 (~180kB/页面) | ✅ 低 (共享实例) | ✅ 低 (共享实例) | ❌ 高 (~19MB/页面) |
| **侵入性** | ✅ **无侵入** (标准 API) | ❌ 强侵入 (魔改引擎/Hook) | ⚠️ 较复杂 | ✅ 无侵入 |
| **状态隔离** | ✅ **高** (独立 Isolate) | ❌ 无 (共享 Isolate) | ❌ 无 (共享 Isolate) | ✅ 高 |
| **接入复杂度** | 🟢 **简单** (类 WebView) | 🔴 高 | 🔴 高 | 🟡 中等 |
| **路由支持** | ✅ **任意** (GoRouter 等) | ⚠️ 需使用特定路由 | ⚠️ 需使用特定路由 | ✅ 任意 |

**为什么选择 Hybrid Stack Manager?**
- 如果你需要**真正的页面隔离**（一个页面的 Dart 异常不会导致所有 Flutter 页面崩溃）。
- 如果你想使用**标准的 Flutter 路由栈**（如 GoRouter, AutoRoute），而不是被迫学习一套新的路由系统。
- 如果你追求**最简单的 Add-to-App 接入体验**，不想处理复杂的单引擎生命周期管理。

## Add‑to‑App 接入清单（简版）

### Android

1. 在原生工程中依赖 Flutter module（`settings.gradle` + `implementation project(...)`）。
2. 在 `Application.onCreate()` 中初始化：`HybridStack.init(this)`。
3. 容器策略：
   - 使用 `HybridFlutterActivity.withNewEngine(...)` 打开 Flutter 页面；或
   - 使用自定义 `FlutterActivity/FlutterFragment`，调用 `HybridStack.createEngine(...)`。
4. 注册桥接：设置 `HybridStackManagerPlugin.onPushNative` 处理 Flutter → Native 跳转。

### iOS

1. 在原生工程中依赖 Flutter module（CocoaPods 或 Xcode 设置）。
2. 在 `AppDelegate` 中初始化：
   - `HybridStack.shared.configure { GeneratedPluginRegistrant.register(with: $0) }`
3. 容器策略：
   - 使用 `HybridStack.shared.makeFlutterViewController(...)` 打开 Flutter 页面。
4. 注册桥接：设置 `HybridStackManagerPlugin.onPushNative` 处理 Flutter → Native 跳转。

## 原生如何选择 Flutter 页面

一个 Flutter 模块包含多个页面时，原生可通过 **initialRoute** 或 **entrypoint** 指定目标页面。

- **Android**：
  `HybridFlutterActivity.withNewEngine(context, entrypoint: "main_profile", initialRoute: "/profile")`
- **iOS**：
  `HybridStack.shared.makeFlutterViewController(entrypoint: "main_profile", initialRoute: "/profile")`

## 架构说明

该库仅提供通信与容器能力，不强绑定任何路由框架。你可以自由选择 `Navigator`、`go_router` 或其他方案。

## 性能表现

基于 `FlutterEngineGroup` 的实现，与传统多引擎方案对比：

- **内存效率**：后续引擎仅消耗约 **180kB**（传统方案约 19MB+），允许在 App 中创建大量 Flutter 容器而无内存压力。
- **启动时间**：由于共享了资源和代码段，新引擎的启动耗时降至毫秒级，实现无感加载。
- **渲染一致性**：所有引擎实例共享光栅线程和 I/O 线程，确保 UI 体验的一致性。

## ⚠️ 常见问题排查 (Troubleshooting)

### Android: "ActivityNotFoundException"
- **原因**：插件的 `AndroidManifest.xml` 没有被正确合并，或者 Activity 没有注册。
- **解决**：确保你的 `settings.gradle` 设置了 `repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)` 以便能够解析插件。如果依然报错，请在宿主 App 的 `AndroidManifest.xml` 中手动添加 `<activity android:name="com.aegislabs.aegis_hybrid_stack_manager.HybridFlutterActivity" ... />`。

### iOS: "Sandbox: dartvm(...) deny(1) file-read-data"
- **原因**：Xcode 15+ 默认开启了 "User Script Sandboxing"，阻止了 Flutter 构建脚本访问文件。
- **解决**：在 Xcode 中，找到 **Build Settings** -> **Build Options** -> **User Script Sandboxing**，将其设为 **NO**。

### iOS: "No such module 'hybrid_stack_manager'"
- **原因**：CocoaPods 配置不完整，或者 Xcode 索引过期。
- **解决**：
    1. 确保 `Podfile` 中正确使用了 `install_all_flutter_pods`。
    2. **必须** 使用 `.xcworkspace` 打开项目，而不是 `.xcodeproj`。
    3. 尝试运行 `pod deintegrate && pod install`。

### iOS: "Method cannot be declared public because its parameter uses an internal type"
- **原因**：Pigeon 生成的 Swift 代码 (`Messages.g.swift`) 默认也是 `internal` 的，但插件公开 API 需要暴露这些类型。
- **解决**：手动修改 `Messages.g.swift`，将报错的 `struct` 改为 `public struct`，`protocol` 改为 `public protocol`。

### iOS: "Cannot find 'GeneratedPluginRegistrant'"
- **原因**：缺少自动生成的插件注册类的引用。
- **解决**：在 `AppDelegate.swift` 中添加 `import FlutterPluginRegistrant`。

