part of '../../main.dart';

class BagScreen extends StatelessWidget {
  const BagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Bag')),
      body: store.bag.isEmpty
          ? const EmptyState(
              icon: CupertinoIcons.bag,
              title: 'Your bag is empty',
              subtitle: 'Configure a device and add it to your bag.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 170),
              children: [
                for (final item in store.bag) CartItemTile(item: item),
              ],
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          ProductGlyph(
            product: product,
            size: 72,
            overrideColor: variant.color,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${variant.colorName} - ${variant.storage}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${variant.price * item.quantity}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          QuantityStepper(
            quantity: item.quantity,
            onMinus: () => store.updateQuantity(item, item.quantity - 1),
            onPlus: () => store.updateQuantity(item, item.quantity + 1),
          ),
        ],
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Decrease',
            onPressed: onMinus,
            icon: const Icon(CupertinoIcons.minus, size: 16),
          ),
          SizedBox(
            width: 20,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            tooltip: 'Increase',
            onPressed: onPlus,
            icon: const Icon(CupertinoIcons.plus, size: 16),
          ),
        ],
      ),
    );
  }
}

class CheckoutSummarySheet extends StatelessWidget {
  const CheckoutSummarySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(24),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PriceRow(label: 'Subtotal', amount: store.subtotal),
            PriceRow(label: 'Estimated tax', amount: store.tax),
            const Divider(height: 22),
            PriceRow(label: 'Total', amount: store.total, isTotal: true),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const BiometricCheckoutSheet(),
              ),
              icon: const Icon(Icons.face_retouching_natural),
              label: const Text('Checkout with Face ID'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceRow extends StatelessWidget {
  const PriceRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
    super.key,
  });

  final String label;
  final int amount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isTotal ? 20 : 15,
      fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text('\$$amount', style: style),
        ],
      ),
    );
  }
}

class BiometricCheckoutSheet extends StatefulWidget {
  const BiometricCheckoutSheet({super.key});

  @override
  State<BiometricCheckoutSheet> createState() => _BiometricCheckoutSheetState();
}

class _BiometricCheckoutSheetState extends State<BiometricCheckoutSheet> {
  bool processing = false;
  bool complete = false;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(24),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                complete
                    ? CupertinoIcons.check_mark_circled_solid
                    : Icons.face_retouching_natural,
                color: complete
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              complete ? 'Order placed' : 'AppleTech Pay',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              complete
                  ? 'Your receipt is now available in Profile.'
                  : 'Hold to authorize \$${store.total} with simulated Face ID.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onLongPressStart: (_) async {
                final navigator = Navigator.of(context);
                setState(() => processing = true);
                await Future<void>.delayed(const Duration(milliseconds: 850));
                if (!mounted) return;
                store.completeCheckout();
                setState(() {
                  processing = false;
                  complete = true;
                });
                await Future<void>.delayed(const Duration(milliseconds: 800));
                if (mounted) navigator.pop();
              },
              onLongPressEnd: (_) {
                if (!complete) setState(() => processing = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  color: processing
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    processing ? 'Authorizing...' : 'Hold to Pay',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
