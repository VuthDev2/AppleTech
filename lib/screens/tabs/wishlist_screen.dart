part of '../../main.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final saved = store.wishlist.map(store.productById).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: saved.isEmpty
          ? const EmptyState(
              icon: CupertinoIcons.heart,
              title: 'No saved products yet',
              subtitle: 'Tap the heart on a product to pin it here.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: saved.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.76,
              ),
              itemBuilder: (context, index) {
                final product = saved[index];
                return Dismissible(
                  key: ValueKey(product.id),
                  direction: DismissDirection.up,
                  onDismissed: (_) => store.toggleWishlist(product.id),
                  child: ProductGridCard(product: product),
                );
              },
            ),
    );
  }
}
