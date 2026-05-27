
part of '../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _orderUpdatesEnabled = true;
  bool _offersEnabled = true;
  bool _biometricCheckoutEnabled = true;
  bool _appleCareReminderEnabled = true;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final user = store.user;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const StoreBrandMark(height: 22),
            const SizedBox(width: AppSpacing.md),
            Text(AppLocalizations.of(context)?.accountUpper ?? 'Account'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: store.logout,
            icon: const Icon(CupertinoIcons.square_arrow_right, size: 20),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkGray
                    : AppColors.lightGray,
              ),
              boxShadow: appShadowSm,
            ),
            child: Row(
              children: [
                StoreUserAvatar(
                  name: user?.name ?? 'AppleTech Customer',
                  photoUrl: user?.photoUrl,
                  size: 72,
                  onTap: store.canChangeProfilePhoto
                      ? () => _showEditProfileSheet(context, store)
                      : null,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'AppleTech Customer',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'customer@apple.com',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit Profile',
                  icon: const Icon(
                    CupertinoIcons.pencil_ellipsis_rectangle,
                    size: 22,
                    color: AppColors.primary,
                  ),
                  onPressed: () => _showEditProfileSheet(context, store),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          _SettingsPanel(
            isDarkMode: store.isDarkMode,
            orderUpdatesEnabled: _orderUpdatesEnabled,
            offersEnabled: _offersEnabled,
            biometricCheckoutEnabled: _biometricCheckoutEnabled,
            appleCareReminderEnabled: _appleCareReminderEnabled,
            onEditProfile: () => _showEditProfileSheet(context, store),
            onLanguageTap: () => _showLanguageSelection(context, store),
    onThemeChanged: (_) => store.toggleTheme(),
            onOrderUpdatesChanged: (value) {
              setState(() => _orderUpdatesEnabled = value);
            },
            onOffersChanged: (value) {
              setState(() => _offersEnabled = value);
            },
            onBiometricCheckoutChanged: (value) {
              setState(() => _biometricCheckoutEnabled = value);
            },
            onAppleCareReminderChanged: (value) {
              setState(() => _appleCareReminderEnabled = value);
            },
            onManageAddresses: () => _showSettingsMessage(
              context,
              'Visit management is available in your history.',
            ),
            onSupport: () => _showSettingsMessage(
              context,
              'AppleTech Support is ready to help with your visit and devices.',
            ),
            onPrivacy: () => _showSettingsMessage(
              context,
              'Privacy controls are protected in this demo experience.',
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // Orders Section
          Text(
            AppLocalizations.of(context)?.orderHistory ?? 'Visit History',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.md),

          if (store.orders.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              child: EmptyState(
                icon: CupertinoIcons.clock,
                title: AppLocalizations.of(context)?.noOrdersYet ?? 'No Scheduled Visits',
                subtitle: AppLocalizations.of(context)?.orderHistoryAppearHere ??
                    'Your visit history will appear here once you schedule a visit.',
              ),
            )
          else
            for (final order in store.orders) OrderTile(order: order),

          const SizedBox(height: AppSpacing.xxxl),

          // FAQ Accordion Section
          const FaqSection(),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, AppStore store) {
    final nameController = TextEditingController(text: store.user?.name);
    final emailController = TextEditingController(text: store.user?.email);
    final formKey = GlobalKey<FormState>();
    Uint8List? pickedPhotoBytes;
    final picker = ImagePicker();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            return StatefulBuilder(
              builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final previewPhotoUrl = store.user?.photoUrl;
            final canChangePhoto = store.canChangeProfilePhoto;

            Future<void> pickPhoto() async {
              try {
                final file = await pickProfileImage(picker);
                if (file == null) return;
                final bytes = await file.readAsBytes();
                setSheetState(() => pickedPhotoBytes = bytes);
              } on PhotoPermissionException catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.toString()),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } on PlatformException catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      error.message ?? 'Could not open photo library.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (error) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)?.couldNotOpenPhoto(error.toString()) ?? 'Could not open photo library: $error'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkGray : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xxl),
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.lightGray,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Edit Profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            pickedPhotoBytes != null
                                ? ClipOval(
                                    child: Image.memory(
                                      pickedPhotoBytes!,
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : _ProfileAvatar(
                                    name: nameController.text.isNotEmpty
                                        ? nameController.text
                                        : store.user?.name ?? 'A',
                                    photoUrl: previewPhotoUrl,
                                    size: 96,
                                  ),
                            if (canChangePhoto)
                              Positioned(
                                right: -4,
                                bottom: -4,
                                child: Material(
                                  color: AppColors.primary,
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: pickPhoto,
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        CupertinoIcons.camera_fill,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (canChangePhoto) ...[
                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: TextButton(
                            onPressed: pickPhoto,
                            child: Text(AppLocalizations.of(context)?.changePhoto ?? 'Change photo'),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      ProfessionalTextField(
                        controller: nameController,
                        hintText: 'Enter your name',
                        label: 'Full Name',
                        prefixIcon: CupertinoIcons.person,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Name cannot be empty'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ProfessionalTextField(
                        controller: emailController,
                        hintText: 'Enter your email',
                        label: 'Email Address',
                        prefixIcon: CupertinoIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: !store.canEditEmail,
                        validator: (v) {
                          if (!store.canEditEmail) return null;
                          if (v == null || v.trim().isEmpty) {
                            return 'Email cannot be empty';
                          }
                          if (!v.contains('@')) return 'Invalid email address';
                          return null;
                        },
                      ),
                      if (!store.canEditEmail) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Email is linked to your sign-in account and cannot be changed here.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxxl),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.lg,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                ),
                              ),
                              onPressed: store.isProfileUpdating
                                  ? null
                                  : () => Navigator.pop(context),
                              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.lg,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                ),
                              ),
                              onPressed: store.isProfileUpdating
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }
                                      final ok = await store.updateUserProfile(
                                        name: nameController.text,
                                        email: emailController.text,
                                        photoBytes: pickedPhotoBytes,
                                      );
                                      if (!context.mounted) return;
                                      if (ok) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          sheetContext,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Profile updated successfully',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              store.authError ??
                                                  'Could not update profile.',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                              child: store.isProfileUpdating
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(AppLocalizations.of(context)?.save ?? 'Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
              },
            );
          },
        );
      },
    );
  }

  void _showLanguageSelection(BuildContext context, AppStore store) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkGray : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  AppLocalizations.of(ctx)!.changeLanguage,
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppSpacing.xl),
                ListTile(
                  leading: const Icon(CupertinoIcons.globe),
                  title: Text(AppLocalizations.of(ctx)!.english),
                  onTap: () {
                    store.setLocale(const Locale('en'));
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.globe),
                  title: Text(AppLocalizations.of(ctx)!.khmer),
                  onTap: () {
                    store.setLocale(const Locale('km'));
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.globe),
                  title: Text(AppLocalizations.of(ctx)!.chinese),
                  onTap: () {
                    store.setLocale(const Locale('zh'));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.isDarkMode,
    required this.orderUpdatesEnabled,
    required this.offersEnabled,
    required this.biometricCheckoutEnabled,
    required this.appleCareReminderEnabled,
    required this.onEditProfile,
    required this.onLanguageTap,

    required this.onThemeChanged,
    required this.onOrderUpdatesChanged,
    required this.onOffersChanged,
    required this.onBiometricCheckoutChanged,
    required this.onAppleCareReminderChanged,
    required this.onManageAddresses,
    required this.onSupport,
    required this.onPrivacy,
  });

  final bool isDarkMode;
  final bool orderUpdatesEnabled;
  final bool offersEnabled;
  final bool biometricCheckoutEnabled;
  final bool appleCareReminderEnabled;
  final VoidCallback onEditProfile;
  final VoidCallback onLanguageTap;

  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<bool> onOrderUpdatesChanged;
  final ValueChanged<bool> onOffersChanged;
  final ValueChanged<bool> onBiometricCheckoutChanged;
  final ValueChanged<bool> onAppleCareReminderChanged;
  final VoidCallback onManageAddresses;
  final VoidCallback onSupport;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.white70 : AppColors.mediumGray;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.settings ?? 'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Manage your AppleTech account, checkout, and communication preferences.',
          style: theme.textTheme.bodyMedium?.copyWith(color: mutedColor),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SettingsGroup(
          title: AppLocalizations.of(context)?.account ?? 'Account',
          children: [
            _SettingsRow(
              icon: CupertinoIcons.person_crop_circle,
              title: AppLocalizations.of(context)?.personalInformation ?? 'Personal information',
              subtitle: AppLocalizations.of(context)?.nameEmailProfile ?? 'Name, email, and customer profile',
              onTap: onEditProfile,
            ),
            _SettingsRow(
              icon: CupertinoIcons.location,
              title: AppLocalizations.of(context)?.deliveryAddresses ?? 'Delivery addresses',
              subtitle: AppLocalizations.of(context)?.defaultShipping ?? 'Default shipping location and contact phone',
              trailingText: '1 ${AppLocalizations.of(context)?.saved ?? 'saved'}',
              onTap: onManageAddresses,
            ),
            _SettingsRow(
              icon: CupertinoIcons.lock_shield,
              title: AppLocalizations.of(context)?.secureCheckout ?? 'Secure checkout',
              subtitle: AppLocalizations.of(context)?.requireFaceId ?? 'Require Face ID or passcode before payment',
              trailing: Switch.adaptive(
                value: biometricCheckoutEnabled,
                activeTrackColor: AppColors.primary,
                onChanged: onBiometricCheckoutChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SettingsGroup(
          title: AppLocalizations.of(context)?.preferences ?? 'Preferences',
          children: [
            _SettingsRow(
              icon: isDarkMode
                  ? CupertinoIcons.moon_fill
                  : CupertinoIcons.sun_max_fill,
              title: AppLocalizations.of(context)?.appearance ?? 'Appearance',
              subtitle: isDarkMode 
                  ? (AppLocalizations.of(context)?.darkModeEnabled ?? 'Dark mode enabled')
                  : (AppLocalizations.of(context)?.lightModeEnabled ?? 'Light mode enabled'),
              trailing: Switch.adaptive(
                value: isDarkMode,
                activeTrackColor: AppColors.primary,
                onChanged: onThemeChanged,
              ),
            ),
            _SettingsRow(
              icon: CupertinoIcons.globe,
              title: AppLocalizations.of(context)?.language ?? 'Language',
              subtitle: AppLocalizations.of(context)?.changeLanguage ?? 'Change app language',
              trailingText: store.locale?.languageCode.toUpperCase() ?? 'EN',
              onTap: onLanguageTap,
            ),
            _SettingsRow(
              icon: CupertinoIcons.bell,
              title: AppLocalizations.of(context)?.orderUpdates ?? 'Order updates',
              subtitle: AppLocalizations.of(context)?.deliveryAlerts ?? 'Delivery alerts, receipts, and pickup status',
              trailing: Switch.adaptive(
                value: orderUpdatesEnabled,
                activeTrackColor: AppColors.primary,
                onChanged: onOrderUpdatesChanged,
              ),
            ),
            _SettingsRow(
              icon: CupertinoIcons.tag,
              title: AppLocalizations.of(context)?.offersAndNews ?? 'Offers and product news',
              subtitle: AppLocalizations.of(context)?.personalizedDeals ?? 'Personalized deals, launches, and availability',
              trailing: Switch.adaptive(
                value: offersEnabled,
                activeTrackColor: AppColors.primary,
                onChanged: onOffersChanged,
              ),
            ),
            _SettingsRow(
              icon: CupertinoIcons.checkmark_shield,
              title: AppLocalizations.of(context)?.appleTechCareReminders ?? 'AppleTech Care reminders',
              subtitle: AppLocalizations.of(context)?.coverageRenewal ?? 'Coverage renewal and warranty notifications',
              trailing: Switch.adaptive(
                value: appleCareReminderEnabled,
                activeTrackColor: AppColors.primary,
                onChanged: onAppleCareReminderChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SettingsGroup(
          title: AppLocalizations.of(context)?.support ?? 'Support',
          children: [
            _SettingsRow(
              icon: CupertinoIcons.chat_bubble_2,
              title: AppLocalizations.of(context)?.contactSupport ?? 'Contact support',
              subtitle: AppLocalizations.of(context)?.getHelpWithOrders ?? 'Get help with orders, returns, and setup',
              trailingText: '24/7',
              onTap: onSupport,
            ),
            _SettingsRow(
              icon: CupertinoIcons.doc_text,
              title: AppLocalizations.of(context)?.privacyAndTerms ?? 'Privacy and terms',
              subtitle: AppLocalizations.of(context)?.dataUse ?? 'Data use, purchase terms, and return policy',
              onTap: onPrivacy,
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.darkGray : AppColors.lightGray,
        ),
        boxShadow: appShadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mediumGray,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1)
                Divider(
                  height: 1,
                  indent: AppSpacing.xl,
                  color: isDark ? Colors.white10 : AppColors.lightGray,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.trailingText,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final String? trailingText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveTrailing = trailing ?? _buildTrailing(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(isDark ? 45 : 18),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color: isDark ? Colors.white : AppColors.primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : AppColors.mediumGray,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              effectiveTrailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (trailingText != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            trailingText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mediumGray,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            CupertinoIcons.chevron_forward,
            color: AppColors.mediumGray,
            size: 16,
          ),
        ],
      );
    }

    if (onTap != null) {
      return const Icon(
        CupertinoIcons.chevron_forward,
        color: AppColors.mediumGray,
        size: 16,
      );
    }

    return const SizedBox.shrink();
  }
}

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.md),
        const FaqAccordionItem(
          question: 'What is the AppleTech return policy?',
          answer:
              'We offer a 14-day premium return policy on all hardware items. Devices must be returned in their original packaging with all accessories and proof of purchase. Returns are completely free of charge.',
        ),
        const FaqAccordionItem(
          question: 'Does AppleTech ship globally?',
          answer:
              'Yes! We ship internationally to over 80 countries worldwide. Fast express shipping is free on orders above \$500. Duties and local taxes are calculated at checkout automatically.',
        ),
        const FaqAccordionItem(
          question: 'How long does standard delivery take?',
          answer:
              'Standard local deliveries take 1 to 2 business days. Express shipping is delivered next day if ordered before 3:00 PM. International delivery times vary by country but usually average 3 to 5 business days.',
        ),
        const FaqAccordionItem(
          question: 'What warranties are included?',
          answer:
              'All new AppleTech hardware products include a 1-Year Limited Hardware Warranty and 90 days of complimentary technical support. You can purchase AppleTech Care+ to extend coverage up to 3 years.',
        ),
      ],
    );
  }
}

class FaqAccordionItem extends StatefulWidget {
  const FaqAccordionItem({
    required this.question,
    required this.answer,
    super.key,
  });

  final String question;
  final String answer;

  @override
  State<FaqAccordionItem> createState() => _FaqAccordionItemState();
}

class _FaqAccordionItemState extends State<FaqAccordionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.darkGray : AppColors.lightGray,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: AppAnimations.normal,
                      curve: AppAnimations.smooth,
                      child: const Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Text(
                  widget.answer,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : AppColors.mediumGray,
                    height: 1.5,
                  ),
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: AppAnimations.normal,
              sizeCurve: AppAnimations.smooth,
            ),
          ],
        ),
      ),
    );
  }
}

class OrderTile extends StatelessWidget {
  const OrderTile({required this.order, super.key});

  final OrderRecord order;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.darkGray : AppColors.lightGray,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RESERVATION ID',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: AppColors.mediumGray,
                    ),
                  ),
                  Text(
                    order.id,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (order.visitTime != null) ...[
            Row(
              children: [
                const Icon(CupertinoIcons.calendar, size: 14, color: AppColors.mediumGray),
                const SizedBox(width: 8),
                Text(
                  'Visit: ${DateFormat('MMM dd, yyyy').format(order.visitTime!)} at ${order.visitTime!.hour.toString().padLeft(2, '0')}:${order.visitTime!.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: AppColors.mediumGray,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              const Icon(CupertinoIcons.cube_box, size: 14, color: AppColors.mediumGray),
              const SizedBox(width: 8),
              Text(
                '${order.items.length} items shortlisted',
                style: const TextStyle(
                  color: AppColors.mediumGray,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.label, required this.isActive});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.lightGray,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(60),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
            color: isActive
                ? (isDark ? Colors.white : AppColors.black)
                : AppColors.mediumGray,
          ),
        ),
      ],
    );
  }
}

class _TimelineDivider extends StatelessWidget {
  const _TimelineDivider({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          height: 2,
          color: isActive ? AppColors.primary : AppColors.lightGray,
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.name,
    this.photoUrl,
    this.size = 72,
    this.onTap,
  });

  final String name;
  final String? photoUrl;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'A';
    final inlineBytes = FirestoreInlineProfileStorage.bytesFromPhotoUrl(photoUrl);
    Widget avatar;
    if (inlineBytes != null) {
      avatar = ClipOval(
        child: Image.memory(
          inlineBytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else if (photoUrl != null &&
        photoUrl!.isNotEmpty &&
        photoUrl!.startsWith('http')) {
      avatar = ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initials(initial, size),
          errorWidget: (_, __, ___) => _initials(initial, size),
        ),
      );
    } else {
      avatar = _initials(initial, size);
    }

    if (onTap == null) return avatar;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: avatar,
      ),
    );
  }

  Widget _initials(String initial, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.appleGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
