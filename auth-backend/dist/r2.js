"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isR2Configured = isR2Configured;
exports.uploadProfilePhotoToR2 = uploadProfilePhotoToR2;
const client_s3_1 = require("@aws-sdk/client-s3");
function requireEnv(name) {
    const value = process.env[name];
    if (!value) {
        throw new Error(`Missing environment variable: ${name}`);
    }
    return value;
}
function isR2Configured() {
    return Boolean(process.env.R2_ACCOUNT_ID &&
        process.env.R2_ACCESS_KEY_ID &&
        process.env.R2_SECRET_ACCESS_KEY &&
        process.env.R2_BUCKET_NAME &&
        process.env.R2_PUBLIC_BASE_URL);
}
function createR2Client() {
    const accountId = requireEnv('R2_ACCOUNT_ID');
    return new client_s3_1.S3Client({
        region: 'auto',
        endpoint: `https://${accountId}.r2.cloudflarestorage.com`,
        credentials: {
            accessKeyId: requireEnv('R2_ACCESS_KEY_ID'),
            secretAccessKey: requireEnv('R2_SECRET_ACCESS_KEY'),
        },
    });
}
async function uploadProfilePhotoToR2(uid, body, contentType) {
    const bucket = requireEnv('R2_BUCKET_NAME');
    const publicBase = requireEnv('R2_PUBLIC_BASE_URL').replace(/\/$/, '');
    const key = `users/${uid}/profile/avatar.jpg`;
    const client = createR2Client();
    await client.send(new client_s3_1.PutObjectCommand({
        Bucket: bucket,
        Key: key,
        Body: body,
        ContentType: contentType,
    }));
    return `${publicBase}/${key}`;
}
//# sourceMappingURL=r2.js.map