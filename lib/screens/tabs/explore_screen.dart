part of '../../main.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String query = '';
  String category = 'All';

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final filtered = store.products.where((product) {
      final matchesCategory = category == 'All' || product.category == category;
      final matchesQuery =
          product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.tagline.toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        children: [
          SearchBar(
            leading: const Icon(CupertinoIcons.search),
            hintText: 'Search MacBook, iPhone, AirPods...',
            onChanged: (value) => setState(() => query = value),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in categories)
                ChoiceChip(
                  avatar: Icon(categoryIcon(item), size: 18),
                  label: Text(item),
                  selected: category == item,
                  onSelected: (_) => setState(() => category = item),
                ),
            ],
          ),
          const SizedBox(height: 22),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.76,
            ),
            itemBuilder: (context, index) =>
                ProductGridCard(product: filtered[index]),
          ),
        ],
      ),
    );
  }
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({required this.category, super.key});

  final String category;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final products = store.products
        .where((product) => product.category == category)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) =>
            ProductListTile(product: products[index]),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemCount: products.length,
      ),
    );
  }
}
