import { Request, Response, NextFunction } from 'express';
import { auth } from '../firebase';

// Extend Express Request type to include verified uid
declare global {
  namespace Express {
    interface Request {
      uid?: string;
    }
  }
}

/**
 * Middleware that verifies a Firebase ID token from the Authorization header.
 * Sets req.uid to the verified UID on success.
 */
export async function verifyToken(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    res.status(401).json({ error: 'Missing or malformed Authorization header' });
    return;
  }

  const idToken = authHeader.split(' ')[1];
  try {
    const decoded = await auth.verifyIdToken(idToken);
    req.uid = decoded.uid;
    next();
  } catch (err: any) {
    console.error('Token verification failed:', err.message);
    res.status(401).json({ error: 'Unauthorized: invalid or expired token' });
  }
}
