import 'package:flutter_test/flutter_test.dart';
import 'package:cookie/main.dart';

void main() {
  testWidgets('Cookie app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CookieApp());
    expect(find.text('COOKIE'), findsOneWidget);
  });
}
