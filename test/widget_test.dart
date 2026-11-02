import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_joy_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ToddlerJoyApp());
    expect(find.text('✨ Toddler Joy ✨'), findsOneWidget);
  });
}
