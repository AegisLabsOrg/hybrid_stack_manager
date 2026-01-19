package com.aegislabs.aegis_hybrid_stack_manager

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * 混合栈核心管理器 (Android)
 *
 * 负责维护 FlutterEngineGroup 并管理 Engine 的创建。
 */
object HybridStack {
    private var engineGroup: FlutterEngineGroup? = null

    /**
     * 初始化混合栈
     * 通常在 Application.onCreate 中调用
     */
    fun init(context: Context) {
        if (engineGroup == null) {
            engineGroup = FlutterEngineGroup(context)
        }
    }

    /**
     * 创建或获取一个 Cached Engine
     * @param context Context
     * @param entrypoint Dart 入口函数名 (默认 "main")
     * @param initialRoute 初始路由
     * @return 配置好的 FlutterEngine
     */
    fun createEngine(context: Context, entrypoint: String = "main", initialRoute: String = "/"): FlutterEngine {
        val group = engineGroup ?: throw IllegalStateException("HybridStack.init(context) must be called first.")
        
        val dartEntry = DartExecutor.DartEntrypoint(
            io.flutter.FlutterInjector.instance().flutterLoader().findAppBundlePath(),
            entrypoint
        )

        return group.createAndRunEngine(context, dartEntry, initialRoute)
        // 注意：FlutterEngineGroup 自动创建的 Engine 会自动 Attach 到 Activity，
        // 并且在 connect 到 FlutterActivity 时会自动注册 Plugins (通过反射查找 GeneratedPluginRegistrant)
        // 所以 Android 侧通常不需要像 iOS 那样手动传 registerPlugins 回调，
        // 除非使用非常自定义的 Activity。
    }
}
