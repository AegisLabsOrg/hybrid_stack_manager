# Hybrid Stack Manager（中文）

这是一个面向 **Add‑to‑App** 的基础库，用于将 Flutter 模块嵌入现有原生 App，并通过 **FlutterEngineGroup** 管理多页面/多引擎，降低内存占用。

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

