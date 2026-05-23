# 🍎 AppleTech

A modern Flutter e-commerce application inspired by Apple’s ecosystem design.  
AppleTech provides a smooth shopping experience with Firebase authentication, Cloud Firestore integration, wishlist management, cart persistence, profile management, and optional Express backend support.

---

## ✨ Features

- 🔐 Firebase Authentication
  - Email & Password
  - Google Sign-In

- 🛍️ E-Commerce Functionality
  - Product catalog
  - Shopping cart
  - Wishlist
  - Order management

- 👤 User Profile System
  - Address management
  - Payment cards
  - Notifications
  - Profile photo upload

- ☁️ Cloud Firestore Integration
  - Real-time data persistence
  - Secure user data storage

- ⚡ Optional Express Backend
  - Firebase Admin SDK
  - REST APIs
  - Product seeding support

- 📱 Cross Platform Support
  - Android
  - iOS
  - Web
  - macOS
  - Windows
  - Linux

---

# 📸 Screenshots

## Home Screen
![Home Screen](Screenshot%202026-05-23%20at%204.03.33%20PM.png)

## Product View
![Product View](Screenshot%202026-05-23%20at%204.09.20%20PM.png)

---

# 🛠️ Tech Stack

## Frontend
- Flutter
- Dart

## Backend
- Firebase Authentication
- Cloud Firestore
- Firebase Storage (optional)
- Express.js (optional backend)

## Tools & Services
- Firebase
- Node.js
- Cloudflare R2 (optional)

---

# 📂 Project Structure

```bash
AppleTech/
│
├── lib/                 # Flutter source code
├── assets/              # Images and assets
├── auth-backend/        # Optional Express backend
├── android/             # Android configuration
├── ios/                 # iOS configuration
├── web/                 # Web support
├── windows/             # Windows support
├── macos/               # macOS support
├── linux/               # Linux support
└── test/                # Test files
```

---

# 🔥 Firebase Setup

## 1. Create Firebase Project

Create or use the Firebase project:

```bash
appletech-6b722
```

---

## 2. Enable Authentication

Enable:
- Email/Password Authentication
- Google Sign-In

---

## 3. Create Firestore Database

Create a Cloud Firestore database in Firebase Console.

---

## 4. Deploy Firebase Rules

```bash
npm run firebase:rules:deploy
```

---

# 🚀 Run The Application

## Default Mode (Direct Firestore)

```bash
flutter pub get
flutter run
```

The app will connect directly to Firebase using Firestore + Firebase Authentication.

---

# 🧠 Optional Express Backend

The `auth-backend` folder provides REST APIs using Express.js and Firebase Admin SDK.

## Setup Backend

### 1. Generate Firebase Admin SDK Key

Go to:

Firebase Console → Project Settings → Service Accounts → Generate New Private Key

Save the key as:

```bash
auth-backend/google-service.json
```

---

### 2. Start Backend Server

```bash
cd auth-backend
npm install
npm run dev
```

---

### 3. Seed Demo Products

```bash
npm run seed
```

---

### 4. Run Flutter With Backend

```bash
flutter run --dart-define=USE_BACKEND_API=true --dart-define=API_BASE_URL=http://localhost:4000
```

For Android Emulator:

```bash
http://10.0.2.2:4000
```

---

# 🖼️ Profile Photo Storage

By default, profile photos are compressed and stored directly in Firestore.

No Firebase Storage or billing required.

```bash
flutter run
```

---

## Optional Storage Providers

| Storage Provider | Configuration |
|------------------|---------------|
| Cloudflare R2 | `--dart-define=PROFILE_STORAGE=r2` |
| Firebase Storage | `--dart-define=PROFILE_STORAGE=firebase` |

---

# 🔐 Security

- Firestore security rules included
- Firebase Authentication secured
- Optional backend verification using Firebase Admin SDK

---

# 📦 Dependencies

Main dependencies used in this project:

- firebase_auth
- cloud_firestore
- google_sign_in
- flutter_bloc
- provider
- cached_network_image

---

# 🎯 Future Improvements

- ✅ Payment gateway integration
- ✅ Admin dashboard
- ✅ Push notifications
- ✅ AI product recommendations
- ✅ Dark mode support
- ✅ Product reviews & ratings

---

# 👨‍💻 Author

Developed by :contentReference[oaicite:1]{index=1}

GitHub: :contentReference[oaicite:2]{index=2}

---

# 📄 License

This project is licensed under the MIT License.

---

# ⭐ Support

If you like this project:

- Give it a ⭐ on GitHub
- Fork the repository
- Share feedback and suggestions
