import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import prisma from '../prisma';

declare global {
  namespace Express {
    interface Request {
      user?: any;
    }
  }
}

const JWT_SECRET = process.env.JWT_SECRET || 'changeme';

export async function authMiddleware(req: Request, res: Response, next: NextFunction) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) return res.status(401).json({ message: 'Missing token' });

    const token = authHeader.split(' ')[1];
    const payload: any = jwt.verify(token, JWT_SECRET);
    if (!payload) return res.status(401).json({ message: 'Invalid token' });

    const user = await prisma.user.findUnique({ where: { id: payload.userId } });
    if (!user) return res.status(401).json({ message: 'User not found' });

    req.user = { id: user.id, role: user.role, clientId: user.clientId };
    next();
  } catch (err: any) {
    console.error('auth error', err.message);
    return res.status(401).json({ message: 'Auth error: ' + err.message });
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
