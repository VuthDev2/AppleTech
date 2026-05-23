import { auth } from '../src/firebase';

async function main() {
  await auth.listUsers(1);
  console.log('Firebase Admin credentials are valid.');
}

main().catch((error) => {
  console.error('Firebase Admin credentials failed.');
  console.error(
    'Generate a new key: Firebase Console → Project settings → Service accounts → Generate new private key.',
  );
  console.error('Save it as auth-backend/google-service.json and run npm run seed.');
  console.error(error.message ?? error);
  process.exitCode = 1;
});
