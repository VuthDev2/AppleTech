# Images

## Home promo carousel (required local assets)

These three files power the auto-rotating banners under the search bar on the home screen:

- `macbook_pro.png`
- `iphone_16_pro.png`
- `watch_ultra.png`

Do not remove or replace with CDN URLs in the carousel — the UI expects these assets.

Files must be **PNG with transparent background** (`fmt=png-alpha` from Apple CDN). Re-download example:

```bash
curl -fsSL "https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/mbp16-silver-select-202410?wid=1400&hei=1400&fmt=png-alpha" -o macbook_pro.png
```

## Product catalog

Product photos in lists and detail screens load from **Apple's store CDN** at runtime.

- Mapping: `lib/data/apple_product_images.dart` 
