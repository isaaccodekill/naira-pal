import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cash_book/app.dart';

void main() {
  testWidgets('NairaPal app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: NairaPalApp()));

    // Wait for any async initialization
    await tester.pumpAndSettle();

    // Verify the app launches without crashing
    expect(find.text('Home'), findsOneWidget);
  });
}
