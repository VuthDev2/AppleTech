"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyToken = verifyToken;
const firebase_1 = require("../firebase");
/**
 * Middleware that verifies a Firebase ID token from the Authorization header.
 * Sets req.uid to the verified UID on success.
 */
async function verifyToken(req, res, next) {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
        res.status(401).json({ error: 'Missing or malformed Authorization header' });
        return;
    }
    const idToken = authHeader.split(' ')[1];
    try {
        const decoded = await firebase_1.auth.verifyIdToken(idToken);
        req.uid = decoded.uid;
        next();
    }
    catch (err) {
        console.error('Token verification failed:', err.message);
        res.status(401).json({ error: 'Unauthorized: invalid or expired token' });
    }
}
//# sourceMappingURL=verifyToken.js.map