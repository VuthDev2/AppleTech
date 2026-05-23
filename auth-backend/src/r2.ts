import { PutObjectCommand, S3Client } from '@aws-sdk/client-s3';

function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing environment variable: ${name}`);
  }
  return value;
}

export function isR2Configured(): boolean {
  return Boolean(
    process.env.R2_ACCOUNT_ID &&
      process.env.R2_ACCESS_KEY_ID &&
      process.env.R2_SECRET_ACCESS_KEY &&
      process.env.R2_BUCKET_NAME &&
      process.env.R2_PUBLIC_BASE_URL,
  );
}

function createR2Client(): S3Client {
  const accountId = requireEnv('R2_ACCOUNT_ID');
  return new S3Client({
    region: 'auto',
    endpoint: `https://${accountId}.r2.cloudflarestorage.com`,
    credentials: {
      accessKeyId: requireEnv('R2_ACCESS_KEY_ID'),
      secretAccessKey: requireEnv('R2_SECRET_ACCESS_KEY'),
    },
  });
}

export async function uploadProfilePhotoToR2(
  uid: string,
  body: Buffer,
  contentType: string,
): Promise<string> {
  const bucket = requireEnv('R2_BUCKET_NAME');
  const publicBase = requireEnv('R2_PUBLIC_BASE_URL').replace(/\/$/, '');
  const key = `users/${uid}/profile/avatar.jpg`;
  const client = createR2Client();

  await client.send(
    new PutObjectCommand({
      Bucket: bucket,
      Key: key,
      Body: body,
      ContentType: contentType,
    }),
  );

  return `${publicBase}/${key}`;
}
