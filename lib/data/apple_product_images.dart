part of '../main.dart';

/// Official Apple Store CDN image links (high-res PNG with transparency).
const _appleCdnBase =
    'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is';

/// Default 1200px square — sharp on retina phones and tablets.
String productImageUrl(String slug, {int size = 1200}) =>
    '$_appleCdnBase/$slug?wid=$size&hei=$size&fmt=png-alpha';

/// Resolved image paths: prioritizes local high-quality assets,
/// falls back to official Apple CDN for unique product display.
String productImageFor(String productId) {
  // 1. Check for specific local mapping
  final localSlug = _localProductImageMappings[productId];
  if (localSlug != null) {
    return 'assets/images/$localSlug.png';
  }

  // 2. Fallback to CDN for unique official images if no local match
  final cdnSlug = _cdnProductImageSlugs[productId];
  if (cdnSlug != null) {
    return productImageUrl(cdnSlug);
  }

  // 3. Generic fallback based on ID prefix
  return _genericFallback(productId);
}

String _genericFallback(String productId) {
  if (productId.startsWith('mba-')) return 'assets/images/macbook_air.png';
  if (productId.startsWith('mbp-')) return 'assets/images/macbook_pro.png';
  if (productId.startsWith('ipad-')) return 'assets/images/ipad_pro.png';
  if (productId.startsWith('iphone-')) return 'assets/images/iphone_16_pro.png';
  if (productId.startsWith('watch-')) return 'assets/images/watch_ultra.png';
  if (productId.startsWith('airpods-')) return 'assets/images/airpods_pro.png';
  if (productId.startsWith('imac-')) return 'assets/images/imac_blue.png';
  if (productId.startsWith('mac-mini')) return 'assets/images/mac_mini.png';
  if (productId.startsWith('mac-studio')) return 'assets/images/mac_studio.png';

  return 'assets/images/iphone_16_pro.png';
}

/// Map product IDs to the UNIQUE cleaned-up local asset names.
const Map<String, String> _localProductImageMappings = {
  // MacBook Air
  'mba-13-m1-2020': 'macbook_air',
  'mba-13-m2-2022': 'mba13_midnight',
  'mba-13-m3-2024': 'mba13_skyblue',
  'mba-15-m2-2023': 'mba15_midnight',
  'mba-15-m3-2024': 'mba15_starlight',
  'mba-15-m4-2025': 'macbook_air_un_1',
  'mba-15-m5-2025': 'macbook_air_un_2', // Cleaned from 'm5' request
  // MacBook Pro
  'mbp-14-m4p-2024': 'mbp14_silver',
  'mbp-14-m4m-2024': 'mbp14_spaceblack',
  'mbp-16-m4p-2024': 'mbp16_silver',
  'mbp-16-m4m-2024': 'mbp16_spaceblack',
  'mbp-14-m5p-2025': 'mbp14_spaceblack_1',
  'mbp-16-m5p-2025': 'mbp16_silver_1',
  'mbp-14-m1p-2021': 'mac_macbook_pro_un_1',
  'mbp-16-m1m-2021': 'mac_macbook_pro_un_3',

  // iPads
  'ipad-10-2022': 'ipad_2022_yellow',
  'ipad-air-6-2024': 'ipad_air_11in_blue',
  'ipad-air-7-2025': 'ipad_air_13in_purple',
  'ipad-mini-7-2024': 'ipad_mini_purple',
  'ipad-pro-11-m4-2024': 'ipad_pro_11_spaceblack',
  'ipad-pro-13-m4-2024': 'ipad_pro_13_spaceblack',
  'ipad-pro-13-m5-2025': 'ipad_pro_13_silver',
  'ipad-2022-hero-blue-wifi-select': 'ipad_2022_blue',

  // iPhones
  'iphone-16-pro-max': 'iphone_16_pro_6_deserttitanium',
  'iphone-16-pro': 'iphone_16_pro_6_naturaltitanium',
  'iphone-16-pro-un': 'iphone_16_pro_un_1',
  'iphone-16': 'iphone_16_6_teal',
  'iphone-16-plus': 'iphone_16_6_ultramarine',
  'iphone-15-pro': 'iphone_15_pro_6_blacktitanium',
  'iphone-15-2023': 'iphone_15_6_pink',
  'iphone-14-2022': 'iphone_14_6_blue',
  'iphone-se-2022': 'iphone_se_midnight',

  // Watch
  'watch-s10-2024': 'watch_s11',
  'watch-ultra-2-2023': 'watch_ultra',
  'watch-ultra-3-2025': 'watch_ultra3',
  'watch-se-2024': 'watch_se3',

  // AirPods
  'airpods-4-2024': 'airpods_4_anc',
  'airpods-pro-2-2022': 'airpods_pro',
  'airpods-pro-3-2025': 'airpods_pro_3_1',
  'airpods-max-usb-2024': 'airpods_max_blue',
  'airpods-max-2020': 'airpods_max_midnight',

  // Others
  'imac-24-m4-2024': 'imac_blue',
  'imac-24-m5-2025': 'imac_purple',
  'apple-tv-4k-2024': 'apple_tv_4k',
  'homepod-mini-2022': 'homepod_mini',
  'mac-mini-m4-2024': 'mac_mini',
  'mac-studio-m4m-2025': 'mac_studio',
};

/// CDN Slugs for unique products not in local assets (Official Apple Store).
const Map<String, String> _cdnProductImageSlugs = {
  // Mac
  'mba-13-2018': 'macbook-air-gold-select-201810',
  'mba-13-2019': 'macbook-air-silver-select-201907',
  'mbp-13-2018': 'macbook-pro-13-spacegray-select-201807',
  'mac-pro-m2u-2023': 'mac-pro-tower-select-202306',
  'mac-studio-m1m-2022': 'mac-studio-select-202203',

  // iPad
  'ipad-9-2021': 'ipad-9-select-wifi-spacegray-202109',
  'ipad-mini-6-2021': 'ipad-mini-select-wifi-pink-202109',
  'ipad-pro-11-2018': 'ipad-pro-11-select-wifi-spacegray-201810',

  // iPhone
  'iphone-13': 'iphone-13-blue-select-2021',
  'iphone-12': 'iphone-12-purple-select-2021',
  'iphone-11': 'iphone-11-white-select-2019',

  // Accessories
  'magic-keyboard-touch-2024': 'MXK83',
  'magic-mouse-2024': 'MXK63',
  'magic-trackpad-2024': 'MXKA3',
  'apple-pencil-pro-2024': 'MX2D3',
  'apple-pencil-usb-2023': 'MUWA3',
  'apple-pencil-1': 'MK0C2',
  'apple-pencil-2': 'MU8F2',
  'magic-keyboard-ipad-pro-13-m4': 'MWR23',
  'magic-keyboard-ipad-air-13': 'MNKT3',
  'smart-folio-ipad-pro-13-m4': 'MWUT3',
  'magsafe-charger-2024': 'MGD74',
  'usb-c-power-adapter-20w-2025': 'MWVV3',
  'usb-c-power-adapter-35w': 'MNWM3',
  'usb-c-charge-cable-240w-2024': 'MU2G3',
  'usb-c-digital-av-adapter-2024': 'MUF82',
  'usb-c-35mm-adapter': 'MU7E2',
  'thunderbolt-5-pro-cable-2025': 'MDW94',
  'airtag-4pack-2021': 'airtag-4pack-select-202104',
  'airtag-1pack': 'MX532',
  'iphone-16-silicone-case': 'MYTP3',
  'earpods-usb-c': 'MTJY3',
  'magsafe-wallet': 'MQYX3',

  // Vision
  'vision-pro-2024': 'apple-vision-pro-select-202401',
  'vision-pro-m5-2025': 'apple-vision-pro-select-202401',

  // Displays
  'studio-display-2022': 'studio-display-select-202203',
  'pro-display-xdr-2019': 'pro-display-xdr-select-201912',
};
