part of '../../main.dart';

enum AuthView { signIn, signUp, forgotPassword, verifyCode, resetPassword }

enum AuthAction { credentials, google, resetRequest, verifyCode, newPassword }

class WelcomeAuthScreen extends StatefulWidget {
  const WelcomeAuthScreen({super.key});

  @override
  State<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends State<WelcomeAuthScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: 'Saravuth ');
  final emailController = TextEditingController(text: '');
  final passwordController = TextEditingController(text: '');
  final confirmPasswordController = TextEditingController(text: '');
  final codeControllers = List.generate(6, (_) => TextEditingController());
  AuthView view = AuthView.signIn;
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  String? resetCode;
  AuthAction? loadingAction;

  bool get isSignUp => view == AuthView.signUp;
  bool get isForgot => view == AuthView.forgotPassword;
  bool get isVerify => view == AuthView.verifyCode;
  bool get isResetPassword => view == AuthView.resetPassword;
  bool get isBusy => loadingAction != null;

  bool isLoading(AuthAction action) => loadingAction == action;

  Future<void> runAuthAction(
    AuthAction action,
    Future<void> Function() callback,
  ) async {
    if (isBusy) return;
    setState(() => loadingAction = action);
    try {
      await callback();
    } finally {
      if (mounted) {
        setState(() => loadingAction = null);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final link = Uri.base;
    final mode = link.queryParameters['mode'];
    final oobCode = link.queryParameters['oobCode'];
    final email = link.queryParameters['email'];

    if (mode == 'resetPassword' && oobCode != null && oobCode.isNotEmpty) {
      resetCode = oobCode;
      emailController.text = email ?? '';
      view = AuthView.resetPassword;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    for (final controller in codeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> submitAuth(AppStore store) async {
    if (!formKey.currentState!.validate()) return;

    await runAuthAction(AuthAction.credentials, () async {
      final success = isSignUp
          ? await store.signUp(
              name: nameController.text,
              email: emailController.text,
              password: passwordController.text,
            )
          : await store.signIn(
              email: emailController.text,
              password: passwordController.text,
            );

      if (!success && mounted) {
        showAuthError(store.authError);
      }
    });
  }

  /// Google creates the account on first use — same flow for sign-in and sign-up.
  Future<void> submitGoogleAuth(AppStore store) async {
    await runAuthAction(AuthAction.google, () async {
      final success = await store.signInWithGoogle();

      if (!success && mounted && store.authError != null) {
        showAuthError(store.authError);
      }
    });
  }

  void submitAppleAuth() {
    showAuthError('Apple Sign In is not available yet.');
  }

  Future<void> requestPasswordReset(AppStore store) async {
    final email = emailController.text.trim();
    if (!email.contains('@')) {
      showAuthError('Enter a valid email.');
      return;
    }

    await runAuthAction(AuthAction.resetRequest, () async {
      final success = await store.requestPasswordReset(email: email);
      if (!mounted) return;

      if (success) {
        if (store.authService is FirebaseAuthService) {
          setState(() => view = AuthView.signIn);
        } else {
          setState(() => view = AuthView.verifyCode);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              store.authService is FirebaseAuthService
                  ? 'Password reset email sent.'
                  : 'Verification code sent. Use 123456 for demo.',
            ),
          ),
        );
      } else {
        showAuthError(store.authError);
      }
    });
  }

  Future<void> verifyResetCode(AppStore store) async {
    final code = codeControllers.map((controller) => controller.text).join();
    await runAuthAction(AuthAction.verifyCode, () async {
      final success = await store.verifyPasswordResetCode(
        email: emailController.text,
        code: code,
      );
      if (!mounted) return;

      if (success) {
        setState(() {
          resetCode = code;
          passwordController.clear();
          confirmPasswordController.clear();
          view = AuthView.resetPassword;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.codeVerifiedNewPassword ?? 'Code verified. Create a new password.'),
          ),
        );
      } else {
        showAuthError(store.authError);
      }
    });
  }

  Future<void> submitNewPassword(AppStore store) async {
    if (!formKey.currentState!.validate()) return;
    final code = resetCode;
    if (code == null || code.isEmpty) {
      showAuthError('Reset code is missing. Request a new password reset.');
      return;
    }

    await runAuthAction(AuthAction.newPassword, () async {
      final success = await store.confirmPasswordReset(
        email: emailController.text,
        code: code,
        newPassword: passwordController.text,
      );
      if (!mounted) return;

      if (success) {
        setState(() {
          resetCode = null;
          passwordController.clear();
          confirmPasswordController.clear();
          for (final controller in codeControllers) {
            controller.clear();
          }
          view = AuthView.signIn;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.passwordUpdatedSignIn ?? 'Password updated. You can sign in now.'),
          ),
        );
      } else {
        showAuthError(store.authError);
      }
    });
  }

  void showAuthError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message ?? 'Authentication failed.')),
    );
  }

  Widget _buildAuthPreferencesBar(BuildContext context, AppStore store) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chipBg = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.lightGray.withAlpha(100);
    final current = store.locale?.languageCode ?? 'en';

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _StoreHeaderIconButton(
          onPressed: store.toggleTheme,
          backgroundColor: chipBg,
          icon: Icon(
            isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _StoreHeaderIconButton(
          onPressed: () {
            if (current == 'en') {
              store.setLocale(const Locale('km'));
            } else if (current == 'km') {
              store.setLocale(const Locale('zh'));
            } else {
              store.setLocale(const Locale('en'));
            }
          },
          backgroundColor: chipBg,
          icon: Text(
            current == 'km'
                ? '🇰🇭'
                : current == 'zh'
                    ? '🇨🇳'
                    : '🇺🇸',
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: AppSpacing.xxl,
              ),
              children: [
                _buildAuthPreferencesBar(context, store),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Hero(
                    tag: 'storeLogo',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const StoreBrandMark(height: 64, compact: true),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'AppleTech',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Form(
                  key: formKey,
                  child: AnimatedSwitcher(
                    duration: AppAnimations.normal,
                    switchInCurve: AppAnimations.easeOut,
                    switchOutCurve: AppAnimations.easeIn,
                    child: KeyedSubtree(
                      key: ValueKey(view),
                      child: _buildCurrentAuthPage(store),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentAuthPage(AppStore store) {
    if (isForgot) {
      return ForgotPasswordPanel(
        emailController: emailController,
        isLoading: isLoading(AuthAction.resetRequest),
        onBack: () => setState(() => view = AuthView.signIn),
        onReset: () => requestPasswordReset(store),
      );
    }

    if (isVerify) {
      return VerifyCodePanel(
        email: emailController.text,
        controllers: codeControllers,
        isLoading: isLoading(AuthAction.verifyCode),
        onBack: () => setState(() => view = AuthView.forgotPassword),
        onVerify: () => verifyResetCode(store),
      );
    }

    if (isResetPassword) {
      return ResetPasswordPanel(
        emailController: emailController,
        passwordController: passwordController,
        confirmPasswordController: confirmPasswordController,
        hidePassword: hidePassword,
        hideConfirmPassword: hideConfirmPassword,
        isLoading: isLoading(AuthAction.newPassword),
        onTogglePassword: () => setState(() => hidePassword = !hidePassword),
        onToggleConfirmPassword: () =>
            setState(() => hideConfirmPassword = !hideConfirmPassword),
        onBack: () => setState(() => view = AuthView.signIn),
        onSubmit: () => submitNewPassword(store),
      );
    }

    if (isSignUp) {
      return SignUpPanel(
        nameController: nameController,
        emailController: emailController,
        passwordController: passwordController,
        hidePassword: hidePassword,
        isBusy: isBusy,
        isCredentialsLoading: isLoading(AuthAction.credentials),
        isGoogleLoading: isLoading(AuthAction.google),
        onTogglePassword: () => setState(() => hidePassword = !hidePassword),
        onSubmit: () => submitAuth(store),
        onAppleAuth: submitAppleAuth,
        onGoogleAuth: () => submitGoogleAuth(store),
        onSignIn: () => setState(() => view = AuthView.signIn),
      );
    }

    return LoginPanel(
      emailController: emailController,
      passwordController: passwordController,
      hidePassword: hidePassword,
      isBusy: isBusy,
      isCredentialsLoading: isLoading(AuthAction.credentials),
      isGoogleLoading: isLoading(AuthAction.google),
      onTogglePassword: () => setState(() => hidePassword = !hidePassword),
      onSubmit: () => submitAuth(store),
      onForgotPassword: () => setState(() => view = AuthView.forgotPassword),
      onAppleAuth: submitAppleAuth,
      onGoogleAuth: () => submitGoogleAuth(store),
      onSignUp: () => setState(() => view = AuthView.signUp),
    );
  }
} 
