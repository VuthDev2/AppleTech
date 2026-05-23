# appletech

A new Flutter project.

## Backend and database

User data (bag, wishlist, orders, addresses, cards, notifications, profile) is stored in **Cloud Firestore**.

By default the Flutter app talks to Firestore **directly** (Firebase Auth + security rules). No Express server is required for day-to-day use.

### 1. Firebase setup

1. Create or use the Firebase project `appletech-6b722` (see `lib/firebase_options.dart`).
2. Enable **Authentication** → Email/Password and Google.
3. Create a **Firestore** database.
4. Deploy security rules from this repo:

```bash
npm run firebase:rules:deploy
```

### 2. Run the app (direct Firestore — default)

```bash
flutter pub get
flutter run
```

Sign up or sign in; cart, wishlist, and profile changes persist per account in Firestore.

### 3. Optional: Express backend (`USE_BACKEND_API=true`)

The `auth-backend` folder provides the same APIs via Express + Firebase Admin SDK.

1. In [Firebase Console](https://console.firebase.google.com) → Project settings → Service accounts → **Generate new private key**.
2. Save the file as `auth-backend/google-service.json` (replace the revoked key).
3. Start the API:

```bash
cd auth-backend
npm install
npm run dev
```

4. Seed demo data (after the new key works):

```bash
npm run seed
```

5. Run Flutter with the backend:

```bash
flutter run --dart-define=USE_BACKEND_API=true --dart-define=API_BASE_URL=http://localhost:4000
```

For an Android emulator, use `http://10.0.2.2:4000` instead of `localhost`.

### Profile photo (free on Spark — default)

By default, profile photos are **compressed and stored in Firestore** on the `photoUrl` field (no Firebase Storage, no Cloudflare, no credit card).

```bash
flutter run
```

Keep images under ~400 KB (the picker compresses automatically). Works with direct Firestore + Firebase Auth on the **Spark** plan.

**Optional paid / external storage** (only if you want URLs instead of inline data):

| Mode | Command | Notes |
|------|---------|--------|
| Cloudflare R2 | `--dart-define=PROFILE_STORAGE=r2` + running `auth-backend` | May require billing on Cloudflare |
| Firebase Storage | `--dart-define=PROFILE_STORAGE=firebase` | Requires Blaze (pay-as-you-go, not a monthly subscription) |

Redeploy Firestore rules (includes `photoUrl`):

```bash
npm run firebase:rules:deploy
```

### Product catalog

Product listings still ship in the app (`lib/data/product_catalog.dart`). Firestore `products` collection is used for optional catalog sync via `npm run seed` in `auth-backend`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
