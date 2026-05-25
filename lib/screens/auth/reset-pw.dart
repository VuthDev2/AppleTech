part of '../../main.dart';

class ResetPasswordPanel extends StatelessWidget {
  const ResetPasswordPanel({
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.hidePassword,
    required this.hideConfirmPassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onBack,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool hidePassword;
  final bool hideConfirmPassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backBg = isDark ? AppColors.darkSurface2 : AppColors.lightGray;
    final backFg = theme.colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor: backBg,
                foregroundColor: backFg,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create new password',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Enter and confirm your new AppleTech password',
                    style: theme.textTheme.bodySmall,
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
              : (AppLocalizations.of(context)?.enterEmail ??
                    'Enter a valid email'),
        ),
        const SizedBox(height: AppSpacing.lg),
        ProfessionalTextField(
          controller: passwordController,
          label: AppLocalizations.of(context)?.password ?? 'Password',
          hintText: 'Enter new password',
          obscureText: hidePassword,
          prefixIcon: Icons.lock_outline,
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
        const SizedBox(height: AppSpacing.lg),
        ProfessionalTextField(
          controller: confirmPasswordController,
          label: 'Confirm Password',
          hintText: 'Confirm new password',
          obscureText: hideConfirmPassword,
          prefixIcon: Icons.lock_reset,
          suffixIcon: IconButton(
            onPressed: onToggleConfirmPassword,
            icon: Icon(
              hideConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.mediumGray,
            ),
          ),
          validator: (value) => value == passwordController.text
              ? null
              : 'Passwords do not match',
        ),
        const SizedBox(height: AppSpacing.xl),
        AuthSubmitButton(
          label: 'Update Password',
          isLoading: isLoading,
          onPressed: isLoading ? null : onSubmit,
        ),
      ],
    );
  }
}
