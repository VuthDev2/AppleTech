part of '../../main.dart';

class BagScreen extends StatelessWidget {
  const BagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final scheduledVisits = store.orders
        .where((order) => order.status == 'Visit Scheduled')
        .toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFF5F5F5), // Light gray background like inspiration
      appBar: AppBar(
        leadingWidth: 72,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface1 : Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(CupertinoIcons.chevron_left, size: 20),
              onPressed: () => store.setTab(0),
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
        title: Text(
          'Cart',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: isDark ? Colors.white : Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: const [],
      ),
      body: AnimatedSwitcher(
        duration: AppAnimations.normal,
        child: store.bag.isEmpty && scheduledVisits.isEmpty
            ? EmptyState(
                icon: CupertinoIcons.bag,
                title:
                    AppLocalizations.of(context)?.emptyBag ??
                    'Your Bag is empty',
                subtitle:
                    AppLocalizations.of(context)?.bagEmptyDesc ??
                    'Items you add to your bag will appear here. They will stay here until you are ready to checkout.',
                customArt: const BagEmptyArt(),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      key: const ValueKey('cart_list'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      children: [
                        if (scheduledVisits.isNotEmpty)
                          ScheduledVisitsPanel(visits: scheduledVisits),
                        
                        for (final item in store.bag) ...[
                          _CartItemWrapper(item: item, store: store),
                          const SizedBox(height: 16),
                        ],

                        if (store.bag.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _PromoCodeField(store: store),
                          const SizedBox(height: 32),
                          _buildOrderSummary(context, store),
                        ],
                        
                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      bottomSheet: store.bag.isEmpty ? null : const CheckoutSummarySheet(),
    );
  }

  void _showClearBagDialog(BuildContext context, AppStore store) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Clear Bag', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to remove all items from your bag?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.mediumGray)),
          ),
          TextButton(
            onPressed: () {
              store.clearBag();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, AppStore store) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface1 : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Subtotal:', value: store.total),
          const SizedBox(height: 16),
          const _SummaryRow(label: 'Taxes:', value: 0),
          const SizedBox(height: 16),
          const _SummaryRow(label: 'Shipping:', value: 0, isFree: true),
          if (store.appliedPromoCode != null) ...[
            const SizedBox(height: 16),
            const _SummaryRow(label: 'Discount:', value: 0, isDiscount: true),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          ),
          _SummaryRow(label: 'Total', value: store.total, isTotal: true),
        ],
      ),
    );
  }
}

class _CartItemWrapper extends StatelessWidget {
  const _CartItemWrapper({required this.item, required this.store});
  final CartItem item;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('${item.productId}-${item.variantId}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        store.removeFromBag(item);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item removed from cart'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(CupertinoIcons.trash, color: Colors.white),
      ),
      child: CartItemTile(item: item),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.isFree = false,
    this.isDiscount = false,
  });

  final String label;
  final int value;
  final bool isTotal;
  final bool isFree;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            fontSize: isTotal ? 18 : 14,
            color: isTotal 
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? Colors.white70 : Colors.grey[600]),
          ),
        ),
        Text(
          isFree ? 'Free' : (isDiscount ? '-\$0' : '\$${value.toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}') ,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            fontSize: isTotal ? 20 : 15,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}

class ScheduledVisitsPanel extends StatelessWidget {
  const ScheduledVisitsPanel({required this.visits, super.key});

  final List<OrderRecord> visits;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scheduled Store Visits',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
          ),
          const SizedBox(height: 16),
          for (final visit in visits) ...[
            _ScheduledVisitCard(visit: visit),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _ScheduledVisitCard extends StatelessWidget {
  const _ScheduledVisitCard({required this.visit});

  final OrderRecord visit;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final visitTime = visit.visitTime;
    final scheduleText = visitTime == null
        ? 'Time not selected'
        : '${DateFormat('MMM dd').format(visitTime)} at ${DateFormat('h:mm a').format(visitTime)}';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface1 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.checkmark_seal_fill, color: AppColors.success, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visit Scheduled',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    Text(
                      scheduleText,
                      style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => store.cancelVisit(visit.id),
                icon: Icon(CupertinoIcons.xmark_circle_fill, color: isDark ? Colors.white30 : Colors.black26, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                for (final item in visit.items) ...[
                  _ScheduledVisitProductRow(item: item),
                  if (item != visit.items.last) 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(height: 1, color: isDark ? Colors.white10 : Colors.black12),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total To Pay', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  Text(
                    '\$${visit.total}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => MultiStepCheckoutSheet(editOrderId: visit.id),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 0,
                ),
                icon: const Icon(CupertinoIcons.pencil, size: 14),
                label: const Text('Edit Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduledVisitProductRow extends StatelessWidget {
  const _ScheduledVisitProductRow({required this.item, super.key});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final product = store.productById(item.productId);
    final variant = store.variantById(item.productId, item.variantId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ProductImageBox(
            imagePath: product.imagePath,
            category: product.category,
            fit: BoxFit.contain,
            animate: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              Text(
                '${variant.colorName} • ${variant.storage}',
                maxLines: 1,
                style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Qty: ${item.quantity}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface1 : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Container
          Container(
            width: 90,
            height: 90,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white12 : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ProductImageBox(
              imagePath: product.imagePath,
              category: product.category,
              fit: BoxFit.contain,
              animate: false,
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${variant.storage}   Color: ${variant.colorName}',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        '\$${(variant.price * item.quantity).toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]},")}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // Quantity Dropdown style
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                            border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFE5E5E5)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${item.quantity}',
                                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isDark ? Colors.white : Colors.black),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                CupertinoIcons.chevron_down,
                                size: 12,
                                color: isDark ? Colors.white60 : Colors.black87,
                              ),
                            ],
                          ),
                        ).onTap(() {
                           _showQuantityPicker(context, store, item);
                        }),
                        const SizedBox(width: 8),
                        // Trash Icon
                        GestureDetector(
                          onTap: () => store.removeFromBag(item),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.trash,
                              size: 16,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Individual Checkout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => MultiStepCheckoutSheet(checkoutItems: [item]),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Reserve This Item Only',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQuantityPicker(BuildContext context, AppStore store, CartItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('Select Quantity', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 10,
                padding: const EdgeInsets.only(bottom: 24),
                itemBuilder: (context, index) {
                  final q = index + 1;
                  return ListTile(
                    title: Text('$q', textAlign: TextAlign.center, style: TextStyle(fontWeight: q == item.quantity ? FontWeight.w900 : FontWeight.w500)),
                    onTap: () {
                      store.updateQuantity(item, q);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension OnTapExtension on Widget {
  Widget onTap(VoidCallback action) {
    return GestureDetector(
      onTap: action,
      child: this,
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
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: FilledButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const MultiStepCheckoutSheet(),
        ),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(64),
          backgroundColor: const Color.fromARGB(255, 27, 25, 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          elevation: 0,
        ),
        child: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
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
  @override
  void initState() {
    super.initState();
    if (widget.store.appliedPromoCode != null) _controller.text = widget.store.appliedPromoCode!;
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final hasPromo = widget.store.appliedPromoCode != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface1 : Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Expanded(
            child: TextFormField(
              controller: _controller,
              enabled: !hasPromo,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'Enter promo code',
                hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: FilledButton(
              onPressed: () {
                if (hasPromo) {
                  widget.store.clearPromoCode();
                  _controller.clear();
                } else {
                  if (_controller.text.isNotEmpty) widget.store.applyPromoCode(_controller.text);
                }
                setState(() {});
              },
              style: FilledButton.styleFrom(
                backgroundColor: hasPromo ? AppColors.error : const Color.fromARGB(255, 151, 162, 186),
                foregroundColor: Colors.black,
                minimumSize: const Size(120, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Text(
                hasPromo ? 'Remove' : 'Apply code',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class MultiStepCheckoutSheet extends StatefulWidget {
  const MultiStepCheckoutSheet({this.editOrderId, this.checkoutItems, super.key});

  final String? editOrderId;
  final List<CartItem>? checkoutItems;

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
  OrderRecord? _editingVisit;

  bool get _isEditing => widget.editOrderId != null;

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
      final existingVisit = widget.editOrderId == null
          ? null
          : store.orders.cast<OrderRecord?>().firstWhere(
              (o) => o?.id == widget.editOrderId,
              orElse: () => null,
            );

      if (existingVisit != null) {
        _editingVisit = existingVisit;
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
    final today = DateUtils.dateOnly(DateTime.now());
    final initialDate = _visitDate.isBefore(today) ? today : _visitDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
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
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            AppSpacing.xxl,
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
            _isEditing ? 'Edit Store Visit' : 'Plan Your Store Visit',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _isEditing
                ? 'Update this visit without changing your other scheduled visits.'
                : 'Tell us when you are coming and we will have your items ready for testing.',
            style: TextStyle(color: AppColors.mediumGray, fontSize: 14),
          ),
          if (_editingVisit != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Reservation ${_editingVisit!.id} • ${_editingVisit!.items.length} item${_editingVisit!.items.length == 1 ? '' : 's'}',
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (widget.checkoutItems != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Checking out ${widget.checkoutItems!.length} specific item${widget.checkoutItems!.length == 1 ? '' : 's'}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
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

          Text(
            'Expected Visit Time',
            style: Theme.of(context).textTheme.labelLarge,
          ),
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
                      color: isDark
                          ? AppColors.white.withAlpha(20)
                          : AppColors.lightGray.withAlpha(100),
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
                      color: isDark
                          ? AppColors.white.withAlpha(20)
                          : AppColors.lightGray.withAlpha(100),
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
                  final editOrderId = widget.editOrderId;
                  if (editOrderId == null) {
                    store.completeCheckout(
                      customerName: _nameController.text.trim(),
                      customerPhone: _phoneController.text.trim(),
                      customerAddress: _addressController.text.trim(),
                      visitTime: visitDateTime,
                      specificItems: widget.checkoutItems,
                    );
                  } else {
                    store.updateVisit(
                      orderId: editOrderId,
                      customerName: _nameController.text.trim(),
                      customerPhone: _phoneController.text.trim(),
                      customerAddress: _addressController.text.trim(),
                      visitTime: visitDateTime,
                    );
                    _editingVisit = store.orders.firstWhere(
                      (order) => order.id == editOrderId,
                    );
                  }
                } catch (e) {
                  debugPrint('Visit saved locally: $e');
                }

                setState(() {
                  _currentStep = 2;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Please fill out your name and phone number.',
                    ),
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
                    : (_processing
                          ? AppColors.success
                          : (isDark ? AppColors.white : AppColors.black)),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: _processing ? appShadowLg : appShadowMd,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: AppAnimations.fast,
                  child: Text(
                    _processing
                        ? (_isEditing ? 'Updating...' : 'Confirming...')
                        : (_complete
                              ? (_isEditing ? 'Updated' : 'Confirmed')
                              : (_isEditing
                                    ? 'Hold to Update Visit'
                                    : 'Hold to Confirm Visit')),
                    key: ValueKey(_processing || _complete),
                    style: TextStyle(
                      color: isDark && !_processing && !_complete
                          ? AppColors.black
                          : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
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
    final orderId =
        widget.editOrderId ??
        (store.orders.isNotEmpty ? store.orders.first.id : 'AT-1001');
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
              const Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: AppColors.success,
                size: 64,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Visit Saved!',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Reservation ID: $orderId',
                style: const TextStyle(
                  color: AppColors.mediumGray,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkGray.withAlpha(120)
                : AppColors.lightGray.withAlpha(80),
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
                style: const TextStyle(
                  color: AppColors.mediumGray,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Name: ${_nameController.text}',
                style: const TextStyle(
                  color: AppColors.mediumGray,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Phone: ${_phoneController.text}',
                style: const TextStyle(
                  color: AppColors.mediumGray,
                  fontSize: 13,
                ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
          ),
          child: const Text(
            'Got it',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
