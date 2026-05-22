part of '../main.dart';

/// Builds the full AppleTech product lineup with configurable RAM/SSD variants.
List<Product> buildProductCatalog() {
  return <Product>[
    ..._buildMacBooks(),
    ...buildExpandedAppleCatalog(),
    ..._buildIPads(),
    ..._buildIMacs(),
    ..._buildAppleWatches(),
    ..._buildAirPods(),
    ..._buildIPhones(),
  ];
}

bool productMatchesSearch(Product product, String rawQuery) {
  final q = rawQuery.trim().toLowerCase();
  if (q.isEmpty) return true;

  final tokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  final haystack = StringBuffer()
    ..write(product.name.toLowerCase())
    ..write(' ')
    ..write(product.category.toLowerCase())
    ..write(' ')
    ..write(product.tagline.toLowerCase())
    ..write(' ')
    ..write(product.description.toLowerCase())
    ..write(' ')
    ..write(product.detailedDescription.toLowerCase())
    ..write(' ')
    ..write(product.specs.join(' ').toLowerCase())
    ..write(' ')
    ..write(product.keyFeatures.join(' ').toLowerCase());

  for (final v in product.variants) {
    haystack
      ..write(' ')
      ..write(v.colorName.toLowerCase())
      ..write(' ')
      ..write(v.storage.toLowerCase())
      ..write(' ')
      ..write((v.ram ?? '').toLowerCase())
      ..write(' ')
      ..write((v.ssd ?? '').toLowerCase())
      ..write(' ')
      ..write((v.size ?? '').toLowerCase());
  }

  final text = haystack.toString();
  return tokens.every(text.contains);
}

// ——— Variant builders ———

const _ssdOptions = <String>['256GB', '512GB', '1TB', '2TB', '4TB'];
const _ssdDeltas = <String, int>{
  '256GB': 0,
  '512GB': 200,
  '1TB': 400,
  '2TB': 800,
  '4TB': 1600,
};

const _laptopRamOptions = <String>[
  '8GB unified memory',
  '16GB unified memory',
  '24GB unified memory',
  '32GB unified memory',
  '48GB unified memory',
  '64GB unified memory',
];

const _laptopRamDeltas = <String, int>{
  '8GB unified memory': 0,
  '16GB unified memory': 200,
  '24GB unified memory': 400,
  '32GB unified memory': 600,
  '48GB unified memory': 1000,
  '64GB unified memory': 1400,
};

const _intelRamOptions = <String>['8GB RAM', '16GB RAM', '32GB RAM'];
const _intelRamDeltas = <String, int>{
  '8GB RAM': 0,
  '16GB RAM': 200,
  '32GB RAM': 500,
};

const _ipadStorageOptions = <String>['64GB', '128GB', '256GB', '512GB', '1TB', '2TB'];
const _ipadStorageDeltas = <String, int>{
  '64GB': 0,
  '128GB': 100,
  '256GB': 200,
  '512GB': 400,
  '1TB': 600,
  '2TB': 900,
};

const _ipadRamOptions = <String>[
  '8GB RAM',
  '16GB RAM',
  '24GB RAM',
];

const _ipadRamDeltas = <String, int>{
  '8GB RAM': 0,
  '16GB RAM': 150,
  '24GB RAM': 300,
};

const _macColors = <_ColorOption>[
  _ColorOption('Space Gray', Color(0xFF7D7E80)),
  _ColorOption('Silver', Color(0xFFD9DADB)),
  _ColorOption('Space Black', Color(0xFF303033)),
];

const _airColors = <_ColorOption>[
  _ColorOption('Midnight', Color(0xFF2E3642)),
  _ColorOption('Starlight', Color(0xFFF5E6D3)),
  _ColorOption('Silver', Color(0xFFD9DADB)),
  _ColorOption('Space Gray', Color(0xFF7D7E80)),
];

List<Variant> _buildLaptopVariants({
  required String idPrefix,
  required List<_ColorOption> colors,
  required List<String> sizes,
  required List<String> rams,
  required Map<String, int> ramDeltas,
  required int basePrice,
  int stockSeed = 6,
}) {
  final variants = <Variant>[];
  for (final color in colors) {
    for (final size in sizes) {
      for (final ram in rams) {
        for (final ssd in _ssdOptions) {
          final price = basePrice + (ramDeltas[ram] ?? 0) + (_ssdDeltas[ssd] ?? 0);
          final slug = _slug('${color.name}-$size-$ram-$ssd');
          variants.add(
            Variant(
              id: '$idPrefix-$slug',
              colorName: color.name,
              color: color.color,
              storage: ssd,
              size: size,
              ram: ram,
              ssd: '$ssd SSD',
              price: price,
              stock: stockSeed + slug.hashCode.abs() % 9,
            ),
          );
        }
      }
    }
  }
  return variants;
}

List<Variant> _buildIPadVariants({
  required String idPrefix,
  required List<_ColorOption> colors,
  required List<String> sizes,
  required List<String> rams,
  required int basePrice,
  bool proStorageOnly = false,
}) {
  final storageOpts = proStorageOnly
      ? _ipadStorageOptions.sublist(2)
      : _ipadStorageOptions;
  final variants = <Variant>[];
  for (final color in colors) {
    for (final size in sizes) {
      for (final ram in rams) {
        for (final storage in storageOpts) {
          final price = basePrice + (_ipadRamDeltas[ram] ?? 0) + (_ipadStorageDeltas[storage] ?? 0);
          final slug = _slug('${color.name}-$size-$ram-$storage');
          variants.add(
            Variant(
              id: '$idPrefix-$slug',
              colorName: color.name,
              color: color.color,
              storage: storage,
              size: size,
              ram: ram,
              ssd: '$storage storage',
              price: price,
              stock: 4 + slug.hashCode.abs() % 12,
            ),
          );
        }
      }
    }
  }
  return variants;
}

Product _macProduct({
  required String id,
  required String name,
  required String chip,
  required int year,
  required String tagline,
  required int basePrice,
  required List<String> sizes,
  required List<String> rams,
  required Map<String, int> ramDeltas,
  required List<_ColorOption> colors,
  bool featured = false,
}) {
  final variants = _buildLaptopVariants(
    idPrefix: id,
    colors: colors,
    sizes: sizes,
    rams: rams,
    ramDeltas: ramDeltas,
    basePrice: basePrice,
  );
  return Product(
    id: id,
    name: name,
    category: 'Mac',
    tagline: tagline,
    description:
        '$name with $chip delivers Apple performance in a portable design. Customize memory and SSD before checkout.',
    detailedDescription:
        'Configure $name ($year, $chip) with your preferred unified memory and SSD. ${sizes.join(', ')} display options. Every unit is tested and backed by AppleTech warranty support.',
    basePrice: basePrice,
    specs: [chip, ...sizes, 'Configurable RAM & SSD', 'Retina display', 'macOS'],
    keyFeatures: const [
      'Configurable unified memory',
      'Configurable SSD storage',
      'Multiple finishes',
      'All-day battery life',
      'Studio-quality microphones',
      'Thunderbolt / USB-C connectivity',
    ],
    accent: const Color(0xFF7D8A95),
    icon: CupertinoIcons.device_laptop,
    imagePath: productImageFor(id),
    featured: featured,
    rating: 4.5 + (year % 10) * 0.03,
    reviewCount: 120 + year * 8,
    warranty: '1 Year Limited Warranty, AppleCare+ available',
    inStock: true,
    releaseDate: DateTime(year, 6, 15),
    reviews: _sampleReviews(name),
    variants: variants,
  );
}

List<Product> _buildMacBooks() {
  final products = <Product>[];

  void air({
    required String id,
    required String size,
    required int year,
    required String chip,
    required int base,
    bool featured = false,
  }) {
    final rams = chip.contains('Intel') ? _intelRamOptions : _laptopRamOptions.sublist(1, 5);
    products.add(
      _macProduct(
        id: id,
        name: 'MacBook Air $size ($year)',
        chip: chip,
        year: year,
        tagline: '$chip. Light. Speedy.',
        basePrice: base,
        sizes: [size],
        rams: rams,
        ramDeltas: chip.contains('Intel') ? _intelRamDeltas : _laptopRamDeltas,
        colors: _airColors,
        featured: featured,
      ),
    );
  }

  void pro({
    required String id,
    required String size,
    required int year,
    required String chip,
    required int base,
    bool featured = false,
  }) {
    final rams = chip == 'Intel'
        ? _intelRamOptions
        : chip.contains('M5') || chip.contains('M4')
            ? _laptopRamOptions.sublist(2)
            : _laptopRamOptions.sublist(1, 6);
    products.add(
      _macProduct(
        id: id,
        name: 'MacBook Pro $size ($year)',
        chip: chip,
        year: year,
        tagline: '$chip Pro power for pros.',
        basePrice: base,
        sizes: [size],
        rams: rams,
        ramDeltas: chip == 'Intel' ? _intelRamDeltas : _laptopRamDeltas,
        colors: _macColors,
        featured: featured,
      ),
    );
  }

  // MacBook Air — 2018 through M5
  air(id: 'mba-13-2018', size: '13-inch', year: 2018, chip: 'Intel Core i5', base: 999);
  air(id: 'mba-13-2019', size: '13-inch', year: 2019, chip: 'Intel Core i5', base: 1099);
  air(id: 'mba-13-m1-2020', size: '13-inch', year: 2020, chip: 'Apple M1', base: 999);
  air(id: 'mba-13-m2-2022', size: '13-inch', year: 2022, chip: 'Apple M2', base: 1099);
  air(id: 'mba-13-m3-2024', size: '13-inch', year: 2024, chip: 'Apple M3', base: 1099);
  air(id: 'mba-13-m4-2025', size: '13-inch', year: 2025, chip: 'Apple M4', base: 1199, featured: true);
  air(id: 'mba-15-m2-2023', size: '15-inch', year: 2023, chip: 'Apple M2', base: 1299);
  air(id: 'mba-15-m3-2024', size: '15-inch', year: 2024, chip: 'Apple M3', base: 1299);
  air(id: 'mba-15-m4-2025', size: '15-inch', year: 2025, chip: 'Apple M4', base: 1399, featured: true);
  air(id: 'mba-15-m5-2025', size: '15-inch', year: 2025, chip: 'Apple M5', base: 1499, featured: true);

  // MacBook Pro
  pro(id: 'mbp-13-2018', size: '13-inch', year: 2018, chip: 'Intel', base: 1299);
  pro(id: 'mbp-13-2019', size: '13-inch', year: 2019, chip: 'Intel', base: 1399);
  pro(id: 'mbp-13-m1-2020', size: '13-inch', year: 2020, chip: 'Apple M1', base: 1299);
  pro(id: 'mbp-14-m1p-2021', size: '14-inch', year: 2021, chip: 'Apple M1 Pro', base: 1999);
  pro(id: 'mbp-14-m1m-2021', size: '14-inch', year: 2021, chip: 'Apple M1 Max', base: 2499);
  pro(id: 'mbp-16-m1p-2021', size: '16-inch', year: 2021, chip: 'Apple M1 Pro', base: 2499);
  pro(id: 'mbp-16-m1m-2021', size: '16-inch', year: 2021, chip: 'Apple M1 Max', base: 2999);
  pro(id: 'mbp-14-m2p-2023', size: '14-inch', year: 2023, chip: 'Apple M2 Pro', base: 1999);
  pro(id: 'mbp-14-m2m-2023', size: '14-inch', year: 2023, chip: 'Apple M2 Max', base: 2499);
  pro(id: 'mbp-16-m2p-2023', size: '16-inch', year: 2023, chip: 'Apple M2 Pro', base: 2499);
  pro(id: 'mbp-16-m2m-2023', size: '16-inch', year: 2023, chip: 'Apple M2 Max', base: 2999);
  pro(id: 'mbp-14-m3p-2023', size: '14-inch', year: 2023, chip: 'Apple M3 Pro', base: 1999);
  pro(id: 'mbp-14-m3m-2023', size: '14-inch', year: 2023, chip: 'Apple M3 Max', base: 2599);
  pro(id: 'mbp-16-m3p-2023', size: '16-inch', year: 2023, chip: 'Apple M3 Pro', base: 2499);
  pro(id: 'mbp-16-m3m-2023', size: '16-inch', year: 2023, chip: 'Apple M3 Max', base: 3199);
  pro(id: 'mbp-14-m4p-2024', size: '14-inch', year: 2024, chip: 'Apple M4 Pro', base: 1999, featured: true);
  pro(id: 'mbp-14-m4m-2024', size: '14-inch', year: 2024, chip: 'Apple M4 Max', base: 2599);
  pro(id: 'mbp-16-m4p-2024', size: '16-inch', year: 2024, chip: 'Apple M4 Pro', base: 2499, featured: true);
  pro(id: 'mbp-16-m4m-2024', size: '16-inch', year: 2024, chip: 'Apple M4 Max', base: 3199);
  pro(id: 'mbp-14-m5p-2025', size: '14-inch', year: 2025, chip: 'Apple M5 Pro', base: 2199, featured: true);
  pro(id: 'mbp-14-m5m-2025', size: '14-inch', year: 2025, chip: 'Apple M5 Max', base: 2799, featured: true);
  pro(id: 'mbp-16-m5p-2025', size: '16-inch', year: 2025, chip: 'Apple M5 Pro', base: 2699, featured: true);
  pro(id: 'mbp-16-m5m-2025', size: '16-inch', year: 2025, chip: 'Apple M5 Max', base: 3499, featured: true);

  return products;
}

Product _ipadProduct({
  required String id,
  required String name,
  required String chip,
  required int year,
  required String tagline,
  required int basePrice,
  required List<String> sizes,
  required List<_ColorOption> colors,
  required List<String> rams,
  bool featured = false,
  bool proStorageOnly = false,
}) {
  final variants = _buildIPadVariants(
    idPrefix: id,
    colors: colors,
    sizes: sizes,
    rams: rams,
    basePrice: basePrice,
    proStorageOnly: proStorageOnly,
  );
  return Product(
    id: id,
    name: name,
    category: 'iPad',
    tagline: tagline,
    description:
        '$name powered by $chip. Choose screen size, memory, and storage.',
    detailedDescription:
        'Build your $name ($year) with configurable RAM and storage. Ideal for creativity, study, and mobile productivity.',
    basePrice: basePrice,
    specs: [chip, ...sizes, 'Configurable RAM & storage', 'Liquid Retina display'],
    keyFeatures: const [
      'Configurable memory on supported models',
      'Multiple storage capacities',
      'Apple Pencil support (model dependent)',
      'All-day battery',
      'Center Stage FaceTime camera',
    ],
    accent: const Color(0xFF9EC5DD),
    icon: Icons.tablet_mac,
    imagePath: productImageFor(id),
    featured: featured,
    rating: 4.4 + (year % 8) * 0.04,
    reviewCount: 80 + year * 6,
    warranty: '1 Year Limited Warranty, AppleCare+ available',
    inStock: true,
    releaseDate: DateTime(year, 5, 10),
    reviews: _sampleReviews(name),
    variants: variants,
  );
}

List<Product> _buildIPads() {
  const colors = <_ColorOption>[
    _ColorOption('Space Gray', Color(0xFF7D7E80)),
    _ColorOption('Silver', Color(0xFFD9DADB)),
    _ColorOption('Blue', Color(0xFFA8C7E7)),
  ];
  const proColors = <_ColorOption>[
    _ColorOption('Space Black', Color(0xFF1F1F1F)),
    _ColorOption('Silver', Color(0xFFD9DADB)),
  ];

  return [
    _ipadProduct(
      id: 'ipad-9-2021',
      name: 'iPad (9th gen)',
      chip: 'A13 Bionic',
      year: 2021,
      tagline: 'Powerful. Colorful. Wonderful.',
      basePrice: 329,
      sizes: const ['10.2-inch'],
      colors: colors,
      rams: const ['8GB RAM'],
    ),
    _ipadProduct(
      id: 'ipad-10-2022',
      name: 'iPad (10th gen)',
      chip: 'A14 Bionic',
      year: 2022,
      tagline: 'Lovable. Drawable. Magical.',
      basePrice: 449,
      sizes: const ['10.9-inch'],
      colors: colors,
      rams: const ['8GB RAM'],
    ),
    _ipadProduct(
      id: 'ipad-air-4-2020',
      name: 'iPad Air (4th gen)',
      chip: 'A14 Bionic',
      year: 2020,
      tagline: 'Powerful. Colorful. Wonderful.',
      basePrice: 599,
      sizes: const ['10.9-inch'],
      colors: colors,
      rams: _ipadRamOptions.sublist(0, 2),
    ),
    _ipadProduct(
      id: 'ipad-air-5-2022',
      name: 'iPad Air (5th gen)',
      chip: 'Apple M1',
      year: 2022,
      tagline: 'Light. Bright. M1 inside.',
      basePrice: 599,
      sizes: const ['10.9-inch'],
      colors: colors,
      rams: _ipadRamOptions.sublist(0, 2),
    ),
    _ipadProduct(
      id: 'ipad-air-6-2024',
      name: 'iPad Air (6th gen)',
      chip: 'Apple M2',
      year: 2024,
      tagline: 'Serious performance. Seriously fun.',
      basePrice: 599,
      sizes: const ['11-inch', '13-inch'],
      colors: colors,
      rams: _ipadRamOptions,
    ),
    _ipadProduct(
      id: 'ipad-air-7-2025',
      name: 'iPad Air (7th gen)',
      chip: 'Apple M3',
      year: 2025,
      tagline: 'Now with M3 power.',
      basePrice: 649,
      sizes: const ['11-inch', '13-inch'],
      colors: colors,
      rams: _ipadRamOptions,
      featured: true,
    ),
    _ipadProduct(
      id: 'ipad-mini-5-2019',
      name: 'iPad mini (5th gen)',
      chip: 'A12 Bionic',
      year: 2019,
      tagline: 'Mega power. Mini size.',
      basePrice: 399,
      sizes: const ['7.9-inch'],
      colors: colors,
      rams: const ['8GB RAM'],
    ),
    _ipadProduct(
      id: 'ipad-mini-6-2021',
      name: 'iPad mini (6th gen)',
      chip: 'A15 Bionic',
      year: 2021,
      tagline: 'Mega power. Mini size.',
      basePrice: 499,
      sizes: const ['8.3-inch'],
      colors: colors,
      rams: const ['8GB RAM'],
    ),
    _ipadProduct(
      id: 'ipad-mini-7-2024',
      name: 'iPad mini (7th gen)',
      chip: 'A17 Pro',
      year: 2024,
      tagline: 'The mini with mighty power.',
      basePrice: 499,
      sizes: const ['8.3-inch'],
      colors: colors,
      rams: _ipadRamOptions.sublist(0, 2),
    ),
    _ipadProduct(
      id: 'ipad-pro-11-2018',
      name: 'iPad Pro 11" (2018)',
      chip: 'A12X Bionic',
      year: 2018,
      tagline: 'Supercharged by A12X.',
      basePrice: 799,
      sizes: const ['11-inch'],
      colors: proColors,
      rams: const ['8GB RAM', '16GB RAM'],
      proStorageOnly: true,
    ),
    _ipadProduct(
      id: 'ipad-pro-12-2018',
      name: 'iPad Pro 12.9" (2018)',
      chip: 'A12X Bionic',
      year: 2018,
      tagline: 'The biggest iPad ever.',
      basePrice: 999,
      sizes: const ['12.9-inch'],
      colors: proColors,
      rams: const ['8GB RAM', '16GB RAM'],
      proStorageOnly: true,
    ),
    _ipadProduct(
      id: 'ipad-pro-11-2020',
      name: 'iPad Pro 11" (2020)',
      chip: 'A12Z Bionic',
      year: 2020,
      tagline: 'Your next computer is an iPad.',
      basePrice: 799,
      sizes: const ['11-inch'],
      colors: proColors,
      rams: const ['8GB RAM', '16GB RAM'],
      proStorageOnly: true,
    ),
    _ipadProduct(
      id: 'ipad-pro-12-2020',
      name: 'iPad Pro 12.9" (2020)',
      chip: 'A12Z Bionic',
      year: 2020,
      tagline: 'Your next computer is an iPad.',
      basePrice: 999,
      sizes: const ['12.9-inch'],
      colors: proColors,
      rams: const ['8GB RAM', '16GB RAM'],
      proStorageOnly: true,
    ),
    _ipadProduct(
      id: 'ipad-pro-11-m1-2021',
      name: 'iPad Pro 11" (2021)',
      chip: 'Apple M1',
      year: 2021,
      tagline: 'Unbelievably fast M1.',
      basePrice: 799,
      sizes: const ['11-inch'],
      colors: proColors,
      rams: _ipadRamOptions,
      proStorageOnly: true,
    ),
    _ipadProduct(
      id: 'ipad-pro-12-m1-2021',
      name: 'iPad Pro 12.9" (2021)',
      chip: 'Apple M1',
      year: 2021,
      tagline: 'Unbelievably fast M1.',
      basePrice: 1099,
      sizes: const ['12.9-inch'],
      colors: proColors,
      rams: _ipadRamOptions,
      proStorageOnly: true,
    ),
    _ipadProduct(
      id: 'ipad-pro-11-m2-2022',
      name: 'iPad Pro 11" (2022)',
      chip: 'Apple M2',
      year: 2022,
      tagline: 'Supercharged by M2.',
      basePrice: 799,
      sizes: const ['11-inch'],
      colors: proColors,
      rams: _ipadRamOptions,
      proStorageOnly: true,
    ),
    _ipadProduct(
      id: 'ipad-pro-12-m2-2022',
      name: 'iPad Pro 12.9" (2022)',
      chip: 'Apple M2',
      year: 2022,
      tagline: 'Supercharged by M2.',
      basePrice: 1099,
      sizes: const ['12.9-inch'],
      colors: proColors,
      rams: _ipadRamOptions,
      proStorageOnly: true,
    ),
    _ipadProduct(
      id: 'ipad-pro-11-m4-2024',
      name: 'iPad Pro 11" (2024)',
      chip: 'Apple M4',
      year: 2024,
      tagline: 'Impossibly thin. Unreal power.',
      basePrice: 999,
      sizes: const ['11-inch'],
      colors: proColors,
      rams: _ipadRamOptions,
      proStorageOnly: true,
      featured: true,
    ),
    _ipadProduct(
      id: 'ipad-pro-13-m4-2024',
      name: 'iPad Pro 13" (2024)',
      chip: 'Apple M4',
      year: 2024,
      tagline: 'Impossibly thin. Unreal power.',
      basePrice: 1299,
      sizes: const ['13-inch'],
      colors: proColors,
      rams: _ipadRamOptions,
      proStorageOnly: true,
      featured: true,
    ),
    _ipadProduct(
      id: 'ipad-pro-11-m5-2025',
      name: 'iPad Pro 11" (2025)',
      chip: 'Apple M5',
      year: 2025,
      tagline: 'M5. The ultimate iPad experience.',
      basePrice: 1099,
      sizes: const ['11-inch'],
      colors: proColors,
      rams: _ipadRamOptions,
      proStorageOnly: true,
      featured: true,
    ),
    _ipadProduct(
      id: 'ipad-pro-13-m5-2025',
      name: 'iPad Pro 13" (2025)',
      chip: 'Apple M5',
      year: 2025,
      tagline: 'M5. The ultimate iPad experience.',
      basePrice: 1399,
      sizes: const ['13-inch'],
      colors: proColors,
      rams: _ipadRamOptions,
      proStorageOnly: true,
      featured: true,
    ),
  ];
}

Product _imacProduct({
  required String id,
  required String name,
  required String chip,
  required int year,
  required int basePrice,
  required String size,
  bool featured = false,
}) {
  final rams = chip.contains('Intel')
      ? _intelRamOptions
      : chip.contains('M5') || chip.contains('M4')
          ? _laptopRamOptions.sublist(1, 6)
          : _laptopRamOptions.sublist(1, 5);
  final variants = _buildLaptopVariants(
    idPrefix: id,
    colors: _macColors,
    sizes: [size],
    rams: rams,
    ramDeltas: chip.contains('Intel') ? _intelRamDeltas : _laptopRamDeltas,
    basePrice: basePrice,
  );
  return Product(
    id: id,
    name: name,
    category: 'iMac',
    tagline: '$chip inside a stunning all-in-one.',
    description:
        '$name all-in-one desktop with $chip. Customize RAM and SSD for your workflow.',
    detailedDescription:
        'The $name ($year) combines a brilliant display with $chip performance. Configure memory and SSD to match photo editing, development, or family use.',
    basePrice: basePrice,
    specs: [chip, size, 'Configurable RAM & SSD', 'Retina display', 'macOS'],
    keyFeatures: const [
      '4.5K Retina display (model dependent)',
      'Configurable unified memory',
      'Configurable SSD',
      'Six-speaker sound system',
      'Studio-quality mics and camera',
    ],
    accent: const Color(0xFF5E9FD6),
    icon: Icons.desktop_mac_outlined,
    imagePath: productImageFor(id),
    featured: featured,
    rating: 4.6,
    reviewCount: 200 + year * 5,
    warranty: '1 Year Limited Warranty, AppleCare+ available',
    inStock: true,
    releaseDate: DateTime(year, 4, 20),
    reviews: _sampleReviews(name),
    variants: variants,
  );
}

List<Product> _buildIMacs() {
  return [
    _imacProduct(
      id: 'imac-21-2019',
      name: 'iMac 21.5" (2019)',
      chip: 'Intel Core i5',
      year: 2019,
      basePrice: 1099,
      size: '21.5-inch',
    ),
    _imacProduct(
      id: 'imac-27-2020',
      name: 'iMac 27" (2020)',
      chip: 'Intel Core i5',
      year: 2020,
      basePrice: 1799,
      size: '27-inch',
    ),
    _imacProduct(
      id: 'imac-24-m1-2021',
      name: 'iMac 24" (2021)',
      chip: 'Apple M1',
      year: 2021,
      basePrice: 1299,
      size: '24-inch',
    ),
    _imacProduct(
      id: 'imac-24-m3-2023',
      name: 'iMac 24" (2023)',
      chip: 'Apple M3',
      year: 2023,
      basePrice: 1299,
      size: '24-inch',
    ),
    _imacProduct(
      id: 'imac-24-m4-2024',
      name: 'iMac 24" (2024)',
      chip: 'Apple M4',
      year: 2024,
      basePrice: 1399,
      size: '24-inch',
      featured: true,
    ),
    _imacProduct(
      id: 'imac-24-m5-2025',
      name: 'iMac 24" (2025)',
      chip: 'Apple M5',
      year: 2025,
      basePrice: 1499,
      size: '24-inch',
      featured: true,
    ),
    _imacProduct(
      id: 'imac-pro-27-2018',
      name: 'iMac Pro 27" (2018)',
      chip: 'Intel Xeon W',
      year: 2018,
      basePrice: 4999,
      size: '27-inch',
    ),
  ];
}

List<Variant> _watchVariants({
  required String idPrefix,
  required List<_ColorOption> colors,
  required List<String> sizes,
  required List<String> bands,
  required int basePrice,
}) {
  final variants = <Variant>[];
  for (final color in colors) {
    for (final size in sizes) {
      for (final band in bands) {
        final slug = _slug('${color.name}-$size-$band');
        variants.add(
          Variant(
            id: '$idPrefix-$slug',
            colorName: color.name,
            color: color.color,
            storage: band,
            size: size,
            price: basePrice + (band.contains('Ocean') ? 50 : 0),
            stock: 3 + slug.hashCode.abs() % 10,
          ),
        );
      }
    }
  }
  return variants;
}

Product _watchProduct({
  required String id,
  required String name,
  required String chip,
  required int year,
  required int basePrice,
  required List<String> sizes,
  required List<String> bands,
  bool featured = false,
}) {
  const colors = <_ColorOption>[
    _ColorOption('Silver', Color(0xFFD9DADB)),
    _ColorOption('Gold', Color(0xFFF4E5C3)),
    _ColorOption('Space Gray', Color(0xFF7D7E80)),
    _ColorOption('Natural Titanium', Color(0xFFC8C2B7)),
    _ColorOption('Black Titanium', Color(0xFF262626)),
  ];
  return Product(
    id: id,
    name: name,
    category: 'Watch',
    tagline: 'A healthy leap ahead.',
    description: '$name with $chip. Pick case size and band style.',
    detailedDescription:
        'Choose your $name ($year) case finish, size (${sizes.join(', ')}), and band. Advanced health sensors and fitness tracking built in.',
    basePrice: basePrice,
    specs: [chip, ...sizes, 'Always-On display', 'GPS + Cellular options'],
    keyFeatures: const [
      'ECG and blood oxygen apps',
      'Crash Detection and Emergency SOS',
      'Fitness and sleep tracking',
      'Interchangeable bands',
      'Water resistant design',
    ],
    accent: const Color(0xFFF28C38),
    icon: Icons.watch,
    imagePath: productImageFor(id),
    featured: featured,
    rating: 4.5 + (year % 7) * 0.05,
    reviewCount: 90 + year * 10,
    warranty: '1 Year Limited Warranty, AppleCare+ available',
    inStock: true,
    releaseDate: DateTime(year, 9, 15),
    reviews: _sampleReviews(name),
    variants: _watchVariants(
      idPrefix: id,
      colors: colors.sublist(0, name.contains('Ultra') ? 2 : 3),
      sizes: sizes,
      bands: bands,
      basePrice: basePrice,
    ),
  );
}

List<Product> _buildAppleWatches() {
  return [
    _watchProduct(
      id: 'watch-s4-2018',
      name: 'Apple Watch Series 4',
      chip: 'S4 SiP',
      year: 2018,
      basePrice: 399,
      sizes: const ['40mm', '44mm'],
      bands: const ['Sport Band', 'Sport Loop'],
    ),
    _watchProduct(
      id: 'watch-s5-2019',
      name: 'Apple Watch Series 5',
      chip: 'S5 SiP',
      year: 2019,
      basePrice: 399,
      sizes: const ['40mm', '44mm'],
      bands: const ['Sport Band', 'Sport Loop', 'Leather Loop'],
    ),
    _watchProduct(
      id: 'watch-s6-2020',
      name: 'Apple Watch Series 6',
      chip: 'S6 SiP',
      year: 2020,
      basePrice: 399,
      sizes: const ['40mm', '44mm'],
      bands: const ['Sport Band', 'Solo Loop', 'Leather Link'],
    ),
    _watchProduct(
      id: 'watch-s7-2021',
      name: 'Apple Watch Series 7',
      chip: 'S7 SiP',
      year: 2021,
      basePrice: 399,
      sizes: const ['41mm', '45mm'],
      bands: const ['Sport Band', 'Braided Solo Loop'],
    ),
    _watchProduct(
      id: 'watch-s8-2022',
      name: 'Apple Watch Series 8',
      chip: 'S8 SiP',
      year: 2022,
      basePrice: 399,
      sizes: const ['41mm', '45mm'],
      bands: const ['Sport Band', 'Sport Loop'],
    ),
    _watchProduct(
      id: 'watch-s9-2023',
      name: 'Apple Watch Series 9',
      chip: 'S9 SiP',
      year: 2023,
      basePrice: 399,
      sizes: const ['41mm', '45mm'],
      bands: const ['Sport Band', 'FineWoven Band'],
    ),
    _watchProduct(
      id: 'watch-s10-2024',
      name: 'Apple Watch Series 10',
      chip: 'S10 SiP',
      year: 2024,
      basePrice: 399,
      sizes: const ['42mm', '46mm'],
      bands: const ['Sport Band', 'Sport Loop'],
      featured: true,
    ),
    _watchProduct(
      id: 'watch-se-2020',
      name: 'Apple Watch SE (1st gen)',
      chip: 'S5 SiP',
      year: 2020,
      basePrice: 279,
      sizes: const ['40mm', '44mm'],
      bands: const ['Sport Band'],
    ),
    _watchProduct(
      id: 'watch-se-2022',
      name: 'Apple Watch SE (2nd gen)',
      chip: 'S8 SiP',
      year: 2022,
      basePrice: 249,
      sizes: const ['40mm', '44mm'],
      bands: const ['Sport Band', 'Sport Loop'],
    ),
    _watchProduct(
      id: 'watch-se-2024',
      name: 'Apple Watch SE (3rd gen)',
      chip: 'S10 SiP',
      year: 2024,
      basePrice: 249,
      sizes: const ['40mm', '44mm'],
      bands: const ['Sport Band'],
    ),
    _watchProduct(
      id: 'watch-ultra-1-2022',
      name: 'Apple Watch Ultra',
      chip: 'S8 SiP',
      year: 2022,
      basePrice: 799,
      sizes: const ['49mm'],
      bands: const ['Alpine Loop', 'Trail Loop', 'Ocean Band'],
    ),
    _watchProduct(
      id: 'watch-ultra-2-2023',
      name: 'Apple Watch Ultra 2',
      chip: 'S9 SiP',
      year: 2023,
      basePrice: 799,
      sizes: const ['49mm'],
      bands: const ['Alpine Loop', 'Trail Loop', 'Ocean Band'],
      featured: true,
    ),
    _watchProduct(
      id: 'watch-ultra-3-2025',
      name: 'Apple Watch Ultra 3',
      chip: 'S10 SiP',
      year: 2025,
      basePrice: 849,
      sizes: const ['49mm'],
      bands: const ['Alpine Loop', 'Trail Loop', 'Ocean Band', 'Titanium Milanese'],
      featured: true,
    ),
  ];
}

Product _airPodsProduct({
  required String id,
  required String name,
  required int year,
  required int basePrice,
  required List<String> caseTypes,
  bool featured = false,
}) {
  const colors = <_ColorOption>[
    _ColorOption('White', Color(0xFFF4F4F2)),
  ];
  final variants = <Variant>[];
  for (final color in colors) {
    for (final caseType in caseTypes) {
      variants.add(
        Variant(
          id: '$id-${_slug(caseType)}',
          colorName: color.name,
          color: color.color,
          storage: caseType,
          price: basePrice + (caseType.contains('MagSafe') ? 20 : 0),
          stock: 12 + caseType.hashCode.abs() % 8,
        ),
      );
    }
  }
  return Product(
    id: id,
    name: name,
    category: 'AirPods',
    tagline: 'Wireless. Effortless. Magical.',
    description: '$name — premium sound with seamless Apple device pairing.',
    detailedDescription:
        'Experience $name with adaptive audio, long battery life, and quick pairing across iPhone, iPad, and Mac.',
    basePrice: basePrice,
    specs: const ['H2 or H1 chip', 'Active Noise Cancellation', 'Spatial Audio', 'USB-C charging'],
    keyFeatures: const [
      'Active Noise Cancellation',
      'Transparency mode',
      'Spatial Audio',
      'Find My support',
      'Quick pairing',
    ],
    accent: const Color(0xFFE7E9EA),
    icon: Icons.earbuds,
    imagePath: productImageFor(id),
    featured: featured,
    rating: 4.5,
    reviewCount: 500 + year * 40,
    warranty: '1 Year Limited Warranty',
    inStock: true,
    releaseDate: DateTime(year, 9, 12),
    reviews: _sampleReviews(name),
    variants: variants,
  );
}

List<Product> _buildAirPods() {
  return [
    _airPodsProduct(
      id: 'airpods-2-2019',
      name: 'AirPods (2nd gen)',
      year: 2019,
      basePrice: 129,
      caseTypes: const ['Lightning Case'],
    ),
    _airPodsProduct(
      id: 'airpods-3-2021',
      name: 'AirPods (3rd gen)',
      year: 2021,
      basePrice: 169,
      caseTypes: const ['Lightning Case', 'MagSafe Case'],
    ),
    _airPodsProduct(
      id: 'airpods-4-2024',
      name: 'AirPods (4th gen)',
      year: 2024,
      basePrice: 179,
      caseTypes: const ['USB-C Case', 'ANC Case'],
      featured: true,
    ),
    _airPodsProduct(
      id: 'airpods-pro-1-2019',
      name: 'AirPods Pro (1st gen)',
      year: 2019,
      basePrice: 249,
      caseTypes: const ['Wireless Case'],
    ),
    _airPodsProduct(
      id: 'airpods-pro-2-2022',
      name: 'AirPods Pro (2nd gen)',
      year: 2022,
      basePrice: 249,
      caseTypes: const ['USB-C Case', 'MagSafe Case'],
      featured: true,
    ),
    _airPodsProduct(
      id: 'airpods-pro-3-2025',
      name: 'AirPods Pro (3rd gen)',
      year: 2025,
      basePrice: 269,
      caseTypes: const ['USB-C Case', 'MagSafe Case', 'Hearing Aid Case'],
      featured: true,
    ),
    _airPodsProduct(
      id: 'airpods-max-2020',
      name: 'AirPods Max',
      year: 2020,
      basePrice: 549,
      caseTypes: const ['Smart Case'],
    ),
    _airPodsProduct(
      id: 'airpods-max-usb-2024',
      name: 'AirPods Max (USB-C)',
      year: 2024,
      basePrice: 549,
      caseTypes: const ['Smart Case', 'Midnight', 'Starlight', 'Blue'],
    ),
  ];
}

const _iphoneStorageOptions = <String>['128GB', '256GB', '512GB', '1TB'];
const _iphoneStorageDeltas = <String, int>{
  '128GB': 0,
  '256GB': 100,
  '512GB': 300,
  '1TB': 500,
};

List<Variant> _buildIPhoneVariants({
  required String idPrefix,
  required List<_ColorOption> colors,
  required List<String> sizes,
  required int basePrice,
}) {
  final variants = <Variant>[];
  for (final color in colors) {
    for (final size in sizes) {
      for (final storage in _iphoneStorageOptions) {
        final price = basePrice + (_iphoneStorageDeltas[storage] ?? 0) + (size.contains('Max') || size.contains('Plus') ? 100 : 0);
        final slug = _slug('${color.name}-$size-$storage');
        variants.add(
          Variant(
            id: '$idPrefix-$slug',
            colorName: color.name,
            color: color.color,
            storage: storage,
            size: size,
            price: price,
            stock: 5 + slug.hashCode.abs() % 18,
          ),
        );
      }
    }
  }
  return variants;
}

Product _iphoneProduct({
  required String id,
  required String name,
  required String chip,
  required int year,
  required String tagline,
  required int basePrice,
  required List<_ColorOption> colors,
  required List<String> sizes,
  bool featured = false,
}) {
  return Product(
    id: id,
    name: name,
    category: 'iPhone',
    tagline: tagline,
    description:
        '$name with $chip. Choose your finish, display size, and storage before checkout.',
    detailedDescription:
        'Build your $name ($year) with $chip. Available in ${colors.map((c) => c.name).join(', ')} across ${sizes.join(', ')} sizes.',
    basePrice: basePrice,
    specs: [chip, ...sizes, 'Ceramic Shield', '5G capable'],
    keyFeatures: const [
      'Advanced camera system',
      'All-day battery life',
      'Multiple storage options',
      'Multiple finishes',
      'Face ID security',
    ],
    accent: colors.first.color,
    icon: CupertinoIcons.device_phone_portrait,
    imagePath: productImageFor(id),
    featured: featured,
    rating: 4.4 + (year % 8) * 0.05,
    reviewCount: 800 + year * 120,
    warranty: '1 Year Limited Warranty, AppleCare+ available',
    inStock: true,
    releaseDate: DateTime(year, 9, 20),
    reviews: _sampleReviews(name),
    variants: _buildIPhoneVariants(
      idPrefix: id,
      colors: colors,
      sizes: sizes,
      basePrice: basePrice,
    ),
  );
}

List<Product> _buildIPhones() {
  const titanium = <_ColorOption>[
    _ColorOption('Natural Titanium', Color(0xFFC9C3B8)),
    _ColorOption('Black Titanium', Color(0xFF3A3A3C)),
    _ColorOption('Desert Titanium', Color(0xFFC9B89A)),
    _ColorOption('White Titanium', Color(0xFFF5F5F0)),
  ];
  const iphone16Colors = <_ColorOption>[
    _ColorOption('Ultramarine', Color(0xFF4E6FAE)),
    _ColorOption('Teal', Color(0xFF5FA89A)),
    _ColorOption('Pink', Color(0xFFF2D4E4)),
    _ColorOption('White', Color(0xFFF5F5F0)),
    _ColorOption('Black', Color(0xFF2E3642)),
  ];
  const iphone15Colors = <_ColorOption>[
    _ColorOption('Blue', Color(0xFFA8C7E7)),
    _ColorOption('Pink', Color(0xFFF2D4E4)),
    _ColorOption('Yellow', Color(0xFFF4E6A1)),
    _ColorOption('Green', Color(0xFFB8D4C8)),
    _ColorOption('Black', Color(0xFF2E3642)),
  ];
  const iphone14Colors = <_ColorOption>[
    _ColorOption('Blue', Color(0xFFA8C7E7)),
    _ColorOption('Purple', Color(0xFFC8B6D8)),
    _ColorOption('Midnight', Color(0xFF2E3642)),
    _ColorOption('Starlight', Color(0xFFF5E6D3)),
  ];
  const classicColors = <_ColorOption>[
    _ColorOption('Midnight', Color(0xFF2E3642)),
    _ColorOption('Starlight', Color(0xFFF5E6D3)),
    _ColorOption('Blue', Color(0xFFA8C7E7)),
    _ColorOption('Pink', Color(0xFFF2D4E4)),
  ];

  return [
    _iphoneProduct(
      id: 'iphone-16-pro-max',
      name: 'iPhone 16 Pro Max',
      chip: 'A18 Pro',
      year: 2024,
      tagline: 'The ultimate iPhone experience.',
      basePrice: 1199,
      colors: titanium,
      sizes: const ['6.9-inch Pro Max'],
      featured: true,
    ),
    _iphoneProduct(
      id: 'iphone-16-pro',
      name: 'iPhone 16 Pro',
      chip: 'A18 Pro',
      year: 2024,
      tagline: 'Titanium. Built for Apple Intelligence.',
      basePrice: 999,
      colors: titanium,
      sizes: const ['6.3-inch Pro'],
      featured: true,
    ),
    _iphoneProduct(
      id: 'iphone-16-plus',
      name: 'iPhone 16 Plus',
      chip: 'A18',
      year: 2024,
      tagline: 'Big and brilliant.',
      basePrice: 899,
      colors: iphone16Colors,
      sizes: const ['6.7-inch Plus'],
    ),
    _iphoneProduct(
      id: 'iphone-16',
      name: 'iPhone 16',
      chip: 'A18',
      year: 2024,
      tagline: 'Built for Apple Intelligence.',
      basePrice: 799,
      colors: iphone16Colors,
      sizes: const ['6.1-inch'],
      featured: true,
    ),
    _iphoneProduct(
      id: 'iphone-16e-2025',
      name: 'iPhone 16e',
      chip: 'A18',
      year: 2025,
      tagline: 'Essential iPhone power.',
      basePrice: 599,
      colors: const [
        _ColorOption('White', Color(0xFFF5F5F0)),
        _ColorOption('Black', Color(0xFF2E3642)),
      ],
      sizes: const ['6.1-inch'],
    ),
    _iphoneProduct(
      id: 'iphone-15-pro-max',
      name: 'iPhone 15 Pro Max',
      chip: 'A17 Pro',
      year: 2023,
      tagline: 'Forged in titanium.',
      basePrice: 1099,
      colors: titanium,
      sizes: const ['6.7-inch Pro Max'],
    ),
    _iphoneProduct(
      id: 'iphone-15-pro',
      name: 'iPhone 15 Pro',
      chip: 'A17 Pro',
      year: 2023,
      tagline: 'Titanium. So strong. So light.',
      basePrice: 999,
      colors: titanium,
      sizes: const ['6.1-inch Pro'],
    ),
    _iphoneProduct(
      id: 'iphone-15-plus',
      name: 'iPhone 15 Plus',
      chip: 'A16 Bionic',
      year: 2023,
      tagline: 'More screen. More fun.',
      basePrice: 899,
      colors: iphone15Colors,
      sizes: const ['6.7-inch Plus'],
    ),
    _iphoneProduct(
      id: 'iphone-15-2023',
      name: 'iPhone 15',
      chip: 'A16 Bionic',
      year: 2023,
      tagline: 'New camera. New design. Newphoria.',
      basePrice: 799,
      colors: iphone15Colors,
      sizes: const ['6.1-inch'],
    ),
    _iphoneProduct(
      id: 'iphone-14-pro-max',
      name: 'iPhone 14 Pro Max',
      chip: 'A16 Bionic',
      year: 2022,
      tagline: 'Pro. Beyond.',
      basePrice: 999,
      colors: const [
        _ColorOption('Deep Purple', Color(0xFF5E4B6B)),
        _ColorOption('Gold', Color(0xFFF4E5C3)),
        _ColorOption('Silver', Color(0xFFD9DADB)),
        _ColorOption('Space Black', Color(0xFF303033)),
      ],
      sizes: const ['6.7-inch Pro Max'],
    ),
    _iphoneProduct(
      id: 'iphone-14-pro',
      name: 'iPhone 14 Pro',
      chip: 'A16 Bionic',
      year: 2022,
      tagline: 'Pro. Beyond.',
      basePrice: 899,
      colors: const [
        _ColorOption('Deep Purple', Color(0xFF5E4B6B)),
        _ColorOption('Gold', Color(0xFFF4E5C3)),
        _ColorOption('Silver', Color(0xFFD9DADB)),
        _ColorOption('Space Black', Color(0xFF303033)),
      ],
      sizes: const ['6.1-inch Pro'],
    ),
    _iphoneProduct(
      id: 'iphone-14-plus',
      name: 'iPhone 14 Plus',
      chip: 'A15 Bionic',
      year: 2022,
      tagline: 'Bigger and better.',
      basePrice: 799,
      colors: iphone14Colors,
      sizes: const ['6.7-inch Plus'],
    ),
    _iphoneProduct(
      id: 'iphone-14-2022',
      name: 'iPhone 14',
      chip: 'A15 Bionic',
      year: 2022,
      tagline: 'Big and bigger.',
      basePrice: 699,
      colors: iphone14Colors,
      sizes: const ['6.1-inch'],
    ),
    _iphoneProduct(
      id: 'iphone-13-pro-max',
      name: 'iPhone 13 Pro Max',
      chip: 'A15 Bionic',
      year: 2021,
      tagline: 'Your new superpower.',
      basePrice: 899,
      colors: const [
        _ColorOption('Graphite', Color(0xFF535150)),
        _ColorOption('Sierra Blue', Color(0xFF9BB5CE)),
        _ColorOption('Gold', Color(0xFFF4E5C3)),
        _ColorOption('Silver', Color(0xFFD9DADB)),
      ],
      sizes: const ['6.7-inch Pro Max'],
    ),
    _iphoneProduct(
      id: 'iphone-13-pro',
      name: 'iPhone 13 Pro',
      chip: 'A15 Bionic',
      year: 2021,
      tagline: 'Oh. So. Pro.',
      basePrice: 799,
      colors: const [
        _ColorOption('Graphite', Color(0xFF535150)),
        _ColorOption('Sierra Blue', Color(0xFF9BB5CE)),
        _ColorOption('Gold', Color(0xFFF4E5C3)),
        _ColorOption('Silver', Color(0xFFD9DADB)),
      ],
      sizes: const ['6.1-inch Pro'],
    ),
    _iphoneProduct(
      id: 'iphone-13',
      name: 'iPhone 13',
      chip: 'A15 Bionic',
      year: 2021,
      tagline: 'Your new superpower.',
      basePrice: 599,
      colors: classicColors,
      sizes: const ['6.1-inch'],
    ),
    _iphoneProduct(
      id: 'iphone-13-mini',
      name: 'iPhone 13 mini',
      chip: 'A15 Bionic',
      year: 2021,
      tagline: 'A lot of iPhone in a mini size.',
      basePrice: 549,
      colors: classicColors,
      sizes: const ['5.4-inch mini'],
    ),
    _iphoneProduct(
      id: 'iphone-12-pro-max',
      name: 'iPhone 12 Pro Max',
      chip: 'A14 Bionic',
      year: 2020,
      tagline: 'The biggest iPhone display ever.',
      basePrice: 899,
      colors: const [
        _ColorOption('Pacific Blue', Color(0xFF2E4A62)),
        _ColorOption('Graphite', Color(0xFF535150)),
        _ColorOption('Gold', Color(0xFFF4E5C3)),
        _ColorOption('Silver', Color(0xFFD9DADB)),
      ],
      sizes: const ['6.7-inch Pro Max'],
    ),
    _iphoneProduct(
      id: 'iphone-12-pro',
      name: 'iPhone 12 Pro',
      chip: 'A14 Bionic',
      year: 2020,
      tagline: 'Blast past fast.',
      basePrice: 799,
      colors: const [
        _ColorOption('Pacific Blue', Color(0xFF2E4A62)),
        _ColorOption('Graphite', Color(0xFF535150)),
        _ColorOption('Gold', Color(0xFFF4E5C3)),
        _ColorOption('Silver', Color(0xFFD9DADB)),
      ],
      sizes: const ['6.1-inch Pro'],
    ),
    _iphoneProduct(
      id: 'iphone-12',
      name: 'iPhone 12',
      chip: 'A14 Bionic',
      year: 2020,
      tagline: 'Blast past fast.',
      basePrice: 599,
      colors: const [
        _ColorOption('Purple', Color(0xFFC8B6D8)),
        _ColorOption('Blue', Color(0xFFA8C7E7)),
        _ColorOption('Green', Color(0xFFB8D4C8)),
        _ColorOption('Black', Color(0xFF2E3642)),
        _ColorOption('White', Color(0xFFF5F5F0)),
      ],
      sizes: const ['6.1-inch'],
    ),
    _iphoneProduct(
      id: 'iphone-12-mini',
      name: 'iPhone 12 mini',
      chip: 'A14 Bionic',
      year: 2020,
      tagline: 'A lot of iPhone in a mini size.',
      basePrice: 549,
      colors: const [
        _ColorOption('Purple', Color(0xFFC8B6D8)),
        _ColorOption('Blue', Color(0xFFA8C7E7)),
        _ColorOption('Green', Color(0xFFB8D4C8)),
        _ColorOption('Black', Color(0xFF2E3642)),
      ],
      sizes: const ['5.4-inch mini'],
    ),
    _iphoneProduct(
      id: 'iphone-11',
      name: 'iPhone 11',
      chip: 'A13 Bionic',
      year: 2019,
      tagline: 'Just the right amount of everything.',
      basePrice: 499,
      colors: const [
        _ColorOption('Purple', Color(0xFFC8B6D8)),
        _ColorOption('Green', Color(0xFFB8D4C8)),
        _ColorOption('Yellow', Color(0xFFF4E6A1)),
        _ColorOption('Black', Color(0xFF2E3642)),
        _ColorOption('White', Color(0xFFF5F5F0)),
      ],
      sizes: const ['6.1-inch'],
    ),
    _iphoneProduct(
      id: 'iphone-se-2022',
      name: 'iPhone SE (3rd gen)',
      chip: 'A15 Bionic',
      year: 2022,
      tagline: 'Love the power. Love the price.',
      basePrice: 429,
      colors: const [
        _ColorOption('Midnight', Color(0xFF2E3642)),
        _ColorOption('Starlight', Color(0xFFF5E6D3)),
        _ColorOption('Red', Color(0xFFC82E2E)),
      ],
      sizes: const ['4.7-inch'],
    ),
    _iphoneProduct(
      id: 'iphone-se-2020',
      name: 'iPhone SE (2nd gen)',
      chip: 'A13 Bionic',
      year: 2020,
      tagline: 'Lots to love. Less to spend.',
      basePrice: 399,
      colors: const [
        _ColorOption('Black', Color(0xFF2E3642)),
        _ColorOption('White', Color(0xFFF5F5F0)),
        _ColorOption('Red', Color(0xFFC82E2E)),
      ],
      sizes: const ['4.7-inch'],
    ),
  ];
}

List<Review> _sampleReviews(String productName) {
  return [
    Review(
      id: 'rev-${productName.hashCode}',
      author: 'AppleTech Customer',
      rating: 5,
      title: 'Great purchase',
      content: '$productName arrived quickly and works exactly as described.',
      date: DateTime.now().subtract(const Duration(days: 12)),
      verified: true,
    ),
  ];
}

String _slug(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

class _ColorOption {
  const _ColorOption(this.name, this.color);
  final String name;
  final Color color;
}
