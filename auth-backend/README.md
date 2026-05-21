# Auth Backend (Firebase + Express)

## Overview
A lightweight authentication backend built with **Node.js**, **Express**, **TypeScript**, and **Firebase Admin SDK**. It provides:
- User registration & login via Firebase Auth REST API
- JWT access token handling (wrapped by Firebase custom tokens)
- Refresh‑token revocation & logout
- Secure middle‑wares (Helmet, CORS, rate‑limiting)

## Prerequisites
- Node.js (v20+) and npm
- A Firebase project with **Email/Password** enabled
- Service‑account JSON file (`google-service.json`) from Firebase console

## Setup
1. **Clone / open the project** at `/Users/macos/Desktop/appletech/auth-backend`.
2. dependencies (already done):
   ```bash
   npm install
   ```
3. Create a `.env` file (already created) and fill in:
   ```text
   PORT=4000
   FIREBASE_API_KEY=your_firebase_web_api_key
   FIREBASE_SERVICE_ACCOUNT_PATH=./google-service.json
   ```
4. **Add the service‑account file**:
   Place the downloaded `serviceAccountKey.json` in the project root (same folder as `package.json`).

## Development
Run the development server with hot‑reloading:
```bash
npm run dev
```
The API will be available at `http://localhost:4000`.

## API Endpoints
| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/auth/register` | Register a new user (email & password). |
| `POST` | `/auth/login` | Log in and receive a Firebase custom token. |
| `POST` | `/auth/refresh` | Refresh an access token. |
| `POST` | `/auth/logout` | Revoke refresh token. |
| `GET`  | `/protected` | Example protected route (requires valid JWT). |

## Testing
You can test quickly with `curl` or Postman:
```bash
curl -X POST http://localhost:4000/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"test@example.com","password":"Secret123!"}'
```
Replace with your credentials and follow the flow.

## Security notes
- Helmet, CORS, and rate‑limiting are enabled by default.
- Tokens are signed using the Firebase secret; never expose them.
- Consider enabling HTTPS in production.

## License
MIT
