import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_manager/main.dart';

void main() {
  testWidgets('WiFi Manager app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WiFiManagerApp());

    // Verify that the app title is displayed
    expect(find.text('WiFi Manager'), findsOneWidget);
  });
}
