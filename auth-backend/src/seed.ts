import { auth, db } from './firebase';

const now = new Date();

async function seed() {
  const demoEmail = process.env.SEED_USER_EMAIL || 'demo@appletech.local';
  const demoPassword = process.env.SEED_USER_PASSWORD || 'password123';

  let uid: string;
  try {
    uid = (await auth.getUserByEmail(demoEmail)).uid;
  } catch {
    const user = await auth.createUser({
      email: demoEmail,
      password: demoPassword,
      displayName: 'AppleTech Demo',
    });
    uid = user.uid;
  }

  const userRef = db.collection('users').doc(uid);
  await userRef.set(
    {
      email: demoEmail,
      displayName: 'AppleTech Demo',
      locale: 'en',
      createdAt: now,
    },
    { merge: true },
  );

  await Promise.all([
    userRef.collection('wishlist').doc('iphone-16-pro').set({
      productId: 'iphone-16-pro',
    }),
    userRef
      .collection('bag')
      .doc('mbp-14-m4p-2024__mbp-14-m4p-2024-space-gray-14-inch-24gb-unified-memory-256gb')
      .set({
        productId: 'mbp-14-m4p-2024',
        variantId: 'mbp-14-m4p-2024-space-gray-14-inch-24gb-unified-memory-256gb',
        quantity: 1,
      }),
    userRef.collection('addresses').doc('addr-demo').set({
      id: 'addr-demo',
      fullName: 'AppleTech Demo',
      street: '123 AppleTech Way',
      city: 'Cupertino',
      postalCode: '95014',
      phone: '+1 555 0100',
      isDefault: true,
    }),
    userRef.collection('notifications').doc('notif-demo').set({
      id: 'notif-demo',
      title: 'Welcome to AppleTech',
      body: 'Your backend and Firestore database are connected.',
      createdAt: now,
      kind: 'system',
      isRead: false,
    }),
    db.collection('products').doc('iphone-16-pro').set({
      name: 'iPhone 16 Pro',
      category: 'iPhone',
      basePrice: 999,
      inStock: true,
      updatedAt: now,
    }),
    db.collection('products').doc('mbp-14-m4p-2024').set({
      name: 'MacBook Pro 14-inch',
      category: 'Mac',
      basePrice: 1999,
      inStock: true,
      updatedAt: now,
    }),
  ]);

  console.log(`Seeded Firestore for ${demoEmail} (${uid}).`);
}

seed()
  .catch((error) => {
    console.error('Seed failed:', error);
    process.exitCode = 1;
  })
  .finally(() => process.exit());
