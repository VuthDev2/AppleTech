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
            const Text('Account'),
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
                Container(
                  width: 72,
                  height: 72,
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
                  child: Center(
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name.substring(0, 1).toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
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
              'Address management will be available from checkout.',
            ),
            onSupport: () => _showSettingsMessage(
              context,
              'AppleTech Support is ready to help with orders and devices.',
            ),
            onPrivacy: () => _showSettingsMessage(
              context,
              'Privacy controls are protected in this demo experience.',
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // Orders Section
          Text(
            'Order History',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.md),

          if (store.orders.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 40),
              child: EmptyState(
                icon: CupertinoIcons.clock,
                title: 'No Orders Yet',
                subtitle:
                    'Your order history will appear here once you make a purchase.',
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

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email cannot be empty';
                      }
                      if (!v.contains('@')) return 'Invalid email address';
                      return null;
                    },
                  ),
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
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
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
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              store.updateUserProfile(
                                name: nameController.text,
                                email: emailController.text,
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated successfully'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: const Text('Save'),
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
          title: 'Account',
          children: [
            _SettingsRow(
              icon: CupertinoIcons.person_crop_circle,
              title: 'Personal information',
              subtitle: 'Name, email, and customer profile',
              onTap: onEditProfile,
            ),
            _SettingsRow(
              icon: CupertinoIcons.location,
              title: 'Delivery addresses',
              subtitle: 'Default shipping location and contact phone',
              trailingText: '1 saved',
              onTap: onManageAddresses,
            ),
            _SettingsRow(
              icon: CupertinoIcons.lock_shield,
              title: 'Secure checkout',
              subtitle: 'Require Face ID or passcode before payment',
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
          title: 'Preferences',
          children: [
            _SettingsRow(
              icon: isDarkMode
                  ? CupertinoIcons.moon_fill
                  : CupertinoIcons.sun_max_fill,
              title: 'Appearance',
              subtitle: isDarkMode ? 'Dark mode enabled' : 'Light mode enabled',
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
              title: 'Order updates',
              subtitle: 'Delivery alerts, receipts, and pickup status',
              trailing: Switch.adaptive(
                value: orderUpdatesEnabled,
                activeTrackColor: AppColors.primary,
                onChanged: onOrderUpdatesChanged,
              ),
            ),
            _SettingsRow(
              icon: CupertinoIcons.tag,
              title: 'Offers and product news',
              subtitle: 'Personalized deals, launches, and availability',
              trailing: Switch.adaptive(
                value: offersEnabled,
                activeTrackColor: AppColors.primary,
                onChanged: onOffersChanged,
              ),
            ),
            _SettingsRow(
              icon: CupertinoIcons.checkmark_shield,
              title: 'AppleTech Care reminders',
              subtitle: 'Coverage renewal and warranty notifications',
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
          title: 'Support',
          children: [
            _SettingsRow(
              icon: CupertinoIcons.chat_bubble_2,
              title: 'Contact support',
              subtitle: 'Get help with orders, returns, and setup',
              trailingText: '24/7',
              onTap: onSupport,
            ),
            _SettingsRow(
              icon: CupertinoIcons.doc_text,
              title: 'Privacy and terms',
              subtitle: 'Data use, purchase terms, and return policy',
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkGray
              : AppColors.lightGray,
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
                    'ORDER ID',
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
              Text(
                '\$${order.total}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(
                CupertinoIcons.cube_box,
                size: 16,
                color: AppColors.mediumGray,
              ),
              const SizedBox(width: 8),
              Text(
                '${order.items.length} items • ${order.status}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mediumGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const DeliveryTimeline(),
        ],
      ),
    );
  }
}

class DeliveryTimeline extends StatelessWidget {
  const DeliveryTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const _TimelineStep(label: 'Ordered', isActive: true),
            _TimelineDivider(isActive: true),
            const _TimelineStep(label: 'Packed', isActive: true),
            _TimelineDivider(isActive: false),
            const _TimelineStep(label: 'Shipped', isActive: false),
          ],
        ),
      ],
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
