part of '../../main.dart';

class VerifyCodePanel extends StatefulWidget {
  const VerifyCodePanel({
    required this.email,
    required this.controllers,
    required this.isLoading,
    required this.onBack,
    required this.onVerify,
    super.key,
  });

  final String email;
  final List<TextEditingController> controllers;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onVerify;

  @override
  State<VerifyCodePanel> createState() => _VerifyCodePanelState();
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
      if (!mounted) return;
      final nextSeconds = secondsRemaining - 1;

      if (nextSeconds <= 0) {
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
    final theme = Theme.of(context);
    final maskedEmail = widget.email.contains('@')
        ? '${widget.email.split('@').first.characters.take(3)}...@${widget.email.split('@').last}'
        : 'your email';
    final resendText = canResend
        ? (AppLocalizations.of(context)?.resendCode ??
              "Didn't receive the code? Resend")
        : 'Resend code in ${secondsRemaining}s';

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
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${AppLocalizations.of(context)?.checkInbox ?? "Check your inbox for verification code sent to"} $maskedEmail',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 50,
              child: TextFormField(
                controller: widget.controllers[index],
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.length == 1 && index < 5) {
                    FocusScope.of(context).nextFocus();
                  }
                  if (value.isEmpty && index > 0) {
                    FocusScope.of(context).previousFocus();
                  }
                  if (value.length == 1 && index == 5) {
                    widget.onVerify();
                  }
                },
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: TextButton(
            onPressed: canResend ? resendCode : null,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              disabledForegroundColor: AppColors.mediumGray,
            ),
            child: Text(
              resendText,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AuthSubmitButton(
          label: 'Verify Code',
          isLoading: widget.isLoading,
          onPressed: widget.isLoading ? null : widget.onVerify,
        ),
      ],
    );
  }
}
