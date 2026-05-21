import 'package:appletech/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppleTech signs in and shows the store shell', (tester) async {
    await tester.pumpWidget(AppleTechApp(authService: LocalAuthService()));

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.byType(StoreShell), findsOneWidget);
    expect(find.byType(WelcomeAuthScreen), findsNothing);
  });
}
