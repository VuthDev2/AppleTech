part of '../../main.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final featured = store.products.where((p) => p.featured).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AppleTech',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'Premium hardware, configured your way.',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Toggle theme',
                      onPressed: store.toggleTheme,
                      icon: Icon(
                        store.isDarkMode
                            ? CupertinoIcons.sun_max
                            : CupertinoIcons.moon,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) =>
                      HeroProductCard(product: featured[index]),
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemCount: featured.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 54,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final category = categories[index + 1];
                    return ActionChip(
                      avatar: Icon(categoryIcon(category), size: 18),
                      label: Text(category),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CategoryScreen(category: category),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemCount: categories.length - 1,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              sliver: SliverList.separated(
                itemBuilder: (context, index) =>
                    ProductListTile(product: store.products[index]),
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemCount: store.products.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
