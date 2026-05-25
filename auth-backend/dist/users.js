"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const firebase_1 = require("./firebase");
const verifyToken_1 = require("./middleware/verifyToken");
const zod_1 = require("zod");
const router = (0, express_1.Router)();
// All routes require a valid Firebase ID token.
router.use(verifyToken_1.verifyToken);
const updateProfileSchema = zod_1.z.object({
    displayName: zod_1.z.string().min(1).max(100).optional(),
    locale: zod_1.z.enum(['en', 'km', 'zh']).optional(),
});
const cartItemSchema = zod_1.z.object({
    productId: zod_1.z.string().min(1),
    variantId: zod_1.z.string().min(1),
    quantity: zod_1.z.number().int().positive(),
});
const wishlistItemSchema = zod_1.z.object({
    productId: zod_1.z.string().min(1),
});
const createOrderSchema = zod_1.z.object({
    id: zod_1.z.string().min(1),
    total: zod_1.z.number().nonnegative(),
    status: zod_1.z.string().default('Preparing for delivery'),
    items: zod_1.z.array(cartItemSchema),
});
const addressSchema = zod_1.z.object({
    id: zod_1.z.string().min(1),
    fullName: zod_1.z.string().min(1).max(120),
    street: zod_1.z.string().min(1).max(240),
    city: zod_1.z.string().min(1).max(120),
    postalCode: zod_1.z.string().min(1).max(32),
    phone: zod_1.z.string().min(1).max(40),
    isDefault: zod_1.z.boolean().default(false),
});
const cardSchema = zod_1.z.object({
    id: zod_1.z.string().min(1),
    cardholderName: zod_1.z.string().min(1).max(120),
    cardNumber: zod_1.z.string().min(1).max(32),
    expiryDate: zod_1.z.string().min(1).max(12),
    brand: zod_1.z.string().min(1).max(80),
    themeColor: zod_1.z.number().int(),
});
const notificationSchema = zod_1.z.object({
    id: zod_1.z.string().min(1),
    title: zod_1.z.string().min(1).max(140),
    body: zod_1.z.string().min(1).max(500),
    kind: zod_1.z.enum(['order', 'promo', 'product', 'system']).default('system'),
    isRead: zod_1.z.boolean().default(false),
});
const notificationReadSchema = zod_1.z.object({
    isRead: zod_1.z.boolean(),
});
router.get('/me', async (req, res) => {
    try {
        const uid = req.uid;
        const [userRecord, profileSnap] = await Promise.all([
            firebase_1.auth.getUser(uid),
            firebase_1.db.collection('users').doc(uid).get(),
        ]);
        const firestoreData = profileSnap.exists ? profileSnap.data() : {};
        if (!profileSnap.exists) {
            await firebase_1.db.collection('users').doc(uid).set({
                email: userRecord.email || '',
                displayName: userRecord.displayName || 'AppleTech Customer',
                createdAt: new Date(),
            });
        }
        return res.json({
            uid: userRecord.uid,
            email: userRecord.email,
            displayName: userRecord.displayName || firestoreData?.displayName,
            emailVerified: userRecord.emailVerified,
            createdAt: userRecord.metadata.creationTime,
            locale: firestoreData?.locale || null,
        });
    }
    catch (err) {
        console.error('GET /users/me error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.patch('/me', async (req, res) => {
    try {
        const uid = req.uid;
        const result = updateProfileSchema.safeParse(req.body);
        if (!result.success) {
            return res.status(400).json({ error: 'Invalid input', details: result.error.format() });
        }
        const { displayName, locale } = result.data;
        const updates = {};
        if (displayName !== undefined) {
            await firebase_1.auth.updateUser(uid, { displayName });
            updates.displayName = displayName;
        }
        if (locale !== undefined)
            updates.locale = locale;
        if (Object.keys(updates).length > 0) {
            await firebase_1.db.collection('users').doc(uid).set(updates, { merge: true });
        }
        return res.json({ success: true, updated: updates });
    }
    catch (err) {
        console.error('PATCH /users/me error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.get('/me/orders', async (req, res) => {
    try {
        const uid = req.uid;
        const snap = await firebase_1.db
            .collection('users')
            .doc(uid)
            .collection('orders')
            .orderBy('placedAt', 'desc')
            .get();
        const orders = snap.docs.map((doc) => {
            const data = doc.data();
            return {
                id: data.id ?? doc.id,
                placedAt: data.placedAt?.toDate?.()?.toISOString() ?? null,
                total: data.total,
                status: data.status,
                items: data.items ?? [],
            };
        });
        return res.json({ orders });
    }
    catch (err) {
        console.error('GET /users/me/orders error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.post('/me/orders', async (req, res) => {
    try {
        const uid = req.uid;
        const result = createOrderSchema.safeParse(req.body);
        if (!result.success) {
            return res.status(400).json({ error: 'Invalid input', details: result.error.format() });
        }
        const order = result.data;
        const placedAt = new Date();
        await firebase_1.db
            .collection('users')
            .doc(uid)
            .collection('orders')
            .doc(order.id)
            .set({ ...order, placedAt });
        return res.status(201).json({ id: order.id, placedAt: placedAt.toISOString() });
    }
    catch (err) {
        console.error('POST /users/me/orders error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.get('/me/wishlist', async (req, res) => {
    try {
        const uid = req.uid;
        const snap = await firebase_1.db.collection('users').doc(uid).collection('wishlist').get();
        const productIds = snap.docs.map((doc) => doc.id);
        return res.json({ productIds });
    }
    catch (err) {
        console.error('GET /users/me/wishlist error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.post('/me/wishlist', async (req, res) => {
    try {
        const uid = req.uid;
        const result = wishlistItemSchema.safeParse(req.body);
        if (!result.success) {
            return res.status(400).json({ error: 'Invalid input', details: result.error.format() });
        }
        const { productId } = result.data;
        await firebase_1.db.collection('users').doc(uid).collection('wishlist').doc(productId).set({ productId });
        return res.status(201).json({ productId });
    }
    catch (err) {
        console.error('POST /users/me/wishlist error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.delete('/me/wishlist/:productId', async (req, res) => {
    try {
        const uid = req.uid;
        await firebase_1.db.collection('users').doc(uid).collection('wishlist').doc(req.params.productId).delete();
        return res.status(204).send();
    }
    catch (err) {
        console.error('DELETE /users/me/wishlist/:productId error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.get('/me/bag', async (req, res) => {
    try {
        const uid = req.uid;
        const snap = await firebase_1.db.collection('users').doc(uid).collection('bag').get();
        const items = snap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
        return res.json({ items });
    }
    catch (err) {
        console.error('GET /users/me/bag error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.put('/me/bag/:itemId', async (req, res) => {
    try {
        const uid = req.uid;
        const result = cartItemSchema.safeParse(req.body);
        if (!result.success) {
            return res.status(400).json({ error: 'Invalid input', details: result.error.format() });
        }
        const expectedId = `${result.data.productId}__${result.data.variantId}`;
        if (req.params.itemId !== expectedId) {
            return res.status(400).json({ error: `itemId must be ${expectedId}` });
        }
        await firebase_1.db.collection('users').doc(uid).collection('bag').doc(req.params.itemId).set(result.data);
        return res.json({ id: req.params.itemId, ...result.data });
    }
    catch (err) {
        console.error('PUT /users/me/bag/:itemId error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.delete('/me/bag/:itemId', async (req, res) => {
    try {
        const uid = req.uid;
        await firebase_1.db.collection('users').doc(uid).collection('bag').doc(req.params.itemId).delete();
        return res.status(204).send();
    }
    catch (err) {
        console.error('DELETE /users/me/bag/:itemId error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.delete('/me/bag', async (req, res) => {
    try {
        const uid = req.uid;
        await deleteCollection(firebase_1.db.collection('users').doc(uid).collection('bag'));
        return res.status(204).send();
    }
    catch (err) {
        console.error('DELETE /users/me/bag error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.get('/me/addresses', async (req, res) => {
    try {
        const uid = req.uid;
        const snap = await firebase_1.db.collection('users').doc(uid).collection('addresses').get();
        const addresses = snap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
        return res.json({ addresses });
    }
    catch (err) {
        console.error('GET /users/me/addresses error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.put('/me/addresses/:addressId', async (req, res) => {
    try {
        const uid = req.uid;
        const result = addressSchema.safeParse({ ...req.body, id: req.params.addressId });
        if (!result.success) {
            return res.status(400).json({ error: 'Invalid input', details: result.error.format() });
        }
        await firebase_1.db.collection('users').doc(uid).collection('addresses').doc(req.params.addressId).set(result.data);
        return res.json(result.data);
    }
    catch (err) {
        console.error('PUT /users/me/addresses/:addressId error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.delete('/me/addresses/:addressId', async (req, res) => {
    try {
        const uid = req.uid;
        await firebase_1.db.collection('users').doc(uid).collection('addresses').doc(req.params.addressId).delete();
        return res.status(204).send();
    }
    catch (err) {
        console.error('DELETE /users/me/addresses/:addressId error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.get('/me/cards', async (req, res) => {
    try {
        const uid = req.uid;
        const snap = await firebase_1.db.collection('users').doc(uid).collection('cards').get();
        const cards = snap.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
        return res.json({ cards });
    }
    catch (err) {
        console.error('GET /users/me/cards error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.put('/me/cards/:cardId', async (req, res) => {
    try {
        const uid = req.uid;
        const result = cardSchema.safeParse({ ...req.body, id: req.params.cardId });
        if (!result.success) {
            return res.status(400).json({ error: 'Invalid input', details: result.error.format() });
        }
        await firebase_1.db.collection('users').doc(uid).collection('cards').doc(req.params.cardId).set(result.data);
        return res.json(result.data);
    }
    catch (err) {
        console.error('PUT /users/me/cards/:cardId error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.delete('/me/cards/:cardId', async (req, res) => {
    try {
        const uid = req.uid;
        await firebase_1.db.collection('users').doc(uid).collection('cards').doc(req.params.cardId).delete();
        return res.status(204).send();
    }
    catch (err) {
        console.error('DELETE /users/me/cards/:cardId error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.get('/me/notifications', async (req, res) => {
    try {
        const uid = req.uid;
        const snap = await firebase_1.db
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .orderBy('createdAt', 'desc')
            .get();
        const notifications = snap.docs.map((doc) => {
            const data = doc.data();
            return {
                id: data.id ?? doc.id,
                ...data,
                createdAt: data.createdAt?.toDate?.()?.toISOString() ?? null,
            };
        });
        return res.json({ notifications });
    }
    catch (err) {
        console.error('GET /users/me/notifications error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.post('/me/notifications', async (req, res) => {
    try {
        const uid = req.uid;
        const result = notificationSchema.safeParse(req.body);
        if (!result.success) {
            return res.status(400).json({ error: 'Invalid input', details: result.error.format() });
        }
        const notification = { ...result.data, createdAt: new Date() };
        await firebase_1.db
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .doc(notification.id)
            .set(notification);
        return res.status(201).json({ ...notification, createdAt: notification.createdAt.toISOString() });
    }
    catch (err) {
        console.error('POST /users/me/notifications error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.patch('/me/notifications/:notificationId', async (req, res) => {
    try {
        const uid = req.uid;
        const result = notificationReadSchema.safeParse(req.body);
        if (!result.success) {
            return res.status(400).json({ error: 'Invalid input', details: result.error.format() });
        }
        await firebase_1.db
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .doc(req.params.notificationId)
            .update(result.data);
        return res.json({ id: req.params.notificationId, ...result.data });
    }
    catch (err) {
        console.error('PATCH /users/me/notifications/:notificationId error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.post('/me/notifications/mark-all-read', async (req, res) => {
    try {
        const uid = req.uid;
        const snap = await firebase_1.db
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .where('isRead', '==', false)
            .get();
        const batch = firebase_1.db.batch();
        snap.docs.forEach((doc) => batch.update(doc.ref, { isRead: true }));
        await batch.commit();
        return res.json({ updated: snap.size });
    }
    catch (err) {
        console.error('POST /users/me/notifications/mark-all-read error:', err);
        return res.status(500).json({ error: err.message });
    }
});
router.delete('/me/notifications/:notificationId', async (req, res) => {
    try {
        const uid = req.uid;
        await firebase_1.db
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .doc(req.params.notificationId)
            .delete();
        return res.status(204).send();
    }
    catch (err) {
        console.error('DELETE /users/me/notifications/:notificationId error:', err);
        return res.status(500).json({ error: err.message });
    }
});
async function deleteCollection(collection) {
    const batchSize = 100;
    let snap;
    do {
        snap = await collection.limit(batchSize).get();
        const batch = firebase_1.db.batch();
        snap.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
    } while (snap.size === batchSize);
}
exports.default = router;
//# sourceMappingURL=users.js.map