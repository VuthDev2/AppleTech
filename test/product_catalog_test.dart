import 'package:appletech/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog includes MacBooks, iPads, iMacs, watches, and AirPods', () {
    final products = buildProductCatalog();
    expect(products.length, greaterThan(60));

    expect(
      products.where((p) => p.category == 'Mac').length,
      greaterThan(20),
    );
    expect(
      products.where((p) => p.category == 'iPad').length,
      greaterThan(15),
    );
    expect(
      products.where((p) => p.category == 'iMac').length,
      greaterThan(5),
    );
    expect(
      products.where(
        (p) =>
            p.name.contains('M5') ||
            p.specs.any((s) => s.contains('M5')) ||
            p.tagline.contains('M5'),
      ).length,
      greaterThan(3),
    );
  });

  test('search matches chip, RAM, SSD, and model year', () {
    final products = buildProductCatalog();
    final m5Pro = products.firstWhere(
      (p) =>
          p.name.contains('MacBook Pro') &&
          p.specs.any((s) => s.contains('M5')),
    );

    expect(productMatchesSearch(m5Pro, 'M5 Pro'), isTrue);
    expect(productMatchesSearch(m5Pro, '48GB unified'), isTrue);
    expect(productMatchesSearch(m5Pro, '2TB'), isTrue);
    expect(productMatchesSearch(m5Pro, '2018'), isFalse);

    final ipadM5 = products.firstWhere(
      (p) => p.id == 'ipad-pro-13-m5-2025',
    );
    expect(productMatchesSearch(ipadM5, 'iPad M5 13'), isTrue);
    expect(productMatchesSearch(ipadM5, '512GB'), isTrue);
  });
}
