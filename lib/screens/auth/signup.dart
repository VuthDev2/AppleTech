part of '../../main.dart';

class SignUpPanel extends StatelessWidget {
  const SignUpPanel({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.hidePassword,
    required this.isBusy,
    required this.isCredentialsLoading,
    required this.isGoogleLoading,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onAppleAuth,
    required this.onGoogleAuth,
    required this.onSignIn,
    super.key,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool hidePassword;
  final bool isBusy;
  final bool isCredentialsLoading;
  final bool isGoogleLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onAppleAuth;
  final VoidCallback onGoogleAuth;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)?.createAccount ?? 'Create an account',
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
          controller: nameController,
          label: AppLocalizations.of(context)?.fullName ?? 'Full name',
          hintText:
              AppLocalizations.of(context)?.enterFullName ??
              'Enter your full name',
          validator: (value) => value!.trim().isEmpty ? '' : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        ProfessionalTextField(
          controller: emailController,
          label: AppLocalizations.of(context)?.email ?? 'Email',
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
        const SizedBox(height: AppSpacing.xl),
        AuthSubmitButton(
          label:
              AppLocalizations.of(context)?.createAccountButton ??
              'Create Account',
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
              AppLocalizations.of(context)?.alreadyHaveAccount ??
                  'Already have an account? ',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: onSignIn,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                AppLocalizations.of(context)?.signIn ?? 'Sign In',
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
