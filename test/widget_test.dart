import 'package:appletech/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppleTech signs in and shows the store shell', (tester) async {
    await tester.pumpWidget(AppleTechApp(authService: LocalAuthService()));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'yourname@gmail.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byType(StoreShell), findsOneWidget);
    expect(find.byType(WelcomeAuthScreen), findsNothing);
  });
}
