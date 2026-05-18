part of '../main.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, this.trailing, super.key});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
      ],
    );
  }
}

class StockBanner extends StatelessWidget {
  const StockBanner({required this.stock, super.key});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final low = stock <= 4;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: low
            ? Colors.orange.withAlpha(32)
            : Theme.of(context).colorScheme.primary.withAlpha(24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            low
                ? CupertinoIcons.exclamationmark_triangle
                : CupertinoIcons.cube_box,
            color: low ? Colors.orange : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              low ? 'Only $stock left in stock' : '$stock available now',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
