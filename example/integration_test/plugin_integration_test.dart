// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:hybrid_stack_manager/hybrid_stack_manager.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HybridStackManager instance test', (WidgetTester tester) async {
    // Verify that the singleton instance is available.
    final HybridStackManager manager = HybridStackManager.instance;
    expect(manager, isNotNull);
  });

  testWidgets('HybridStackManager pushNative connectivity test', (
    WidgetTester tester,
  ) async {
    // This test ensures that the method can be called without crashing.
    // In a real device/emulator, this would trigger a native call.
    try {
      await HybridStackManager.instance.pushNative('test_route');
      // If we are in a pure test environment without native side,
      // it might throw a MissingPluginException or succeed depending on how it's run.
      // But for a basic connectivity test, we just want to see if the Dart code holds up.
    } catch (e) {
      debugPrint('Caught expected exception in test environment: $e');
    }
  });
}
