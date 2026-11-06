import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('Matsanam application root builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MatsanamApp());

    expect(find.byType(MatsanamApp), findsOneWidget);
  });
}
