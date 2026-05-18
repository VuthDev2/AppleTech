import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

part 'core/app_scope.dart';
part 'models/app_models.dart';
part 'data/sample_products.dart';
part 'screens/auth/welcome_auth_screen.dart';
part 'widgets/app_text_field.dart';
part 'screens/store_shell.dart';
part 'screens/tabs/home_screen.dart';
part 'widgets/product_cards.dart';
part 'screens/tabs/explore_screen.dart';
part 'widgets/product_grid_card.dart';
part 'screens/product/product_detail_screen.dart';
part 'widgets/product_detail_widgets.dart';
part 'screens/tabs/wishlist_screen.dart';
part 'screens/tabs/bag_screen.dart';
part 'screens/tabs/profile_screen.dart';
part 'widgets/shared_widgets.dart';

void main() {
  runApp(const AppleTechApp());
}

class AppleTechApp extends StatefulWidget {
  const AppleTechApp({super.key});

  @override
  State<AppleTechApp> createState() => _AppleTechAppState();
}

class _AppleTechAppState extends State<AppleTechApp> {
  final AppStore store = AppStore();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: store,
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final scheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF0071E3),
            brightness: store.isDarkMode ? Brightness.dark : Brightness.light,
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'AppleTech',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: scheme,
              scaffoldBackgroundColor: store.isDarkMode
                  ? Colors.black
                  : const Color(0xFFF5F5F7),
              fontFamily: '.SF UI Display',
              bottomSheetTheme: const BottomSheetThemeData(
                showDragHandle: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
              ),
            ),
            home: store.isAuthenticated
                ? const StoreShell()
                : const WelcomeAuthScreen(),
          );
        },
      ),
    );
  }
}
