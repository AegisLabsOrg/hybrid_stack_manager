import 'package:flutter_test/flutter_test.dart';
import 'package:aegis_hybrid_stack_manager/aegis_hybrid_stack_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Native calling pushFlutterRoute triggers delegate', () async {
    String? capturedRoute;
    Map<String, Object?>? capturedArgs;

    // 1. 设置 Delegate 监听 Native 消息
    HybridStackManager.instance.setDelegate(
      onPush: (route, args) {
        capturedRoute = route;
        capturedArgs = args;
      },
      onPop: () {},
    );

    // 2. 模拟 Native 发送消息 (在真实场景中是 NativeStackApi -> FlutterStackApi)
    // 这里我们直接调用实现了 FlutterStackApi 的类方法来模拟
    HybridStackManager.instance.pushFlutterRoute('native_pushed', {
      'data': 'hello',
    });

    // 3. 验证 Delegate 被调用
    expect(capturedRoute, 'native_pushed');
    expect(capturedArgs, {'data': 'hello'});
  });

  test('Native calling popFlutterRoute triggers delegate', () async {
    bool popTriggered = false;

    HybridStackManager.instance.setDelegate(
      onPush: (_, __) {},
      onPop: () {
        popTriggered = true;
      },
    );

    HybridStackManager.instance.popFlutterRoute();

    expect(popTriggered, isTrue);
  });
}
