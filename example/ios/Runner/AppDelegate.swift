import Flutter
import UIKit
import hybrid_stack_manager

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 1. 初始化混合栈
    HybridStack.shared.configure { registry in
        GeneratedPluginRegistrant.register(with: registry)
    }

    // 2. 注册 Native 跳转逻辑
    HybridStackManagerPlugin.onPushNative = { [weak self] routeName, args in
        print("Flutter requested push: \(routeName), args: \(String(describing: args))")
        
        guard let self = self,
              let rootVC = self.window?.rootViewController else { return }
        
        let alert = UIAlertController(title: "Native Received", message: "Push to: \(routeName)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // 演示：打开一个新的 Flutter VC
            let nextVC = HybridStack.shared.makeFlutterViewController(initialRoute: "/sub_page")
            nextVC.modalPresentationStyle = .fullScreen
            
            // 简单处理：如果是 Nav 就 push，否则 present
            if let nav = rootVC as? UINavigationController {
                nav.pushViewController(nextVC, animated: true)
            } else {
                rootVC.present(nextVC, animated: true)
            }
        }))
        
        rootVC.present(alert, animated: true)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

