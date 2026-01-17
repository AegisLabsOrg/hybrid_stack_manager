import Flutter
import UIKit

/// 混合栈核心管理器 (iOS)
///
/// 负责维护 FlutterEngineGroup 并分发新的 FlutterViewController。
public class HybridStack: NSObject {
    public static let shared = HybridStack()
    
    // 引擎组，用于低内存消耗地创建多引擎
    private var engineGroup: FlutterEngineGroup?
    
    // Plugin 注册回调 (由宿主 AppDelegate 传入 GeneratedPluginRegistrant.register)
    private var pluginRegistrantCallback: ((FlutterPluginRegistry) -> Void)?
    
    private override init() {
        super.init()
    }
    
    /// 初始化混合栈
    /// - Parameters:
    ///   - engineGroup: 宿主 App 创建的 engineGroup (可选，若不传则内部创建)
    ///   - registerPlugins: **必须传入** `GeneratedPluginRegistrant.register`，否则新页面无法使用插件
    public func configure(engineGroup: FlutterEngineGroup? = nil,
                          registerPlugins: @escaping (FlutterPluginRegistry) -> Void) {
        self.engineGroup = engineGroup ?? FlutterEngineGroup(name: "hybrid_stack_group", project: nil)
        self.pluginRegistrantCallback = registerPlugins
    }
    
    /// 创建一个新的 FlutterViewController (使用 EngineGroup)
    /// - Parameters:
    ///   - entrypoint: Dart 入口函数名 (默认 "main")
    ///   - initialRoute: 初始路由 (如 "/profile")
    ///   - arguments: 传递给 Dart 的启动参数 (需要在 Dart 端通过 ui.window.defaultRouteName 解析，或等引擎启动后通过 Channel 发送)
    /// - Returns: 配置好的 FlutterViewController
    public func makeFlutterViewController(entrypoint: String = "main",
                                        initialRoute: String = "/",
                                        arguments: [String: Any]? = nil) -> FlutterViewController {
        guard let engineGroup = engineGroup else {
            fatalError("HybridStack.shared.configure() must be called before creating view controllers.")
        }
        
        let newEngine = engineGroup.makeEngine(withEntrypoint: entrypoint, libraryURI: nil, initialRoute: initialRoute)
        
        // 1. 注册所有插件 (包括 HybridStackManagerPlugin)
        pluginRegistrantCallback?(newEngine)
        
        // 2. 创建 VC
        let hostVC = HybridFlutterViewController(engine: newEngine, nibName: nil, bundle: nil)
        
        return hostVC
    }
}

/// 自定义 FlutterViewController，可以在这里处理一些通用的生命周期或改写
public class HybridFlutterViewController: FlutterViewController {
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 可以在这里通知 Dart 页面可见
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 可以在这里通知 Dart 页面消失
    }
    
    deinit {
        print("HybridFlutterViewController deinit")
        // EngineGroup 创建的 Engine 默认会随 VC 释放，无需手动 destroy
    }
}
