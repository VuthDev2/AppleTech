part of '../../main.dart';

class BagScreen extends StatelessWidget {
  const BagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const StoreBrandMark(height: 22),
            const SizedBox(width: AppSpacing.md),
            Text(AppLocalizations.of(context)?.yourBag ?? 'Your Bag'),
          ],
        ),
        actions: [
          if (store.bag.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: TextButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Bag'),
                      content: const Text('Are you sure you want to remove all items from your bag?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            store.clearBag();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.error),
                ),
              ),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: AppAnimations.normal,
        child: store.bag.isEmpty
            ? EmptyState(
                icon: CupertinoIcons.bag,
                title: AppLocalizations.of(context)?.emptyBag ?? 'Your Bag is empty',
                subtitle: AppLocalizations.of(context)?.bagEmptyDesc ?? 'Items you add to your bag will appear here. They will stay here until you are ready to checkout.',
                customArt: const BagEmptyArt(),
              )
            : Column(
                children: [
                  if (store.orders.isNotEmpty && store.orders.any((o) => o.status == 'Visit Scheduled'))
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, 0),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.success.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.checkmark_seal_fill, color: AppColors.success, size: 18),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Visit Scheduled',
                                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.success, fontSize: 13),
                                ),
                                Text(
                                  'You can still edit your selection or details.',
                                  style: TextStyle(color: AppColors.success.withAlpha(200), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const MultiStepCheckoutSheet(),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.success,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Edit Info', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () {
                              final visit = store.orders.firstWhere((o) => o.status == 'Visit Scheduled');
                              store.cancelVisit(visit.id);
                            },
                            icon: const Icon(CupertinoIcons.xmark_circle, color: AppColors.error, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            tooltip: 'Cancel Visit',
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.separated(
                      key: const ValueKey('bag_list'),
                      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, 250),
                      itemCount: store.bag.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
                      itemBuilder: (context, index) {
                        final item = store.bag[index];
                        return Dismissible(
                          key: ValueKey('${item.productId}-${item.variantId}'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            store.removeFromBag(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Item removed from Selection'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          background: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                            child: const Icon(CupertinoIcons.trash, color: Colors.white),
                          ),
                          child: CartItemTile(item: item),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      bottomSheet: (store.bag.isEmpty || (store.orders.isNotEmpty && store.orders.any((o) => o.status == 'Visit Scheduled'))) 
          ? null 
          : const CheckoutSummarySheet(),
    );
  }
}

class CartItemTile extends StatelessWidget {
  const CartItemTile({required this.item, super.key});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final product = store.productById(item.productId);
    final variant = store.variantById(item.productId, item.variantId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark ? AppColors.darkGray.withAlpha(80) : AppColors.lightGray,
        ),
        boxShadow: appShadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              SizedBox(
                width: 110,
                child: Hero(
                  tag: 'product-image-${product.id}-${variant.id}',
                  child: ProductImageBox(
                    imagePath: product.imagePath,
                    category: product.category,
                    fit: BoxFit.contain,
                    animate: false,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              
              // Product Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${variant.colorName} • ${variant.storage}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '\$${variant.price}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              IconButton(
                                icon: Icon(
                                  store.wishlist.contains(product.id)
                                      ? CupertinoIcons.heart_fill
                                      : CupertinoIcons.heart,
                                  size: 18,
                                  color: store.wishlist.contains(product.id)
                                      ? AppColors.primary
                                      : AppColors.mediumGray,
                                ),
                                tooltip: 'Save for later',
                                onPressed: () {
                                  store.removeFromBag(item);
                                  if (!store.wishlist.contains(product.id)) {
                                    store.toggleWishlist(product.id);
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Moved ${product.name} to Wishlist'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.md),
                            child: QuantityStepper(
                              quantity: item.quantity,
                              onMinus: () => store.updateQuantity(item, item.quantity - 1),
                              onPlus: () => store.updateQuantity(item, item.quantity + 1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
    super.key,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGray.withAlpha(150),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: CupertinoIcons.minus,
            onPressed: onMinus,
          ),
          SizedBox(
            width: 30,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
          _StepperButton(
            icon: CupertinoIcons.plus,
            onPressed: onPlus,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 14, color: AppColors.black),
        ),
      ),
    );
  }
}

class CheckoutSummarySheet extends StatelessWidget {
  const CheckoutSummarySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withAlpha(isDark ? 240 : 252),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        border: Border.all(
          color: isDark ? AppColors.darkGray.withAlpha(80) : AppColors.lightGray,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Promo Code Container
          _PromoCodeField(store: store),
          
          const SizedBox(height: AppSpacing.md),
          _PriceRow(label: AppLocalizations.of(context)?.subtotal ?? 'Subtotal', amount: store.subtotal),
          
          if (store.discount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            _PriceRow(
              label: 'Promo Discount (${store.appliedPromoCode})',
              amount: store.discount,
              isDiscount: true,
            ),
          ],
          
          const SizedBox(height: AppSpacing.sm),
          _PriceRow(label: AppLocalizations.of(context)?.shipping ?? 'Shipping', amount: 0, isFree: true),
          const SizedBox(height: AppSpacing.sm),
          _PriceRow(label: AppLocalizations.of(context)?.tax ?? 'Estimated Tax', amount: store.tax),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Divider(color: AppColors.lightGray, thickness: 1),
          ),
          _PriceRow(label: AppLocalizations.of(context)?.total ?? 'Total', amount: store.total, isTotal: true),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const MultiStepCheckoutSheet(),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
            ),
            child: const Text('Plan Store Visit', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
    this.isFree = false,
    this.isDiscount = false,
  });

  final String label;
  final int amount;
  final bool isTotal;
  final bool isFree;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String displayAmount = '\$${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    if (isDiscount) {
      displayAmount = '-\$${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal 
                ? (isDark ? AppColors.white : AppColors.black)
                : AppColors.mediumGray,
            fontSize: isTotal ? 18 : 15,
          ),
        ),
        Text(
          isFree ? (AppLocalizations.of(context)?.free ?? 'FREE') : displayAmount,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
            fontSize: isTotal ? 22 : 16,
            color: isFree || isDiscount
                ? AppColors.success 
                : (isDark ? AppColors.white : AppColors.black),
          ),
        ),
      ],
    );
  }
}

class _PromoCodeField extends StatefulWidget {
  const _PromoCodeField({required this.store});

  final AppStore store;

  @override
  State<_PromoCodeField> createState() => _PromoCodeFieldState();
}

class _PromoCodeFieldState extends State<_PromoCodeField> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.store.appliedPromoCode != null) {
      _controller.text = widget.store.appliedPromoCode!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPromo = widget.store.appliedPromoCode != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: TextFormField(
                  controller: _controller,
                  enabled: !hasPromo,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Promo Code (APPLE10, WELCOME)',
                    filled: true,
                    fillColor: AppColors.lightGray.withAlpha(120),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    suffixIcon: hasPromo 
                        ? const Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.success)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () {
                  if (hasPromo) {
                    widget.store.clearPromoCode();
                    _controller.clear();
                    setState(() => _error = null);
                  } else {
                    final code = _controller.text.trim();
                    if (code.isEmpty) return;
                    final success = widget.store.applyPromoCode(code);
                    if (success) {
                      setState(() => _error = null);
                    } else {
                      setState(() => _error = 'Invalid Promo Code');
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: hasPromo ? Colors.red.shade400 : AppColors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Text(
                  hasPromo ? 'Remove' : 'Apply',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 4),
          Text(
            _error!,
            style: TextStyle(color: Colors.red.shade600, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}

class MultiStepCheckoutSheet extends StatefulWidget {
  const MultiStepCheckoutSheet({super.key});

  @override
  State<MultiStepCheckoutSheet> createState() => _MultiStepCheckoutSheetState();
}

class _MultiStepCheckoutSheetState extends State<MultiStepCheckoutSheet> {
  int _currentStep = 1; // 1: Details, 2: Success
  bool _processing = false;
  bool _complete = false;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  DateTime _visitDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _visitTime = const TimeOfDay(hour: 10, minute: 0);
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final store = AppScope.of(context);
      final existingVisit = store.orders.cast<OrderRecord?>().firstWhere(
            (o) => o?.status == 'Visit Scheduled',
            orElse: () => null,
          );

      if (existingVisit != null) {
        _nameController.text = existingVisit.customerName ?? '';
        _phoneController.text = existingVisit.customerPhone ?? '';
        _addressController.text = existingVisit.customerAddress ?? '';

        if (existingVisit.visitTime != null) {
          _visitDate = existingVisit.visitTime!;
          _visitTime = TimeOfDay.fromDateTime(existingVisit.visitTime!);
        }
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _visitDate) {
      setState(() => _visitDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _visitTime,
    );
    if (picked != null && picked != _visitTime) {
      setState(() => _visitTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkGray : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + AppSpacing.xxl,
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              if (_currentStep == 1) _buildDetailsStep(store, isDark),
              if (_currentStep == 2) _buildSuccessStep(store, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsStep(AppStore store, bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan Your Store Visit',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tell us when you are coming and we will have your items ready for testing.',
            style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.xxl),
          
          ProfessionalTextField(
            controller: _nameController,
            hintText: 'e.g. Kry Saravuth',
            label: 'Full Name',
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfessionalTextField(
            controller: _phoneController,
            hintText: '012 345 678',
            label: 'Phone Number',
            keyboardType: TextInputType.phone,
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfessionalTextField(
            controller: _addressController,
            hintText: 'Street, House No, City',
            label: 'Address (Optional)',
          ),
          const SizedBox(height: AppSpacing.xxl),

          Text('Expected Visit Time', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white.withAlpha(20) : AppColors.lightGray.withAlpha(100),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.calendar, size: 20),
                        const SizedBox(width: AppSpacing.md),
                        Text(DateFormat('MMM dd, yyyy').format(_visitDate)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: InkWell(
                  onTap: _selectTime,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white.withAlpha(20) : AppColors.lightGray.withAlpha(100),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.clock, size: 20),
                        const SizedBox(width: AppSpacing.md),
                        Text(_visitTime.format(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xxxl),

          // Confirm interaction
          GestureDetector(
            onLongPressStart: (_) async {
              if (_formKey.currentState!.validate()) {
                setState(() => _processing = true);
                await Future<void>.delayed(const Duration(milliseconds: 1400));
                if (!mounted) return;
                
                setState(() {
                  _processing = false;
                  _complete = true;
                });
                
                await Future<void>.delayed(const Duration(milliseconds: 800));
                if (!mounted) return;

                final visitDateTime = DateTime(
                  _visitDate.year,
                  _visitDate.month,
                  _visitDate.day,
                  _visitTime.hour,
                  _visitTime.minute,
                );

                try {
                  store.completeCheckout(
                    customerName: _nameController.text.trim(),
                    customerPhone: _phoneController.text.trim(),
                    customerAddress: _addressController.text.trim(),
                    visitTime: visitDateTime,
                  );
                } catch (e) {
                  // Fallback: Proceed even if backend fails (Offline/Guest mode)
                  debugPrint('Visit saved locally: $e');
                }

                setState(() {
                  _currentStep = 2;
                });
              } else {
                // Haptic feedback or snackbar to show validation failed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please fill out your name and phone number.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.orange.shade800,
                  ),
                );
              }
            },
            onLongPressEnd: (_) {
              if (!_complete) setState(() => _processing = false);
            },
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                color: _complete 
                    ? AppColors.success 
                    : (_processing ? AppColors.success : (isDark ? AppColors.white : AppColors.black)),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: _processing ? appShadowLg : appShadowMd,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: AppAnimations.fast,
                  child: Text(
                    _processing 
                        ? (store.orders.any((o) => o.status == 'Visit Scheduled') ? 'Updating...' : 'Confirming...') 
                        : (_complete ? (store.orders.any((o) => o.status == 'Visit Scheduled') ? 'Updated' : 'Confirmed') 
                        : (store.orders.any((o) => o.status == 'Visit Scheduled') ? 'Hold to Update Visit' : 'Hold to Confirm Visit')),
                    key: ValueKey(_processing || _complete),
                    style: TextStyle(
                      color: isDark && !_processing && !_complete ? AppColors.black : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Center(
            child: Text(
              'No payment required. Pay at the store after testing.',
              style: TextStyle(color: AppColors.mediumGray, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(AppStore store, bool isDark) {
    final orderId = store.orders.isNotEmpty ? store.orders.first.id : 'AT-1001';
    final visitDateTime = DateTime(
      _visitDate.year,
      _visitDate.month,
      _visitDate.day,
      _visitTime.hour,
      _visitTime.minute,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              const Icon(CupertinoIcons.checkmark_seal_fill, color: AppColors.success, size: 64),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Visit Scheduled!',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text(
                'Reservation ID: $orderId',
                style: const TextStyle(color: AppColors.mediumGray, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkGray.withAlpha(120) : AppColors.lightGray.withAlpha(80),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Visit Details',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Time: ${DateFormat('MMM dd, yyyy').format(visitDateTime)} at ${visitDateTime.hour.toString().padLeft(2, '0')}:${visitDateTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: AppColors.mediumGray, fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Name: ${_nameController.text}',
                style: const TextStyle(color: AppColors.mediumGray, fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Phone: ${_phoneController.text}',
                style: const TextStyle(color: AppColors.mediumGray, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),

        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(60),
            backgroundColor: AppColors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          ),
          child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ),
      ],
    );
  }
}
