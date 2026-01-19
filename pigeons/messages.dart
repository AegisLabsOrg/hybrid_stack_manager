import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/aegislabs/hybrid_stack_manager/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.aegislabs.hybrid_stack_manager'),
    swiftOut: 'ios/Classes/Messages.g.swift',
    swiftOptions: SwiftOptions(),
  ),
)
// 数据模型：路由参数
class NativeRouteArgs {
  String? routeName;
  Map<String, Object?>? arguments;
}

// 接口：Flutter 调用 Native 的能力 (Host API)
@HostApi()
abstract class NativeStackApi {
  void pushNativeRoute(NativeRouteArgs args);
  void popNativeRoute();
  void registerFlutterRoutes(List<String> routes);
}

// 接口：Native 调用 Flutter 的能力 (Flutter API)
@FlutterApi()
abstract class FlutterStackApi {
  // Native 请求 Flutter push 一个新页面
  void pushFlutterRoute(String routeName, Map<String, Object?>? arguments);

  // Native 请求 Flutter pop 一个页面
  void popFlutterRoute();
}
