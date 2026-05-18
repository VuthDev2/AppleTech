part of '../main.dart';

class StoreShell extends StatefulWidget {
  const StoreShell({super.key});

  @override
  State<StoreShell> createState() => _StoreShellState();
}

class _StoreShellState extends State<StoreShell> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final screens = <Widget>[
      const HomeScreen(),
      const ExploreScreen(),
      const WishlistScreen(),
      const BagScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: tabIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabIndex,
        onDestinationSelected: (index) => setState(() => tabIndex = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(CupertinoIcons.house),
            selectedIcon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(CupertinoIcons.search),
            label: 'Explore',
          ),
          const NavigationDestination(
            icon: Icon(CupertinoIcons.heart),
            selectedIcon: Icon(CupertinoIcons.heart_fill),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Badge.count(
              count: store.bagCount,
              isLabelVisible: store.bagCount > 0,
              child: const Icon(CupertinoIcons.bag),
            ),
            selectedIcon: Badge.count(
              count: store.bagCount,
              isLabelVisible: store.bagCount > 0,
              child: const Icon(CupertinoIcons.bag_fill),
            ),
            label: 'Bag',
          ),
          const NavigationDestination(
            icon: Icon(CupertinoIcons.person_crop_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
