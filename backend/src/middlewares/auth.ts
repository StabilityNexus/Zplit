import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import prisma from '../prisma';
import config from '../config';

declare global {
  namespace Express {
    interface Request {
      user?: any;
    }
  }
}

// Use centralized configuration (JWT_SECRET is guaranteed to be set and validated)
const JWT_SECRET = config.jwt.secret;

/**
 * Authentication middleware
 * - Validates Authorization header format ("Bearer <token>")
 * - Verifies JWT signature and expiration
 * - Loads user from database
 * - Sets req.user with user id, role, and clientId
 * - Returns 401 for auth failures (invalid/expired token, missing user)
 * - Returns 500 for server misconfigurations
 */
export async function authMiddleware(req: Request, res: Response, next: NextFunction) {
  try {
    // Validate Authorization header exists
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      return res.status(401).json({ message: 'Invalid or expired token' });
    }

    // Strictly validate Bearer token format
    const parts = authHeader.split(' ');
    if (parts.length !== 2 || parts[0] !== 'Bearer' || !parts[1]) {
      return res.status(401).json({ message: 'Invalid or expired token' });
    }

    const token = parts[1];

    // Verify JWT signature and expiration
    let payload: any;
    try {
      payload = jwt.verify(token, JWT_SECRET);
    } catch (verifyErr: any) {
      // Log detailed error internally, respond generically to client
      console.error('JWT verification failed:', verifyErr.message);
      return res.status(401).json({ message: 'Invalid or expired token' });
    }

    // Validate payload contains userId
    if (!payload || !payload.userId) {
      console.error('Invalid JWT payload: missing userId');
      return res.status(401).json({ message: 'Invalid or expired token' });
    }

    // Load user from database
    const user = await prisma.user.findUnique({ where: { id: payload.userId } });
    if (!user) {
      console.error(`User not found for userId: ${payload.userId}`);
      return res.status(401).json({ message: 'Invalid or expired token' });
    }

    // Set user on request (only after all validations pass)
    req.user = { id: user.id, role: user.role, clientId: user.clientId };
    next();
  } catch (err: any) {
    // Catch-all for unexpected server errors
    console.error('Unexpected auth middleware error:', err);
    return res.status(500).json({ message: 'Server error' });
  }
}

export function adminOnly(req: Request, res: Response, next: NextFunction) {
  if (req.user?.role !== 'ADMIN') return res.status(403).json({ message: 'Admin access required' });
  next();
}

export function clientOrAdmin(req: Request, res: Response, next: NextFunction) {
  const role = req.user?.role;
  if (role === 'ADMIN') return next();
  if (role === 'CLIENT') return next();
  return res.status(403).json({ message: 'Unauthorized' });
}
