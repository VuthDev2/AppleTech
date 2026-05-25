"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const firebase_1 = require("./firebase");
const zod_1 = require("zod");
const dotenv_1 = __importDefault(require("dotenv"));
// import fetch from 'node-fetch'; // using global fetch in Node 20+
dotenv_1.default.config();
const router = (0, express_1.Router)();
// Load environment variables
const API_KEY = process.env.FIREBASE_API_KEY;
if (!API_KEY) {
    throw new Error('FIREBASE_API_KEY is not set in .env');
}
// Schemas
const registerSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    password: zod_1.z.string().min(6),
});
const loginSchema = zod_1.z.object({
    email: zod_1.z.string().email(),
    password: zod_1.z.string().min(6),
});
// Register new user
router.post('/register', async (req, res) => {
    try {
        const result = registerSchema.safeParse(req.body);
        if (!result.success) {
            return res.status(400).json({ error: 'Invalid input', details: result.error.format() });
        }
        const { email, password } = result.data;
        const userRecord = await firebase_1.auth.createUser({ email, password });
        // Create initial Firestore profile document
        await firebase_1.db.collection('users').doc(userRecord.uid).set({
            email: userRecord.email,
            displayName: userRecord.displayName || '',
            createdAt: new Date(),
        });
        return res.status(201).json({ uid: userRecord.uid, email: userRecord.email });
    }
    catch (err) {
        console.error(err);
        return res.status(500).json({ error: err.message });
    }
});
// Login – uses Firebase Auth REST API to verify password and obtain ID token
router.post('/login', async (req, res) => {
    try {
        const result = loginSchema.safeParse(req.body);
        if (!result.success) {
            return res.status(400).json({ error: 'Invalid input', details: result.error.format() });
        }
        const { email, password } = result.data;
        const response = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password, returnSecureToken: true }),
        });
        const data = await response.json();
        if (!response.ok) {
            return res.status(401).json({ error: data.error?.message || 'Authentication failed' });
        }
        // data contains idToken, refreshToken, expiresIn, localId etc.
        return res.json({ idToken: data.idToken, refreshToken: data.refreshToken, expiresIn: data.expiresIn, uid: data.localId });
    }
    catch (err) {
        console.error(err);
        return res.status(500).json({ error: err.message });
    }
});
// Refresh token endpoint
router.post('/refresh', async (req, res) => {
    const { refreshToken } = req.body;
    if (!refreshToken) {
        return res.status(400).json({ error: 'refreshToken is required' });
    }
    try {
        const response = await fetch(`https://securetoken.googleapis.com/v1/token?key=${API_KEY}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `grant_type=refresh_token&refresh_token=${refreshToken}`,
        });
        const data = await response.json();
        if (!response.ok) {
            return res.status(400).json({ error: data.error?.message || 'Refresh failed' });
        }
        return res.json({ idToken: data.id_token, refreshToken: data.refresh_token, expiresIn: data.expires_in, uid: data.user_id });
    }
    catch (err) {
        console.error(err);
        return res.status(500).json({ error: err.message });
    }
});
// Logout (revoke refresh tokens)
router.post('/logout', async (req, res) => {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Missing or malformed Authorization header' });
    }
    const idToken = authHeader.split(' ')[1];
    try {
        const decoded = await firebase_1.auth.verifyIdToken(idToken);
        await firebase_1.auth.revokeRefreshTokens(decoded.uid);
        return res.json({ message: 'Refresh tokens revoked' });
    }
    catch (err) {
        console.error(err);
        return res.status(500).json({ error: err.message });
    }
});
exports.default = router;
//# sourceMappingURL=auth.js.map