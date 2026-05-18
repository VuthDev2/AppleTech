part of '../../main.dart';

enum AuthView { signIn, signUp, forgotPassword, verifyCode }

const Color authBlue = Color(0xFF6693E7);
const Color authInk = Color(0xFF1F1F1F);
const Color authMuted = Color(0xFF8D8D8D);
const Color authLine = Color(0xFFE1E1E1);

class WelcomeAuthScreen extends StatefulWidget {
  const WelcomeAuthScreen({super.key});

  @override
  State<WelcomeAuthScreen> createState() => _WelcomeAuthScreenState();
}

class _WelcomeAuthScreenState extends State<WelcomeAuthScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: 'Kry Saravuth');
  final emailController = TextEditingController(text: 'student@appletech.dev');
  final passwordController = TextEditingController(text: 'password123');
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

  void submitAuth(AppStore store) {
    if (formKey.currentState!.validate()) {
      store.login(
        emailController.text.trim(),
        passwordController.text,
        name: nameController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final height = MediaQuery.sizeOf(context).height;
    final topGap = math.max(12.0, math.min(54.0, height * 0.045));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(30, 18, 30, 28),
              children: [
                SizedBox(height: topGap),
                const AppleTechAuthLogo(),
                SizedBox(height: isForgot || isVerify ? 34 : 28),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: KeyedSubtree(
                    key: ValueKey(view),
                    child: isForgot
                        ? ForgotPasswordPanel(
                            emailController: emailController,
                            onBack: () =>
                                setState(() => view = AuthView.signIn),
                            onReset: () =>
                                setState(() => view = AuthView.verifyCode),
                          )
                        : isVerify
                        ? VerifyCodePanel(
                            email: emailController.text,
                            controllers: codeControllers,
                            onBack: () =>
                                setState(() => view = AuthView.forgotPassword),
                            onVerify: () =>
                                setState(() => view = AuthView.signIn),
                          )
                        : Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  isSignUp
                                      ? 'Create an account'
                                      : 'Welcome back!',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: authBlue,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0,
                                      ),
                                ),
                                const SizedBox(height: 30),
                                if (isSignUp)
                                  AppTextField(
                                    controller: nameController,
                                    label: 'Full name',
                                    hintText: 'Enter your full name',
                                    validator: (value) => value!.trim().isEmpty
                                        ? 'Enter your name'
                                        : null,
                                  ),
                                AppTextField(
                                  controller: emailController,
                                  label: isSignUp ? 'Email' : 'Your Email',
                                  hintText: 'yourname@gmail.com',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) =>
                                      value != null && value.contains('@')
                                      ? null
                                      : 'Enter a valid email',
                                ),
                                AppTextField(
                                  controller: passwordController,
                                  label: 'Password',
                                  hintText: 'Enter your password',
                                  obscureText: hidePassword,
                                  suffix: IconButton(
                                    tooltip: hidePassword
                                        ? 'Show password'
                                        : 'Hide password',
                                    onPressed: () => setState(
                                      () => hidePassword = !hidePassword,
                                    ),
                                    icon: Icon(
                                      hidePassword
                                          ? CupertinoIcons.eye_slash
                                          : CupertinoIcons.eye,
                                      color: const Color(0xFFC8C8C8),
                                    ),
                                  ),
                                  validator: (value) =>
                                      value != null && value.length >= 6
                                      ? null
                                      : 'Use at least 6 characters',
                                ),
                                if (!isSignUp)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => setState(
                                        () => view = AuthView.forgotPassword,
                                      ),
                                      child: const Text('Forgot password?'),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                FilledButton(
                                  onPressed: () => submitAuth(store),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: authBlue,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size.fromHeight(58),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                const AuthDivider(),
                                const SizedBox(height: 20),
                                SocialAuthButton(
                                  icon: const Icon(
                                    Icons.apple,
                                    color: Colors.black,
                                    size: 23,
                                  ),
                                  label: 'Login with Apple',
                                  onPressed: () => submitAuth(store),
                                ),
                                const SizedBox(height: 12),
                                SocialAuthButton(
                                  icon: const GoogleMark(),
                                  label: 'Login with Google',
                                  onPressed: () => submitAuth(store),
                                ),
                                const SizedBox(height: 26),
                                AuthModeSwitch(
                                  isSignUp: isSignUp,
                                  onPressed: () => setState(
                                    () => view = isSignUp
                                        ? AuthView.signIn
                                        : AuthView.signUp,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

class AppleTechAuthLogo extends StatelessWidget {
  const AppleTechAuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 74,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 2,
                child: Icon(
                  CupertinoIcons.paperplane,
                  color: const Color(0xFF25425D).withAlpha(230),
                  size: 34,
                ),
              ),
              Positioned(
                bottom: 2,
                child: Container(
                  width: 44,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF25425D),
                      width: 1.8,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    CupertinoIcons.device_phone_portrait,
                    color: Color(0xFF25425D),
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF294A64),
              letterSpacing: 0,
            ),
            children: [
              TextSpan(text: 'Apple'),
              TextSpan(
                text: 'Tech',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: authLine)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: authLine)),
      ],
    );
  }
}

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: authInk,
          side: const BorderSide(color: authLine, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 28, child: Center(child: icon)),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class AuthModeSwitch extends StatelessWidget {
  const AuthModeSwitch({
    required this.isSignUp,
    required this.onPressed,
    super.key,
  });

  final bool isSignUp;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 2,
      children: [
        Text(
          isSignUp ? 'Already have an account?' : 'Don\'t have an account?',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(isSignUp ? 'Sign in' : 'Sign up'),
        ),
      ],
    );
  }
}

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
        AuthBackTitle(title: 'Forgot password', onBack: onBack),
        const SizedBox(height: 24),
        Text(
          'Please enter your email to reset the password.',
          style: TextStyle(
            color: Colors.grey.shade500,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        AppTextField(
          controller: emailController,
          label: 'Email',
          hintText: 'yourname@gmail.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: onReset,
          style: FilledButton.styleFrom(
            backgroundColor: authBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Reset Password',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class VerifyCodePanel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final maskedEmail = email.contains('@')
        ? '${email.split('@').first.characters.take(3).toString()}...@${email.split('@').last}'
        : 'your email';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthBackTitle(title: 'Check your email', onBack: onBack),
        const SizedBox(height: 24),
        Text(
          'We sent a reset link to $maskedEmail. Enter the 5 digit code mentioned in the email.',
          style: TextStyle(
            color: Colors.grey.shade600,
            height: 1.45,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            for (int index = 0; index < controllers.length; index++) ...[
              Expanded(
                child: CodeBox(
                  controller: controllers[index],
                  onChanged: (value) {
                    if (value.isNotEmpty && index < controllers.length - 1) {
                      FocusScope.of(context).nextFocus();
                    }
                  },
                ),
              ),
              if (index != controllers.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onVerify,
          style: FilledButton.styleFrom(
            backgroundColor: authBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Verify Code',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          children: [
            Text(
              'Haven\'t got the email yet?',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('Resend email')),
          ],
        ),
      ],
    );
  }
}

class AuthBackTitle extends StatelessWidget {
  const AuthBackTitle({required this.title, required this.onBack, super.key});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onBack,
          icon: const Icon(CupertinoIcons.chevron_left),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFF0F0F0),
            foregroundColor: authInk,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: authInk,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class CodeBox extends StatelessWidget {
  const CodeBox({required this.controller, required this.onChanged, super.key});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: authLine, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: authBlue, width: 2),
          ),
        ),
      ),
    );
  }
}
