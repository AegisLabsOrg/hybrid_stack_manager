import 'package:flutter/foundation.dart';
import 'src/messages.g.dart';

export 'src/messages.g.dart' show NativeRouteArgs;

/// 混合栈管理器
///
/// 负责处理 Flutter 与 Native 之间的路由跳转。
class HybridStackManager implements FlutterStackApi {
  static final HybridStackManager _instance = HybridStackManager._internal();
  static HybridStackManager get instance => _instance;

  final NativeStackApi _nativeApi = NativeStackApi();

  // 外部可以注册这个回调来处理 Native -> Flutter 的路由请求
  void Function(String routeName, Map<String, Object?>? arguments)?
  _onPushFlutterRoute;
  void Function()? _onPopFlutterRoute;

  HybridStackManager._internal() {
    // 注册 FlutterStackApi 以便接收来自 Native 的调用
    FlutterStackApi.setUp(this);
  }

  /// 设置路由回调，通常在 main.dart 或者 Router 初始化时调用
  void setDelegate({
    required void Function(String routeName, Map<String, Object?>? arguments)
    onPush,
    required void Function() onPop,
  }) {
    _onPushFlutterRoute = onPush;
    _onPopFlutterRoute = onPop;
  }

  // --- Native 调用的方法 (FlutterStackApi 实现) ---

  @override
  void pushFlutterRoute(String routeName, Map<String, Object?>? arguments) {
    debugPrint(
      'HybridStackManager: Native requested pushFlutterRoute: $routeName, args: $arguments',
    );
    if (_onPushFlutterRoute != null) {
      _onPushFlutterRoute!(routeName, arguments);
    } else {
      debugPrint(
        'HybridStackManager: No delegate registered to handle pushFlutterRoute.',
      );
    }
  }

  @override
  void popFlutterRoute() {
    debugPrint('HybridStackManager: Native requested popFlutterRoute');
    if (_onPopFlutterRoute != null) {
      _onPopFlutterRoute!();
    } else {
      debugPrint(
        'HybridStackManager: No delegate registered to handle popFlutterRoute.',
      );
    }
  }

  // --- Flutter 调用的方法 (调用 NativeStackApi) ---

  /// 请求 Native 打开一个新的页面（可以是 Native 页面，也可以是新的 Flutter 容器）
  /// [routeName] 目标路由名称
  /// [arguments] 参数
  Future<void> pushNative(
    String routeName, {
    Map<String, Object?>? arguments,
  }) async {
    final args = NativeRouteArgs(routeName: routeName, arguments: arguments);
    _nativeApi.pushNativeRoute(args);
  }

  /// 请求 Native 关闭当前所有的 Flutter 容器（即关闭当前的 Activity/ViewController）
  Future<void> popNative() async {
    _nativeApi.popNativeRoute();
  }
}
