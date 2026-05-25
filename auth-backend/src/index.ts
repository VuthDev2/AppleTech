import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import authRouter from './auth';
import usersRouter from './users';
import { verifyToken } from './middleware/verifyToken';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

// Global middlewares
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(
  rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
  })
);

// Routes
app.use('/auth', authRouter);
app.use('/users', usersRouter);

// Health check
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Example protected route
app.get('/protected', verifyToken, (_req, res) => {
  res.json({ message: 'You have accessed a protected endpoint!' });
});

app.listen(PORT, () => {
  console.log(`Auth backend listening on http://localhost:${PORT}`);
});
