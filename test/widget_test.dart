import 'package:flutter_test/flutter_test.dart';
import 'package:funngro_assessment/main.dart';

void main() {
  testWidgets('FunngroAssessmentApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FunngroAssessmentApp());
    await tester.pumpAndSettle();

    // Verify header and navigation cards exist
    expect(find.text('Funngro Mobile Engineering'), findsOneWidget);
    expect(find.text('Part 1: Rewritten Earnings Screen'), findsOneWidget);
    expect(find.text('Part 2: Paginated Projects Screen'), findsOneWidget);
  });
}
