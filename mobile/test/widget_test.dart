import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/widgets/common/guru_bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Matsanam application root builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MatsanamApp());

    expect(find.byType(MatsanamApp), findsOneWidget);
  });

  testWidgets('Guru bottom navigation follows the approved five-tab design', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          bottomNavigationBar: GuruBottomNavigation(currentIndex: 0),
        ),
      ),
    );

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Materi'), findsOneWidget);
    expect(find.text('Tugas'), findsOneWidget);
    expect(find.text('Absensi'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Nilai'), findsNothing);
  });
}
