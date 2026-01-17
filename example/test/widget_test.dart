// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hybrid_stack_manager_example/main.dart';

void main() {
  testWidgets('Verify Hybrid Stack Example UI', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title is present.
    expect(find.text('Hybrid Stack Example'), findsOneWidget);

    // Verify that the "Push Native Page" button is present.
    expect(find.text('Push Native Page'), findsOneWidget);
  });
}
