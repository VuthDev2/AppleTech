"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const dotenv_1 = __importDefault(require("dotenv"));
const auth_1 = __importDefault(require("./auth"));
const users_1 = __importDefault(require("./users"));
const verifyToken_1 = require("./middleware/verifyToken");
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 4000;
// Global middlewares
app.use((0, helmet_1.default)());
app.use((0, cors_1.default)());
app.use(express_1.default.json());
app.use((0, express_rate_limit_1.default)({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
}));
// Routes
app.use('/auth', auth_1.default);
app.use('/users', users_1.default);
// Health check
app.get('/health', (_req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
// Example protected route
app.get('/protected', verifyToken_1.verifyToken, (_req, res) => {
    res.json({ message: 'You have accessed a protected endpoint!' });
});
app.listen(PORT, () => {
    console.log(`Auth backend listening on http://localhost:${PORT}`);
});
//# sourceMappingURL=index.js.map