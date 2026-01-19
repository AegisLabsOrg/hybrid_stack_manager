import Flutter
import UIKit

public class HybridStackManagerPlugin: NSObject, FlutterPlugin, NativeStackApi {
    private var flutterApi: FlutterStackApi?
    
    // 静态回调，供宿主 App 实现具体的跳转逻辑
    public static var onPushNative: ((String, [String: Any]?) -> Void)?
    public static var onPopNative: (() -> Void)?
    public static var onRegisterFlutterRoutes: (([String]) -> Void)?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = HybridStackManagerPlugin()
        // 注册 NativeApi (Flutter -> Native)
        NativeStackApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
        // 初始化 FlutterApi (Native -> Flutter)
        instance.flutterApi = FlutterStackApi(binaryMessenger: registrar.messenger())
    }

    // --- NativeStackApi Implementation ---

    public func pushNativeRoute(args: NativeRouteArgs) throws {
        if let onPush = HybridStackManagerPlugin.onPushNative {
            onPush(args.routeName ?? "", args.arguments as? [String: Any])
        } else {
            print("HybridStackManager: onPushNative not implemented")
        }
    }

    public func popNativeRoute() throws {
        if let onPop = HybridStackManagerPlugin.onPopNative {
            onPop()
        } else {
            // 默认实现：尝试 Pop 或 Dismiss
            DispatchQueue.main.async {
                // 尝试获取当前顶层控制器并关闭
                if let topController = self.getTopMostViewController() {
                    if let nav = topController.navigationController {
                        nav.popViewController(animated: true)
                    } else {
                        topController.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }

    public func registerFlutterRoutes(routes: [String]) throws {
        if let onRegister = HybridStackManagerPlugin.onRegisterFlutterRoutes {
            onRegister(routes)
        } else {
            print("HybridStackManager: onRegisterFlutterRoutes not implemented")
        }
    }
    
    // 辅助方法：获取最顶层 VC
    private func getTopMostViewController() -> UIViewController? {
        // 在新版 iOS 中 keyWindow 可能被废弃，需要从 scenes 中获取
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
            
        var topController = keyWindow?.rootViewController
        
        while let presented = topController?.presentedViewController {
            topController = presented
        }
        return topController
    }
}
