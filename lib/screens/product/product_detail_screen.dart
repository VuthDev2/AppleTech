part of '../../main.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({required this.product, super.key});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Variant selected = widget.product.variants.first;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final isSaved = store.wishlist.contains(widget.product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.category),
        actions: [
          IconButton(
            tooltip: isSaved ? 'Remove from wishlist' : 'Add to wishlist',
            onPressed: () => store.toggleWishlist(widget.product.id),
            icon: Icon(
              isSaved ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              color: isSaved ? Colors.redAccent : null,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 270,
            decoration: BoxDecoration(
              color: selected.color.withAlpha(190),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Center(
              child: Hero(
                tag: 'product-${widget.product.id}',
                child: Icon(
                  widget.product.icon,
                  size: 150,
                  color: selected.color.computeLuminance() > 0.6
                      ? Colors.black54
                      : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.product.name,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.description,
            style: TextStyle(
              height: 1.45,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '\$${selected.price}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 22),
          SectionTitle(title: 'Finish', trailing: selected.colorName),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            children: [
              for (final variant in widget.product.variants)
                Tooltip(
                  message: variant.colorName,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => setState(() => selected = variant),
                    child: Container(
                      width: 46,
                      height: 46,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: selected.id == variant.id ? 3 : 1,
                          color: selected.id == variant.id
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: variant.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          const SectionTitle(title: 'Storage / band'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final variant in widget.product.variants)
                ChoiceChip(
                  label: Text(variant.storage),
                  selected: selected.id == variant.id,
                  onSelected: (_) => setState(() => selected = variant),
                ),
            ],
          ),
          const SizedBox(height: 22),
          StockBanner(stock: selected.stock),
          const SizedBox(height: 22),
          for (final spec in widget.product.specs)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(CupertinoIcons.check_mark_circled),
              title: Text(spec),
            ),
        ],
      ),
      bottomSheet: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: FilledButton.icon(
            onPressed: selected.stock == 0
                ? null
                : () {
                    store.addToBag(widget.product, selected);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.product.name} added to Bag'),
                      ),
                    );
                  },
            icon: const Icon(CupertinoIcons.bag_badge_plus),
            label: Text('Add to Bag - \$${selected.price}'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
