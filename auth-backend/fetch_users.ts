import admin from 'firebase-admin';
import { readFileSync } from 'fs';
import path from 'path';

const serviceAccountPath = path.join(__dirname, 'google-service.json');
const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf8'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function fetchUsers() {
  try {
    const listUsersResult = await admin.auth().listUsers(100);
    if (listUsersResult.users.length === 0) {
      console.log('No users found in Firebase Authentication.');
      return;
    }

    console.log('--- User Profiles ---');
    listUsersResult.users.forEach((userRecord) => {
      console.log({
        uid: userRecord.uid,
        email: userRecord.email,
        displayName: userRecord.displayName || 'N/A',
        createdAt: userRecord.metadata.creationTime,
        lastSignIn: userRecord.metadata.lastSignInTime,
      });
    });
    console.log('---------------------');
  } catch (error) {
    console.error('Error fetching users:', error);
  } finally {
    process.exit();
  }
}

fetchUsers();
