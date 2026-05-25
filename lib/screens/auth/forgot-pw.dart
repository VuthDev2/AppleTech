part of '../../main.dart';

class ForgotPasswordPanel extends StatelessWidget {
  const ForgotPasswordPanel({
    required this.emailController,
    required this.isLoading,
    required this.onBack,
    required this.onReset,
    super.key,
  });

  final TextEditingController emailController;
  final bool isLoading;
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
                    AppLocalizations.of(context)?.resetPassword ??
                        'Reset Password',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppLocalizations.of(context)?.resetInstructions ??
                        'Enter your registered email to receive reset instructions',
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
              : (AppLocalizations.of(context)?.enterEmail ??
                    'Enter a valid email'),
        ),
        const SizedBox(height: AppSpacing.xl),
        AuthSubmitButton(
          label: AppLocalizations.of(context)?.submit ?? 'Submit',
          isLoading: isLoading,
          onPressed: isLoading ? null : onReset,
        ),
      ],
    );
  }
}
