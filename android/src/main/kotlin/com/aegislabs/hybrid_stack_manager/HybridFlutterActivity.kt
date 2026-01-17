package com.aegislabs.hybrid_stack_manager

import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * 通用的混合栈 Activity
 *
 * 使用 HybridStack 管理的 EngineGroup 来启动，实现低内存占用。
 */
open class HybridFlutterActivity : FlutterActivity() {

    companion object {
        private const val ARG_ENTRYPOINT = "arg_entrypoint"
        private const val ARG_INITIAL_ROUTE = "arg_initial_route"

        fun withNewEngine(context: Context, entrypoint: String = "main", initialRoute: String = "/"): Intent {
            return Intent(context, HybridFlutterActivity::class.java)
                .putExtra(ARG_ENTRYPOINT, entrypoint)
                .putExtra(ARG_INITIAL_ROUTE, initialRoute)
        }
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        val entrypoint = intent.getStringExtra(ARG_ENTRYPOINT) ?: "main"
        val initialRoute = intent.getStringExtra(ARG_INITIAL_ROUTE) ?: "/"
        
        return HybridStack.createEngine(context, entrypoint, initialRoute)
    }
}
