import 'package:flutter_test/flutter_test.dart';
import 'package:hybrid_stack_manager/hybrid_stack_manager.dart';
import 'package:hybrid_stack_manager/src/messages.g.dart';
import 'messages_test.g.dart';

// Mock Native Api 实现 (用于验证 Dart -> Native 的调用)
class MockNativeStackApi implements TestNativeStackApi {
  NativeRouteArgs? lastPushArgs;
  bool popCalled = false;

  @override
  void pushNativeRoute(NativeRouteArgs args) {
    lastPushArgs = args;
  }

  @override
  void popNativeRoute() {
    popCalled = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockApi = MockNativeStackApi();

  setUp(() {
    // 注入 Mock 实现，拦截 Pigeon 调用，模拟 Native 端接收
    TestNativeStackApi.setUp(mockApi);
    mockApi.lastPushArgs = null;
    mockApi.popCalled = false;
  });

  test('pushNative sends correct arguments to Native', () async {
    // Act
    await HybridStackManager.instance.pushNative(
      'test_route',
      arguments: {'id': 123},
    );

    // Assert
    expect(mockApi.lastPushArgs, isNotNull);
    expect(mockApi.lastPushArgs!.routeName, 'test_route');
    expect(mockApi.lastPushArgs!.arguments, {'id': 123});
  });

  test('popNative calls native pop', () async {
    // Act
    await HybridStackManager.instance.popNative();

    // Assert
    expect(mockApi.popCalled, isTrue);
  });

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
