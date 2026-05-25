part of '../../main.dart';

class LoginPanel extends StatelessWidget {
  const LoginPanel({
    required this.emailController,
    required this.passwordController,
    required this.hidePassword,
    required this.isBusy,
    required this.isCredentialsLoading,
    required this.isGoogleLoading,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onAppleAuth,
    required this.onGoogleAuth,
    required this.onSignUp,
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool hidePassword;
  final bool isBusy;
  final bool isCredentialsLoading;
  final bool isGoogleLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onAppleAuth;
  final VoidCallback onGoogleAuth;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)?.welcomeBack ?? 'Welcome back!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 30),
        ProfessionalTextField(
          controller: emailController,
          label: AppLocalizations.of(context)?.yourEmail ?? 'Your Email',
          hintText: 'yourname@gmail.com',
          keyboardType: TextInputType.emailAddress,
          validator: (value) => value != null && value.contains('@')
              ? null
              : (AppLocalizations.of(context)?.enterEmail ??
                    'Enter a valid email'),
        ),
        const SizedBox(height: AppSpacing.lg),
        ProfessionalTextField(
          controller: passwordController,
          label: AppLocalizations.of(context)?.password ?? 'Password',
          hintText:
              AppLocalizations.of(context)?.enterPassword ??
              'Enter your password',
          obscureText: hidePassword,
          suffixIcon: IconButton(
            onPressed: onTogglePassword,
            icon: Icon(
              hidePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.mediumGray,
            ),
          ),
          validator: (value) => value != null && value.length >= 6
              ? null
              : (AppLocalizations.of(context)?.useAtLeast6Digits ??
                    'Use at least 6 digits'),
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onForgotPassword,
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: Text(
              AppLocalizations.of(context)?.forgotPassword ??
                  'Forgot password?',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AuthSubmitButton(
          label: AppLocalizations.of(context)?.continueButton ?? 'Continue',
          isLoading: isCredentialsLoading,
          onPressed: isBusy ? null : onSubmit,
        ),
        const SizedBox(height: AppSpacing.xl),
        AuthSocialActions(
          isBusy: isBusy,
          isGoogleLoading: isGoogleLoading,
          onAppleAuth: onAppleAuth,
          onGoogleAuth: onGoogleAuth,
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 2,
          children: [
            Text(
              AppLocalizations.of(context)?.dontHaveAccount ??
                  "Don't have an account yet? ",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: onSignUp,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                AppLocalizations.of(context)?.signUp ?? 'Sign Up',
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
