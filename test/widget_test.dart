import 'package:appletech/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppleTech signs in and shows the store shell', (tester) async {
    await tester.pumpWidget(const AppleTechApp());

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Premium hardware, configured your way.'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Bag'), findsOneWidget);
  });
}
