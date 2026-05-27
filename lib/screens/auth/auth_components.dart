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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final buttonColor = disabled
        ? (isDark ? const Color(0xFF2C2C2E) : AppColors.lightGray)
        : (isDark ? const Color(0xFF1C1C1E) : AppColors.white);

    final borderColor = isDark
        ? const Color(0xFF3A3A3C)
        : AppColors.lightGray;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          color: buttonColor,
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
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )
                else
                  logo,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    color: Theme.of(context).colorScheme.onSurface,
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
                logo: Icon(
                  Icons.apple,
                  size: 22,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                label: 'Apple',
                onPressed: isBusy ? null : onAppleAuth,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: SocialAuthButton(
                logo: Builder(
                  builder: (context) {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    final img = Image.asset(
                      'assets/images/google_icon.png',
                      width: 26,
                      height: 26,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    );
                    if (isDark) {
                      // Wrap in a small white circle so the colorful Google
                      // logo stays crisp — the circle is small enough to look
                      // intentional rather than a full white button background.
                      return Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: img,
                      );
                    }
                    return img;
                  },
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
        backgroundColor: const Color.fromARGB(255, 18, 21, 24),
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
