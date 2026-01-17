package com.aegislabs.hybrid_stack_manager

import android.app.Activity
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** HybridStackManagerPlugin */
class HybridStackManagerPlugin: FlutterPlugin, ActivityAware, NativeStackApi {
  private var activity: Activity? = null
  private var flutterStackApi: FlutterStackApi? = null

  // 静态单例回调，供宿主 App 注册
  companion object {
    var onPushNative: ((Activity, String, Map<String, Any>?) -> Unit)? = null
  }

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    // 注册 NativeStackApi (处理 Flutter -> Native 调用)
    NativeStackApi.setUp(flutterPluginBinding.binaryMessenger, this)
    // 初始化 FlutterStackApi (用于 Native -> Flutter 调用)
    flutterStackApi = FlutterStackApi(flutterPluginBinding.binaryMessenger)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    NativeStackApi.setUp(binding.binaryMessenger, null)
    flutterStackApi = null
  }

  // --- ActivityAware ---

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  // --- NativeStackApi Impl ---

  override fun pushNativeRoute(args: NativeRouteArgs) {
    val currentActivity = activity
    if (currentActivity == null) {
      Log.e("HybridStackManager", "Cannot push native route: No active activity")
      return
    }

    if (onPushNative != null) {
        @Suppress("UNCHECKED_CAST")
        onPushNative?.invoke(currentActivity, args.routeName ?: "", args.arguments as? Map<String, Any>)
    } else {
        Log.w("HybridStackManager", "onPushNative not implemented. Please set HybridStackManagerPlugin.onPushNative in your MainActivity.")
    }
  }

  override fun popNativeRoute() {
    activity?.finish()
  }
}
