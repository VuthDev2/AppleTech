"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.db = exports.auth = void 0;
const firebase_admin_1 = __importDefault(require("firebase-admin"));
const dotenv_1 = __importDefault(require("dotenv"));
const fs_1 = require("fs");
const path_1 = __importDefault(require("path"));
dotenv_1.default.config();
// Initialize Firebase Admin SDK using service account
const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH || path_1.default.join(__dirname, '..', 'serviceAccountKey.json');
const serviceAccount = JSON.parse((0, fs_1.readFileSync)(serviceAccountPath, 'utf8'));
firebase_admin_1.default.initializeApp({
    credential: firebase_admin_1.default.credential.cert(serviceAccount),
});
exports.auth = firebase_admin_1.default.auth();
exports.db = firebase_admin_1.default.firestore();
//# sourceMappingURL=firebase.js.map