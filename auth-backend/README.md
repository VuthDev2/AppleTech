# Auth Backend (Firebase + Express)

## Overview
A lightweight backend built with **Node.js**, **Express**, **TypeScript**, and **Firebase Admin SDK**. It provides:
- User registration and login via Firebase Auth REST API
- Firebase ID token verification for protected routes
- User profile, bag, wishlist, orders, addresses, cards, and notifications APIs
- Refresh-token revocation and logout
- Secure middleware: Helmet, CORS, and rate limiting

## Prerequisites
- Node.js (v20+) and npm
- A Firebase project with **Email/Password** enabled
- Service-account JSON file from Firebase Console

## Setup
1. Open the project at `/Users/macos/Desktop/appletech/auth-backend`.
2. Install dependencies:
   ```bash
   npm install
   ```
3. Create a `.env` file and fill in:
   ```text
   PORT=4000
   FIREBASE_API_KEY=your_firebase_web_api_key
   FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
   ```
4. Place the downloaded `serviceAccountKey.json` in this folder, next to `package.json`.

## Development
Run the development server with hot reloading:
```bash
npm run dev
```
The API will be available at `http://localhost:4000`.

## Seed Firestore
If the Firestore Database page is empty, seed it with demo data:

```bash
npm run seed
```

This creates:
- `users/{demoUid}` with bag, wishlist, address, and notification subcollections
- `products/iphone-16-pro`
- `products/mbp-14-m4p-2024`

If seeding fails with `invalid_grant` or `Invalid JWT Signature`, generate a
new Firebase Admin SDK private key from Firebase Console:
Project settings -> Service accounts -> Generate new private key.
Save it as `auth-backend/google-service.json`, then run `npm run seed` again.

## API Endpoints
| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/auth/register` | Register a new user with email and password. |
| `POST` | `/auth/login` | Log in and receive Firebase ID and refresh tokens. |
| `POST` | `/auth/refresh` | Refresh an ID token. |
| `POST` | `/auth/logout` | Revoke refresh tokens. |
| `GET` | `/protected` | Example protected route. |
| `GET` | `/users/me` | Fetch the authenticated user's profile. |
| `PATCH` | `/users/me` | Update display name and locale. |
| `GET` | `/users/me/orders` | Fetch order history. |
| `POST` | `/users/me/orders` | Create an order. |
| `GET` | `/users/me/wishlist` | Fetch wishlist product IDs. |
| `POST` | `/users/me/wishlist` | Add a wishlist product. |
| `DELETE` | `/users/me/wishlist/:productId` | Remove a wishlist product. |
| `GET` | `/users/me/bag` | Fetch shopping bag items. |
| `PUT` | `/users/me/bag/:itemId` | Create or update a bag item. |
| `DELETE` | `/users/me/bag/:itemId` | Remove a bag item. |
| `DELETE` | `/users/me/bag` | Clear the shopping bag. |
| `GET` | `/users/me/addresses` | Fetch saved addresses. |
| `PUT` | `/users/me/addresses/:addressId` | Create or update an address. |
| `DELETE` | `/users/me/addresses/:addressId` | Remove an address. |
| `GET` | `/users/me/cards` | Fetch saved payment cards. |
| `PUT` | `/users/me/cards/:cardId` | Create or update a card. |
| `DELETE` | `/users/me/cards/:cardId` | Remove a card. |
| `GET` | `/users/me/notifications` | Fetch notifications. |
| `POST` | `/users/me/notifications` | Create a notification. |
| `PATCH` | `/users/me/notifications/:notificationId` | Update notification read state. |
| `POST` | `/users/me/notifications/mark-all-read` | Mark all notifications as read. |
| `DELETE` | `/users/me/notifications/:notificationId` | Remove a notification. |

All `/users/*` routes require:
```text
Authorization: Bearer <firebase_id_token>
```

## Testing
You can test quickly with `curl` or Postman:
```bash
curl -X POST http://localhost:4000/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","password":"Secret123!"}'
```
Replace with your credentials and follow the flow.

## Security Notes
- Helmet, CORS, and rate limiting are enabled by default.
- Keep Firebase service-account JSON and API keys out of source control.
- Use HTTPS in production.

## License
MIT
