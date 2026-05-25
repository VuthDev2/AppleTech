part of '../../main.dart';

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
                    letterSpacing: 0,
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

class AuthSocialActions extends StatelessWidget {
  const AuthSocialActions({
    required this.isBusy,
    required this.isGoogleLoading,
    required this.onAppleAuth,
    required this.onGoogleAuth,
    super.key,
  });

  final bool isBusy;
  final bool isGoogleLoading;
  final VoidCallback onAppleAuth;
  final VoidCallback onGoogleAuth;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(color: AppColors.lightGray, thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                AppLocalizations.of(context)?.orContinueWith ??
                    'Or continue with',
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
                onPressed: isBusy ? null : onAppleAuth,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: SocialAuthButton(
                logo: Image.asset(
                  'assets/images/google_icon.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                label: 'Google',
                isLoading: isGoogleLoading,
                onPressed: isBusy ? null : onGoogleAuth,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.white,
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
    );
  }
}
