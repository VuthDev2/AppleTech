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
                  // Clear bag or something
                },
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
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
            : ListView.separated(
                key: const ValueKey('bag_list'),
                padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, 250),
                itemCount: store.bag.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
                itemBuilder: (context, index) => CartItemTile(item: store.bag[index]),
              ),
      ),
      bottomSheet: store.bag.isEmpty ? null : const CheckoutSummarySheet(),
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
                          Text(
                            '\$${variant.price}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
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
              minimumSize: const Size.fromHeight(64),
              backgroundColor: AppColors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.creditcard_fill, size: 20),
                const SizedBox(width: AppSpacing.md),
                Text('${AppLocalizations.of(context)?.checkout ?? 'Checkout'} - \$${store.total}'),
              ],
            ),
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
  int _currentStep = 1; // 1: Shipping, 2: Payment, 3: Face ID, 4: Success
  ShippingAddress? _selectedAddress;
  PaymentCard? _selectedCard;
  String _paymentMethod = 'Apple Pay'; // 'Apple Pay' or 'Credit Card'
  
  bool _isAddingAddress = false;
  bool _isAddingCard = false;
  bool _processing = false;
  bool _complete = false;

  // Address form fields
  final _addrFormKey = GlobalKey<FormState>();
  final _addrNameController = TextEditingController();
  final _addrStreetController = TextEditingController();
  final _addrCityController = TextEditingController();
  final _addrPostalController = TextEditingController();
  final _addrPhoneController = TextEditingController();

  // Card form fields
  final _cardFormKey = GlobalKey<FormState>();
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  String _cardBrand = 'Visa';
  Color _cardColor = const Color(0xFF0071E3);

  @override
  void dispose() {
    _addrNameController.dispose();
    _addrStreetController.dispose();
    _addrCityController.dispose();
    _addrPostalController.dispose();
    _addrPhoneController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Auto-select defaults
    if (_selectedAddress == null && store.addresses.isNotEmpty) {
      _selectedAddress = store.addresses.firstWhere((a) => a.isDefault, orElse: () => store.addresses.first);
    }
    if (_selectedCard == null && store.cards.isNotEmpty) {
      _selectedCard = store.cards.first;
    }

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
              // Top drag pill
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

              // Title and Header
              if (_currentStep < 4) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _stepTitle(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Step $_currentStep of 3',
                      style: TextStyle(
                        color: AppColors.mediumGray,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],

              // STEP 1: SHIPPING ADDRESS
              if (_currentStep == 1) _buildShippingStep(store, isDark),

              // STEP 2: PAYMENT METHOD
              if (_currentStep == 2) _buildPaymentStep(store, isDark),

              // STEP 3: FACE ID BIOMETRIC CONFIRMATION
              if (_currentStep == 3) _buildFaceIdStep(store, isDark),

              // STEP 4: ORDER SUCCESS RECEIPT
              if (_currentStep == 4) _buildSuccessStep(store, isDark),
            ],
          ),
        ),
      ),
    );
  }

  String _stepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Shipping Address';
      case 2:
        return 'Payment Method';
      case 3:
        return 'Express Checkout';
      default:
        return 'Success';
    }
  }

  Widget _buildShippingStep(AppStore store, bool isDark) {
    if (_isAddingAddress) {
      return Form(
        key: _addrFormKey,
        child: Column(
          children: [
            ProfessionalTextField(
              controller: _addrNameController,
              hintText: 'e.g. Kry Saravuth',
              label: 'Full Name',
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            ProfessionalTextField(
              controller: _addrStreetController,
              hintText: 'Street address, Suite, Apt...',
              label: 'Street Address',
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ProfessionalTextField(
                    controller: _addrCityController,
                    hintText: 'e.g. Cupertino, CA',
                    label: 'City & State',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: ProfessionalTextField(
                    controller: _addrPostalController,
                    hintText: 'e.g. 95014',
                    label: 'Postal Code',
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ProfessionalTextField(
              controller: _addrPhoneController,
              hintText: '+1 (555) 000-0000',
              label: 'Phone Number',
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isAddingAddress = false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_addrFormKey.currentState!.validate()) {
                        final newAddr = ShippingAddress(
                          id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
                          fullName: _addrNameController.text.trim(),
                          street: _addrStreetController.text.trim(),
                          city: _addrCityController.text.trim(),
                          postalCode: _addrPostalController.text.trim(),
                          phone: _addrPhoneController.text.trim(),
                          isDefault: store.addresses.isEmpty,
                        );
                        store.addAddress(newAddr);
                        setState(() {
                          _selectedAddress = newAddr;
                          _isAddingAddress = false;
                        });
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: AppColors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                    ),
                    child: const Text('Save Address'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...store.addresses.map((addr) {
          final isSelected = _selectedAddress?.id == addr.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: InkWell(
              onTap: () => setState(() => _selectedAddress = addr),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkGray.withAlpha(120) : AppColors.lightGray.withAlpha(100),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                      color: isSelected ? AppColors.primary : AppColors.mediumGray,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addr.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${addr.street}, ${addr.city} ${addr.postalCode}',
                            style: TextStyle(color: AppColors.mediumGray, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            addr.phone,
                            style: TextStyle(color: AppColors.mediumGray, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.md),
        TextButton.icon(
          onPressed: () => setState(() {
            _addrNameController.clear();
            _addrStreetController.clear();
            _addrCityController.clear();
            _addrPostalController.clear();
            _addrPhoneController.clear();
            _isAddingAddress = true;
          }),
          icon: const Icon(CupertinoIcons.add),
          label: const Text('Add New Shipping Address'),
        ),
        const SizedBox(height: AppSpacing.xxl),
        FilledButton(
          onPressed: _selectedAddress == null
              ? null
              : () => setState(() => _currentStep = 2),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: AppColors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          ),
          child: const Text('Continue to Payment', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _buildPaymentStep(AppStore store, bool isDark) {
    if (_isAddingCard) {
      return Form(
        key: _cardFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Glassmorphic card preview!
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              child: GlassmorphicCreditCard(
                cardholderName: _cardNameController.text.isEmpty ? 'YOUR NAME' : _cardNameController.text,
                cardNumber: _cardNumberController.text.isEmpty ? '•••• •••• •••• ••••' : _cardNumberController.text,
                expiryDate: _cardExpiryController.text.isEmpty ? 'MM/YY' : _cardExpiryController.text,
                brand: _cardBrand,
                themeColor: _cardColor,
              ),
            ),
            
            ProfessionalTextField(
              controller: _cardNameController,
              hintText: 'e.g. Kry Saravuth',
              label: 'Cardholder Name',
              onChanged: (_) => setState(() {}),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            ProfessionalTextField(
              controller: _cardNumberController,
              hintText: '4242 4242 4242 4242',
              label: 'Card Number',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ProfessionalTextField(
                    controller: _cardExpiryController,
                    hintText: 'MM/YY',
                    label: 'Expiry Date',
                    onChanged: (_) => setState(() {}),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: ProfessionalTextField(
                    controller: _cardCvvController,
                    hintText: '123',
                    label: 'CVV',
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.trim().length != 3 ? 'Invalid' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Choose card color/theme!
            Text('Card Color Theme', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _colorOption(const Color(0xFF0071E3)), // Apple Blue
                _colorOption(const Color(0xFF1F1F1F)), // Space Black
                _colorOption(const Color(0xFFE55A5A)), // Red Rose
                _colorOption(const Color(0xFF27AE60)), // Forest Green
                _colorOption(const Color(0xFF8E44AD)), // Premium Purple
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isAddingCard = false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_cardFormKey.currentState!.validate()) {
                        final newCard = PaymentCard(
                          id: 'card-${DateTime.now().millisecondsSinceEpoch}',
                          cardholderName: _cardNameController.text.trim(),
                          cardNumber: '•••• •••• •••• ${_cardNumberController.text.trim().substring(math.max(0, _cardNumberController.text.trim().length - 4))}',
                          expiryDate: _cardExpiryController.text.trim(),
                          cvv: _cardCvvController.text.trim(),
                          brand: _cardBrand,
                          themeColor: _cardColor,
                        );
                        store.addCard(newCard);
                        setState(() {
                          _selectedCard = newCard;
                          _isAddingCard = false;
                        });
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: AppColors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                    ),
                    child: const Text('Save Card'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Method toggler
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                avatar: const Icon(CupertinoIcons.device_phone_portrait, size: 16),
                label: const Text('Apple Pay'),
                selected: _paymentMethod == 'Apple Pay',
                onSelected: (val) {
                  if (val) setState(() => _paymentMethod = 'Apple Pay');
                },
                showCheckmark: false,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _paymentMethod == 'Apple Pay' ? AppColors.white : AppColors.black,
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: ChoiceChip(
                avatar: const Icon(CupertinoIcons.creditcard, size: 16),
                label: const Text('Credit Card'),
                selected: _paymentMethod == 'Credit Card',
                onSelected: (val) {
                  if (val) setState(() => _paymentMethod = 'Credit Card');
                },
                showCheckmark: false,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _paymentMethod == 'Credit Card' ? AppColors.white : AppColors.black,
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        if (_paymentMethod == 'Apple Pay') ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkGray.withAlpha(120) : AppColors.lightGray.withAlpha(100),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.success, size: 24),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Apple Pay Active',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Confirm using your biometric security on step 3.',
                        style: TextStyle(color: AppColors.mediumGray, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Saved cards horizontal list!
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: store.cards.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final card = store.cards[index];
                final isSelected = _selectedCard?.id == card.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCard = card),
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 280,
                        child: GlassmorphicCreditCard(
                          cardholderName: card.cardholderName,
                          cardNumber: card.cardNumber,
                          expiryDate: card.expiryDate,
                          brand: card.brand,
                          themeColor: card.themeColor,
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(CupertinoIcons.checkmark_circle_fill, color: AppColors.primary, size: 22),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() {
                _cardNameController.clear();
                _cardNumberController.clear();
                _cardExpiryController.clear();
                _cardCvvController.clear();
                _cardBrand = 'Visa';
                _cardColor = const Color(0xFF0071E3);
                _isAddingCard = true;
              }),
              icon: const Icon(CupertinoIcons.add),
              label: const Text('Add New Payment Card'),
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.xxl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
                ),
                child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: FilledButton(
                onPressed: (_paymentMethod == 'Credit Card' && _selectedCard == null)
                    ? null
                    : () => setState(() => _currentStep = 3),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: AppColors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
                ),
                child: const Text('Confirm Details', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _colorOption(Color color) {
    final isSelected = _cardColor == color;
    return GestureDetector(
      onTap: () => setState(() => _cardColor = color),
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.md),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: appShadowSm,
        ),
      ),
    );
  }

  Widget _buildFaceIdStep(AppStore store, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: (_complete ? AppColors.success : AppColors.primary).withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: AppAnimations.normal,
              child: Icon(
                _complete
                    ? CupertinoIcons.check_mark_circled_solid
                    : Icons.face_retouching_natural,
                key: ValueKey(_complete),
                color: _complete ? AppColors.success : AppColors.primary,
                size: 46,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          _complete ? 'Order Success!' : 'Confirm Order',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _complete
              ? 'Biometric authorization successful.'
              : 'Press & hold the Apple Pay bar to authenticate \$${store.total}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.mediumGray,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        
        // Dynamic press and hold authentication bar!
        GestureDetector(
          onLongPressStart: (_) async {
            if (_complete) return;
            setState(() => _processing = true);
            
            // Apple-style biometric processing simulation
            await Future<void>.delayed(const Duration(milliseconds: 1400));
            if (!mounted) return;
            
            setState(() {
              _processing = false;
              _complete = true;
            });
            
            await Future<void>.delayed(const Duration(milliseconds: 800));
            if (!mounted) return;
            setState(() {
              _currentStep = 4;
            });
            // Complete checkout in the store which generates OrderRecord and empties the bag!
            store.completeCheckout();
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
                      ? 'Authorizing...' 
                      : (_complete ? 'Success' : 'Hold to Authorize'),
                  key: ValueKey(_processing || _complete),
                  style: TextStyle(
                    color: isDark && !_processing && !_complete ? AppColors.black : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 2),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
                ),
                child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessStep(AppStore store, bool isDark) {
    // Generate order receipt details before popping
    final orderId = store.orders.isNotEmpty ? store.orders.first.id : 'AT-1001';
    final shippingTo = _selectedAddress != null 
        ? '${_selectedAddress!.fullName}\n${_selectedAddress!.street}, ${_selectedAddress!.city}'
        : 'Store Pickup';
    
    final paidWith = _paymentMethod == 'Apple Pay' 
        ? 'Apple Pay (Biometric)' 
        : (_selectedCard != null ? '${_selectedCard!.brand} ending in ${_selectedCard!.cardNumber.substring(_selectedCard!.cardNumber.length - 4)}' : 'Credit Card');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              const Icon(CupertinoIcons.checkmark_seal_fill, color: AppColors.success, size: 64),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Order Confirmed!',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text(
                'Order ID: $orderId',
                style: const TextStyle(color: AppColors.mediumGray, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),

        // Receipt Summary Box
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
                'Delivery Information',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                shippingTo,
                style: const TextStyle(color: AppColors.mediumGray, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Payment Method',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                paidWith,
                style: const TextStyle(color: AppColors.mediumGray, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),

        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                content: const Row(
                  children: [
                    Icon(CupertinoIcons.cube_box_fill, color: AppColors.white),
                    SizedBox(width: AppSpacing.md),
                    Text('Order placed successfully! Track status in Profile.'),
                  ],
                ),
              ),
            );
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(60),
            backgroundColor: AppColors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
          ),
          child: const Text('Track Order Status', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ),
      ],
    );
  }
}

class GlassmorphicCreditCard extends StatelessWidget {
  const GlassmorphicCreditCard({
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.brand,
    required this.themeColor,
    super.key,
  });

  final String cardholderName;
  final String cardNumber;
  final String expiryDate;
  final String brand;
  final Color themeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeColor.withAlpha(230), themeColor.withAlpha(120)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.white.withAlpha(60)),
        boxShadow: appShadowSm,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(CupertinoIcons.creditcard, color: AppColors.white, size: 28),
              Text(
                brand,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            cardNumber,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARDHOLDER',
                    style: TextStyle(
                      color: AppColors.white.withAlpha(150),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cardholderName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: AppColors.white.withAlpha(150),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expiryDate,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
