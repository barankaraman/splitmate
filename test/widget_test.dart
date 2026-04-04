import 'package:flutter_test/flutter_test.dart';
import 'package:splitmate/app.dart';

void main() {
  testWidgets('App smoke test — renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SplitMateApp());
    // The Groups screen title should be present.
    expect(find.text('SplitMate'), findsAny);
  });
}
