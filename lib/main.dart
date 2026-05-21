import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:appletech/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_preview/device_preview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

part 'core/app_scope.dart';
part 'core/app_theme.dart';
part 'data/auth_service.dart';
part 'models/app_models.dart';
part 'data/apple_product_images.dart';
part 'data/product_catalog.dart';
part 'data/sample_products.dart';
part 'screens/auth/welcome_auth_screen.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = await createAuthService();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => AppleTechApp(authService: authService),
    ),
  );
}

Future<AuthService> createAuthService() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return FirebaseAuthService();
  } catch (e) {
    // If Firebase initialization fails (e.g., missing config), fall back to mock service.
    return LocalAuthService();
  }
}

class AppleTechApp extends StatefulWidget {
  const AppleTechApp({required this.authService, super.key});

  final AuthService authService;

  @override
  State<AppleTechApp> createState() => _AppleTechAppState();
}

class _AppleTechAppState extends State<AppleTechApp> {
  late final AppStore store;

  @override
  void initState() {
    super.initState();
    store = AppStore(authService: widget.authService);
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: store,
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          return MaterialApp(
            locale: store.locale ?? DevicePreview.locale(context),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: DevicePreview.appBuilder,
            debugShowCheckedModeBanner: false,
            title: 'AppleTech',
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: store.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: store.isAuthenticated
                ? const StoreShell()
                : const WelcomeAuthScreen(),
          );
        },
      ),
    );
  }
}
