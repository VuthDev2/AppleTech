# Product images

Product photos load from **Apple's official store CDN** at runtime (high-resolution PNG, cached on device).

- Mapping: `lib/data/apple_product_images.dart`
- Each catalog item has its own image slug (no shared placeholder across Mac / iPhone / iPad / Watch / iMac / AirPods).

Local assets in this folder are optional (e.g. `appletech_logo.png` for branding).
