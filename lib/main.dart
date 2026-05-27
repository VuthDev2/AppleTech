import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:appletech/l10n/app_localizations.dart';
import 'package:appletech/core/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:appletech/screens/admin/admin_shell.dart';
import 'package:device_preview/device_preview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

part 'widgets/user_notification_sheet.dart';
part 'core/app_scope.dart';
part 'core/app_theme.dart';
part 'data/auth_service.dart';
part 'data/firestore_service.dart';
part 'data/profile_storage_service.dart';
part 'data/photo_picker_helper.dart';
part 'models/app_models.dart';
part 'data/apple_product_images.dart';
part 'data/product_catalog.dart';
part 'data/product_catalog_expansion.dart';
part 'data/sample_products.dart';
part 'screens/auth/auth_components.dart';
part 'screens/auth/forgot-pw.dart';
part 'screens/auth/login.dart';
part 'screens/auth/reset-pw.dart';
part 'screens/auth/signup.dart';
part 'screens/auth/verify.dart';
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
part 'utils/responsive.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final (authService, firestoreService, profileStorage) = await _createServices();

  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (context) => AppleTechApp(
        authService: authService,
        firestoreService: firestoreService,
        profileStorage: profileStorage,
      ),
    ),
  );
}

/// When true, user data goes through the Express API (`auth-backend`).
/// When false (default), the app writes directly to Firestore using security rules.
const bool kUseBackendApi = bool.fromEnvironment(
  'USE_BACKEND_API',
  defaultValue: false,
);

/// Profile photos: `firestore` (default, free on Spark), `r2`, or `firebase`.
const String kProfileStorage = String.fromEnvironment(
  'PROFILE_STORAGE',
  defaultValue: 'firestore',
);

Future<(
  AuthService,
  UserDataRepository?,
  ProfilePhotoStorage?,
)> _createServices() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final UserDataRepository dataRepository = kUseBackendApi
        ? FirestoreService()
        : DirectFirestoreService();
    final ProfilePhotoStorage profileStorage = createProfilePhotoStorage();
    return (
      FirebaseAuthService(),
      dataRepository,
      profileStorage,
    );
  } catch (e) {
    debugPrint('Firebase init failed, using local auth: $e');
    return (LocalAuthService(), null, null);
  }
}

class AppleTechApp extends StatefulWidget {
  const AppleTechApp({
    required this.authService,
    this.firestoreService,
    this.profileStorage,
    super.key,
  });

  final AuthService authService;
  final UserDataRepository? firestoreService;
  final ProfilePhotoStorage? profileStorage;

  @override
  State<AppleTechApp> createState() => _AppleTechAppState();
}

class _AppleTechAppState extends State<AppleTechApp> {
  late final AppStore store;

  @override
  void initState() {
    super.initState();
    store = AppStore(
      authService: widget.authService,
      firestoreService: widget.firestoreService,
      profileStorage: widget.profileStorage,
    );
    // Restore persisted session from Firestore on cold start
    store.initialize();
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
                ? const _AuthGate() // Use AuthGate to determine view based on role
                : const WelcomeAuthScreen(),
          );
        },
      ),
    );
  }
}

/// A widget that acts as an authentication gate, redirecting users
/// based on their role (admin or regular user) after successful login.
class _AuthGate extends StatelessWidget {
  const _AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final user = store.user;

    if (user == null) {
      // This case should ideally not be reached if store.isAuthenticated is true,
      // but as a fallback, redirect to login.
      return const WelcomeAuthScreen();
    }

    // Redirect to AdminShell if the user has the admin role, 
    // otherwise show the regular StoreShell.
    if (user.isAdmin) {
      return const AdminShell();
    }
    
    return const StoreShell();
  }
}
