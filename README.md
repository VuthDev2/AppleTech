# appletech

A new Flutter project.

## Backend integration

The Flutter app uses Firebase Auth for sign-in, then sends the Firebase ID token
to the Express backend for user data such as bag, wishlist, orders, addresses,
cards, notifications, and profile locale/name.

Start the backend first:

```bash
cd auth-backend
npm run dev
```

Run Flutter with the backend URL:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:4000
```

For an Android emulator, use `http://10.0.2.2:4000` instead of localhost.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
