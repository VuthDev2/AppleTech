part of '../../main.dart';

enum AuthView { signIn, signUp, forgotPassword, verifyCode }

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
  final codeControllers = List.generate(5, (_) => TextEditingController());
  AuthView view = AuthView.signIn;
  bool hidePassword = true;

  bool get isSignUp => view == AuthView.signUp;
  bool get isForgot => view == AuthView.forgotPassword;
  bool get isVerify => view == AuthView.verifyCode;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    for (final controller in codeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> submitAuth(AppStore store) async {
    if (!formKey.currentState!.validate() || store.isAuthLoading) return;

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
  }

  /// Google creates the account on first use — same flow for sign-in and sign-up.
  Future<void> submitGoogleAuth(AppStore store) async {
    if (store.isAuthLoading) return;

    final success = await store.signInWithGoogle();

    if (!success && mounted && store.authError != null) {
      showAuthError(store.authError);
    }
  }

  void submitAppleAuth() {
    showAuthError('Apple Sign In is not available yet.');
  }

  Future<void> requestPasswordReset(AppStore store) async {
    if (store.isAuthLoading) return;

    final email = emailController.text.trim();
    if (!email.contains('@')) {
      showAuthError('Enter a valid email.');
      return;
    }

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
                : 'Verification code sent. Use 12345 for demo.',
          ),
        ),
      );
    } else {
      showAuthError(store.authError);
    }
  }

  Future<void> verifyResetCode(AppStore store) async {
    if (store.isAuthLoading) return;

    final code = codeControllers.map((controller) => controller.text).join();
    final success = await store.verifyPasswordResetCode(
      email: emailController.text,
      code: code,
    );
    if (!mounted) return;

    if (success) {
      setState(() => view = AuthView.signIn);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code verified. You can sign in now.')),
      );
    } else {
      showAuthError(store.authError);
    }
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
            current == 'km' ? '🇰🇭' : current == 'zh' ? '🇨🇳' : '🇺🇸',
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
                vertical: AppSpacing.sm,
              ),
              children: [
                _buildAuthPreferencesBar(context, store),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Column(
                    children: [
                      // Professional logo: monochromatic and clean
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.black.withAlpha(8),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/appletech_logo.png',
                          width: 56,
                          height: 56,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'AppleTech',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
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
                      child: isForgot
                          ? ForgotPasswordPanel(
                              emailController: emailController,
                              onBack: () =>
                                  setState(() => view = AuthView.signIn),
                              onReset: () => requestPasswordReset(store),
                            )
                          : isVerify
                          ? VerifyCodePanel(
                              email: emailController.text,
                              controllers: codeControllers,
                              onBack: () =>
                                  setState(() => view = AuthView.forgotPassword),
                              onVerify: () => verifyResetCode(store),
                            )
                          : _buildAuthForm(store),
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

  Widget _buildAuthForm(AppStore store) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isSignUp 
              ? (AppLocalizations.of(context)?.createAccount ?? 'Create an account') 
              : (AppLocalizations.of(context)?.welcomeBack ?? 'Welcome back!'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 30),

        if (isSignUp) ...[
          ProfessionalTextField(
            controller: nameController,
            label: AppLocalizations.of(context)?.fullName ?? 'Full name',
            hintText: AppLocalizations.of(context)?.enterFullName ?? 'Enter your full name',
            validator: (value) =>
                value!.trim().isEmpty ? '' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        ProfessionalTextField(
          controller: emailController,
          label: isSignUp 
              ? (AppLocalizations.of(context)?.email ?? 'Email') 
              : (AppLocalizations.of(context)?.yourEmail ?? 'Your Email'),
          hintText: 'yourname@gmail.com',
          keyboardType: TextInputType.emailAddress,
          validator: (value) => value != null && value.contains('@')
              ? null
              : (AppLocalizations.of(context)?.enterEmail ?? 'Enter a valid email'),
        ),
        const SizedBox(height: AppSpacing.lg),

        ProfessionalTextField(
          controller: passwordController,
          label: AppLocalizations.of(context)?.password ?? 'Password',
          hintText: AppLocalizations.of(context)?.enterPassword ?? 'Enter your password',
          obscureText: hidePassword,

          suffixIcon: IconButton(
            onPressed: () => setState(() => hidePassword = !hidePassword),
            icon: Icon(
              hidePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.mediumGray,
            ),
          ),
          validator: (value) => value != null && value.length >= 6
              ? null
              : (AppLocalizations.of(context)?.useAtLeast6Digits ?? 'Use at least 6 digits'),
        ),
        const SizedBox(height: AppSpacing.md),

        if (!isSignUp)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => view = AuthView.forgotPassword),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: Text(
                AppLocalizations.of(context)?.forgotPassword ?? 'Forgot password?',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),

        FilledButton(
          onPressed: store.isAuthLoading ? null : () => submitAuth(store),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            backgroundColor: AppColors.black,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: store.isAuthLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
                : Text(
                    isSignUp ? (AppLocalizations.of(context)?.createAccountButton ?? 'Create Account') : (AppLocalizations.of(context)?.continueButton ?? 'Continue'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
        ),

        const SizedBox(height: AppSpacing.xl),

        Row(
          children: [
            const Expanded(
              child: Divider(color: AppColors.lightGray, thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                  AppLocalizations.of(context)?.orContinueWith ?? 'Or continue with',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ),
            const Expanded(
              child: Divider(color: AppColors.lightGray, thickness: 1),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        Row(
          children: [
            Expanded(
              child: SocialAuthButton(
                logo: const Icon(Icons.apple, size: 22, color: Colors.black),
                label: 'Apple',
                onPressed: store.isAuthLoading ? null : submitAppleAuth,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: SocialAuthButton(
                logo: Image.network(
                  'https://developers.google.com/identity/images/g-logo.png',
                  width: 22,
                  height: 22,
                  errorBuilder: (context, error, stackTrace) => const Text(
                    'G',
                    style: TextStyle(
                      color: Color(0xFF4285F4),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                label: 'Google',
                isLoading: store.isAuthLoading,
                onPressed: store.isAuthLoading ? null : () => submitGoogleAuth(store),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          children: [
            Text(
              isSignUp
                  ? (AppLocalizations.of(context)?.alreadyHaveAccount ?? 'Already have an account? ')
                  : (AppLocalizations.of(context)?.dontHaveAccount ?? "Don't have an account yet? "),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: () => setState(
                () => view = isSignUp ? AuthView.signIn : AuthView.signUp,
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                isSignUp ? (AppLocalizations.of(context)?.signIn ?? 'Sign In') : (AppLocalizations.of(context)?.signUp ?? 'Sign Up'),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Social auth button
class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    required this.logo,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final Widget logo;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGray, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          color: disabled ? AppColors.lightGray : AppColors.white,
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  logo,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Forgot password panel
class ForgotPasswordPanel extends StatelessWidget {
  const ForgotPasswordPanel({
    required this.emailController,
    required this.onBack,
    required this.onReset,
    super.key,
  });

  final TextEditingController emailController;
  final VoidCallback onBack;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.lightGray,
                foregroundColor: AppColors.black,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.resetPassword ?? 'Reset Password',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppLocalizations.of(context)?.resetInstructions ?? 'Enter your registered email to receive reset instructions',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        ProfessionalTextField(
          controller: emailController,
          label: AppLocalizations.of(context)?.emailAddress ?? 'Email Address',
          hintText: 'yourname@gmail.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline,
          validator: (value) => value != null && value.contains('@')
              ? null
              : (AppLocalizations.of(context)?.enterEmail ?? 'Enter a valid email'),
        ),
        const SizedBox(height: AppSpacing.xl),

        FilledButton(
          onPressed: onReset,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            backgroundColor: AppColors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: Text(AppLocalizations.of(context)?.submit ?? 'Submit'),
        ),
      ],
    );
  }
}

/// Verify code panel
class VerifyCodePanel extends StatefulWidget {
  const VerifyCodePanel({
    required this.email,
    required this.controllers,
    required this.onBack,
    required this.onVerify,
    super.key,
  });

  final String email;
  final List<TextEditingController> controllers;
  final VoidCallback onBack;
  final VoidCallback onVerify;

  @override
  State<VerifyCodePanel> createState()  => _VerifyCodePanelState();
}

class _VerifyCodePanelState extends State<VerifyCodePanel> {
  static const int resendSeconds = 60;

  Timer? resendTimer;
  int secondsRemaining = resendSeconds;

  bool get canResend => secondsRemaining == 0;

  @override
  void initState() {
    super.initState();
    startResendCountdown();
  }

  @override
  void dispose() {
    resendTimer?.cancel();
    super.dispose();
  }

  void startResendCountdown() {
    resendTimer?.cancel();
    setState(() => secondsRemaining = resendSeconds);
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final nextSeconds = secondsRemaining - 1;

      if (nextSeconds == 0) {
        timer.cancel();
      }

      setState(() => secondsRemaining = nextSeconds);
    });
  }

  void resendCode() {
    if (!canResend) return;
    startResendCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final maskedEmail = widget.email.contains('@')
        ? '${widget.email.split('@').first.characters.take(3).toString()}...@${widget.email.split('@').last}'
        : 'your email';
    final resendText = canResend
        ? (AppLocalizations.of(context)?.resendCode ?? "Didn't receive the code? Resend")
        : AppLocalizations.of(context)!.resendInSeconds(secondsRemaining);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.lightGray,
                foregroundColor: AppColors.black,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.verifyEmail ?? 'Verify Email',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppLocalizations.of(context)?.checkInbox ?? 'Check your inbox for verification code',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        Text(
          AppLocalizations.of(context)!.verificationCodeSent(maskedEmail),
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),

        Row(
          children: [
            for (int i = 0; i < widget.controllers.length; i++) ...[
              Expanded(
                child: CodeInputBox(
                  controller: widget.controllers[i],
                  onChanged: (value) {
                    if (value.isNotEmpty && i < widget.controllers.length - 1) {
                      FocusScope.of(context).nextFocus();
                    }
                  },
                ),
              ),
              if (i != widget.controllers.length - 1)
                const SizedBox(width: AppSpacing.md),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        FilledButton(
          onPressed: widget.onVerify,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            backgroundColor: AppColors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: const Text('Verify Code'),
        ),
        const SizedBox(height: AppSpacing.lg),

        TextButton(
          onPressed: canResend ? resendCode : null,
          child: Text(
            resendText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: canResend ? AppColors.black : AppColors.mediumGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Code input box for verification
class CodeInputBox extends StatelessWidget {
  const CodeInputBox({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLength: 1,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: AppColors.lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.lightGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.lightGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.black, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }
}
