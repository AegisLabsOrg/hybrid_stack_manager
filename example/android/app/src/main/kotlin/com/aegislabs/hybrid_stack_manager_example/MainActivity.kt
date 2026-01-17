package com.aegislabs.hybrid_stack_manager_example

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import com.aegislabs.hybrid_stack_manager.HybridFlutterActivity
import com.aegislabs.hybrid_stack_manager.HybridStack
import com.aegislabs.hybrid_stack_manager.HybridStackManagerPlugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 1. 初始化 (通常在 Application 中做，这里为了演示简化)
        HybridStack.init(applicationContext)

        // 2. 监听 Flutter 的跳转请求
        HybridStackManagerPlugin.onPushNative = { activity, routeName, args ->
            Toast.makeText(activity, "Flutter requested: $routeName", Toast.LENGTH_SHORT).show()
            
            if (routeName == "native_settings_page") {
                // 这里可以跳转原生 Activity，但为了演示 EngineGroup，我们再跳回一个新的 FLUTTER engine
                // 模拟 "Flutter A -> Native -> Flutter B" 的流程
                val intent = HybridFlutterActivity.withNewEngine(activity, initialRoute = "/settings")
                activity.startActivity(intent)
            }
        }
    }
}

