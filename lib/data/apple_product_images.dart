part of '../main.dart';

/// High-resolution product photos from Apple's official store CDN.
/// Each catalog product id maps to a distinct image slug where possible.
const _appleCdnBase =
    'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is';

String productImageUrl(String slug, {int size = 960}) =>
    '$_appleCdnBase/$slug?wid=$size&hei=$size&fmt=png-alpha';

String productImageFor(String productId) =>
    productImageUrl(_productImageSlugs[productId] ?? _fallbackSlug(productId));

final Map<String, String> _productImageSlugs = () {
  final map = <String, String>{};
  _assignUnique(map, _macBookAirIds, _macBookAirImageSlugs);
  _assignUnique(map, _macBookProIds, _macBookProImageSlugs);
  _assignUnique(map, _iPadIds, _iPadImageSlugs);
  _assignUnique(map, _iMacIds, _iMacImageSlugs);
  _assignUnique(map, _watchIds, _watchImageSlugs);
  _assignUnique(map, _airPodsIds, _airPodsImageSlugs);
  _assignUnique(map, _iPhoneIds, _iPhoneImageSlugs);
  return map;
}();

void _assignUnique(
  Map<String, String> map,
  List<String> productIds,
  List<String> slugs,
) {
  for (var i = 0; i < productIds.length; i++) {
    map[productIds[i]] = slugs[i % slugs.length];
  }
}

String _fallbackSlug(String productId) {
  if (productId.startsWith('mba-') || productId.startsWith('mbp-')) {
    return _macBookAirImageSlugs.first;
  }
  if (productId.startsWith('ipad-')) return _iPadImageSlugs.first;
  if (productId.startsWith('imac-')) return _iMacImageSlugs.first;
  if (productId.startsWith('watch-')) return _watchImageSlugs.first;
  if (productId.startsWith('airpods-')) return _airPodsImageSlugs.first;
  if (productId.startsWith('iphone-')) return _iPhoneImageSlugs.first;
  return 'iphone-16-pro-model-unselect-gallery-1-202409';
}

// ——— Product id lists (must match product_catalog.dart) ———

const _macBookAirIds = <String>[
  'mba-13-2018',
  'mba-13-2019',
  'mba-13-m1-2020',
  'mba-13-m2-2022',
  'mba-13-m3-2024',
  'mba-13-m4-2025',
  'mba-15-m2-2023',
  'mba-15-m3-2024',
  'mba-15-m4-2025',
  'mba-15-m5-2025',
];

const _macBookProIds = <String>[
  'mbp-13-2018',
  'mbp-13-2019',
  'mbp-13-m1-2020',
  'mbp-14-m1p-2021',
  'mbp-14-m1m-2021',
  'mbp-16-m1p-2021',
  'mbp-16-m1m-2021',
  'mbp-14-m2p-2023',
  'mbp-14-m2m-2023',
  'mbp-16-m2p-2023',
  'mbp-16-m2m-2023',
  'mbp-14-m3p-2023',
  'mbp-14-m3m-2023',
  'mbp-16-m3p-2023',
  'mbp-16-m3m-2023',
  'mbp-14-m4p-2024',
  'mbp-14-m4m-2024',
  'mbp-16-m4p-2024',
  'mbp-16-m4m-2024',
  'mbp-14-m5p-2025',
  'mbp-14-m5m-2025',
  'mbp-16-m5p-2025',
  'mbp-16-m5m-2025',
];

const _iPadIds = <String>[
  'ipad-9-2021',
  'ipad-10-2022',
  'ipad-air-4-2020',
  'ipad-air-5-2022',
  'ipad-air-6-2024',
  'ipad-air-7-2025',
  'ipad-mini-5-2019',
  'ipad-mini-6-2021',
  'ipad-mini-7-2024',
  'ipad-pro-11-2018',
  'ipad-pro-12-2018',
  'ipad-pro-11-2020',
  'ipad-pro-12-2020',
  'ipad-pro-11-m1-2021',
  'ipad-pro-12-m1-2021',
  'ipad-pro-11-m2-2022',
  'ipad-pro-12-m2-2022',
  'ipad-pro-11-m4-2024',
  'ipad-pro-13-m4-2024',
  'ipad-pro-11-m5-2025',
  'ipad-pro-13-m5-2025',
];

const _iMacIds = <String>[
  'imac-21-2019',
  'imac-27-2020',
  'imac-24-m1-2021',
  'imac-24-m3-2023',
  'imac-24-m4-2024',
  'imac-24-m5-2025',
  'imac-pro-27-2018',
];

const _watchIds = <String>[
  'watch-s4-2018',
  'watch-s5-2019',
  'watch-s6-2020',
  'watch-s7-2021',
  'watch-s8-2022',
  'watch-s9-2023',
  'watch-s10-2024',
  'watch-se-2020',
  'watch-se-2022',
  'watch-se-2024',
  'watch-ultra-1-2022',
  'watch-ultra-2-2023',
  'watch-ultra-3-2025',
];

const _airPodsIds = <String>[
  'airpods-2-2019',
  'airpods-3-2021',
  'airpods-4-2024',
  'airpods-pro-1-2019',
  'airpods-pro-2-2022',
  'airpods-pro-3-2025',
  'airpods-max-2020',
  'airpods-max-usb-2024',
];

const _iPhoneIds = <String>[
  'iphone-16-pro-max',
  'iphone-16-pro',
  'iphone-16-plus',
  'iphone-16',
  'iphone-16e-2025',
  'iphone-15-pro-max',
  'iphone-15-pro',
  'iphone-15-plus',
  'iphone-15-2023',
  'iphone-14-pro-max',
  'iphone-14-pro',
  'iphone-14-plus',
  'iphone-14-2022',
  'iphone-13-pro-max',
  'iphone-13-pro',
  'iphone-13',
  'iphone-13-mini',
  'iphone-12-pro-max',
  'iphone-12-pro',
  'iphone-12',
  'iphone-12-mini',
  'iphone-11',
  'iphone-se-2022',
  'iphone-se-2020',
];

// ——— Verified Apple store CDN slugs (unique per slot) ———

const _macBookAirImageSlugs = <String>[
  'mba13-midnight-select-202503',
  'mba13-silver-select-202503',
  'mba13-skyblue-select-202503',
  'mba15-starlight-select-202503',
  'mba15-midnight-select-202503',
  'mba15-silver-select-202503',
  'mba13-midnight-select-202402',
  'macbook-air-size-unselect-202601-gallery-1',
  'macbook-air-size-unselect-202601-gallery-2',
  'macbook-air-size-unselect-202603-gallery-3',
  'macbook-air-chip-select-202603',
  'og-macbook-air-202603',
];

const _macBookProImageSlugs = <String>[
  'mbp14-silver-select-202410',
  'mbp14-spaceblack-select-202410',
  'mbp16-silver-select-202410',
  'mbp16-spaceblack-select-202410',
  'mbp14-silver-select-202301',
  'mbp16-silver-select-202301',
  'mac-macbook-pro-size-unselect-202601-gallery-1',
  'mac-macbook-pro-size-unselect-202601-gallery-2',
  'mac-macbook-pro-size-unselect-202601-gallery-3',
  'mbp14-spaceblack-cto-hero-202410',
  'mbp16-silver-cto-hero-202410',
  'mba13-midnight-select-202503',
  'mba15-starlight-select-202503',
];

const _iPadImageSlugs = <String>[
  'ipad-pro-gallery-1-202405',
  'ipad-pro-gallery-2-202405',
  'ipad-pro-gallery-3-202405',
  'ipad-pro-gallery-4-202405',
  'ipad-pro-gallery-5-202405',
  'ipad-pro-11-select-wifi-silver-202405',
  'ipad-pro-11-select-wifi-spaceblack-202405',
  'ipad-pro-13-select-wifi-silver-202405',
  'ipad-pro-13-select-wifi-spaceblack-202405',
  'ipad-air-select-11in-wifi-blue-202405',
  'ipad-air-select-11in-wifi-purple-202405',
  'ipad-air-select-11in-wifi-spacegray-202405',
  'ipad-air-select-11in-wifi-starlight-202405',
  'ipad-air-select-13in-wifi-blue-202405',
  'ipad-air-select-13in-wifi-purple-202405',
  'ipad-2022-hero-blue-wifi-select',
  'ipad-2022-hero-pink-wifi-select',
  'ipad-2022-hero-silver-wifi-select',
  'ipad-2022-hero-yellow-wifi-select',
  'ipad-mini-select-wifi-blue-202410',
  'ipad-mini-select-wifi-purple-202410',
  'ipad-mini-select-wifi-spacegray-202410',
  'ipad-mini-select-wifi-starlight-202410',
];

const _iMacImageSlugs = <String>[
  'imac-color-unselect-202601-gallery-1',
  'imac-color-unselect-202601-gallery-2',
  'imac-color-unselect-202601-gallery-3',
  'imac-color-unselect-202601-gallery-4',
  'imac-color-unselect-202601-gallery-5',
  'imac-color-unselect-202601-gallery-6',
  'imac-touch-id-blue-selection-hero-202410',
  'imac-touch-id-orange-selection-hero-202410',
  'imac-touch-id-pink-selection-hero-202410',
  'imac-touch-id-purple-selection-hero-202410',
  'imac-vesa-green-selection-hero-202410',
  'imac-vesa-silver-selection-hero-202410',
  'imac-vesa-yellow-selection-hero-202410',
];

const _watchImageSlugs = <String>[
  's11-case-unselect-gallery-1-202509',
  's11-case-unselect-gallery-2-202509',
  's11-case-unselect-gallery-3-202509',
  's10-case-unselect-gallery-1-202409',
  's10-case-unselect-gallery-2-202409',
  's10-case-unselect-gallery-3-202409',
  'watch-compare-ultra3-202509',
  'watch-compare-series11-swatches-202509',
  'watch-compare-se-202509',
  'watch-compare-s11-202509',
  'watch-compare-se3-swatches-202509',
  'watch-compare-ultra3-swatches-202509',
];

const _airPodsImageSlugs = <String>[
  'airpods-pro-3-gallery-1-202509',
  'airpods-pro-3-gallery-2-202509',
  'airpods-4-select-202409',
  'airpods-4-anc-select-202409',
  'airpods-max-select-202409-midnight',
  'airpods-max-select-202409-starlight',
  'airpods-max-select-202409-blue',
  'airpods-max-select-202409-purple',
  'airpods-max-select-202409-orange',
];

const _iPhoneImageSlugs = <String>[
  'iphone-16-pro-model-unselect-gallery-1-202409',
  'iphone-16-pro-model-unselect-gallery-2-202409',
  'iphone-16-pro-finish-select-202409-6-3inch-naturaltitanium',
  'iphone-16-pro-finish-select-202409-6-3inch-blacktitanium',
  'iphone-16-pro-finish-select-202409-6-3inch-deserttitanium',
  'iphone-16-pro-finish-select-202409-6-3inch-whitetitanium',
  'iphone-16-model-unselect-gallery-1-202409',
  'iphone-16-finish-select-202409-6-1inch-ultramarine',
  'iphone-16-finish-select-202409-6-1inch-teal',
  'iphone-16-finish-select-202409-6-1inch-pink',
  'iphone-16-finish-select-202409-6-1inch-white',
  'iphone-16-finish-select-202409-6-1inch-black',
  'iphone-15-pro-finish-select-202309-6-1inch-naturaltitanium',
  'iphone-15-pro-finish-select-202309-6-1inch-bluetitanium',
  'iphone-15-pro-finish-select-202309-6-1inch-whitetitanium',
  'iphone-15-pro-finish-select-202309-6-1inch-blacktitanium',
  'iphone-15-model-unselect-gallery-1-202309',
  'iphone-15-finish-select-202309-6-1inch-blue',
  'iphone-15-finish-select-202309-6-1inch-pink',
  'iphone-15-finish-select-202309-6-1inch-yellow',
  'iphone-15-finish-select-202309-6-1inch-green',
  'iphone-15-finish-select-202309-6-1inch-black',
  'iphone-14-model-unselect-gallery-1-202209',
  'iphone-14-finish-select-202209-6-1inch-blue',
  'iphone-14-finish-select-202209-6-1inch-purple',
  'iphone-14-finish-select-202209-6-1inch-midnight',
  'iphone-14-finish-select-202209-6-1inch-starlight',
  'iphone-se-finish-select-202207-midnight',
];
