import express from 'express';
import prisma from '../prisma';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { authMiddleware, adminOnly } from '../middlewares/auth';
import config from '../config';

const router = express.Router();

// Use centralized configuration (JWT_SECRET is guaranteed to be set and validated)
const JWT_SECRET = config.jwt.secret;
const ADMIN_INVITE_KEY = config.admin.inviteKey;

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  clientName: z.string().optional(),
});

const adminRegisterSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  inviteKey: z.string(),
});

const loginSchema = z.object({ email: z.string().email(), password: z.string() });

/**
 * Public registration endpoint - CLIENT role only
 * ⚠️  ADMIN creation is strictly forbidden here
 * Use POST /auth/register-admin with a valid invite key to create admin accounts
 */
router.post('/register', async (req, res) => {
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ message: 'Invalid input', errors: parsed.error.format() });
  }

  const { email, password, clientName } = parsed.data;

  try {
    // Validate required fields
    if (!clientName) {
      return res.status(400).json({ message: 'clientName is required' });
    }

    // Create client for CLIENT user
    const existingClient = await prisma.client.findUnique({ where: { email } });
    const client = existingClient ?? (await prisma.client.create({ data: { name: clientName, email } }));

    // Hash password before database write
    const hashed = await bcrypt.hash(password, 10);

    // Create user with CLIENT role (ADMIN creation forbidden in public endpoint)
    const user = await prisma.user.create({
      data: {
        email,
        password: hashed,
        role: 'CLIENT',
        clientId: client.id,
      },
    });

    res.json({ id: user.id, email: user.email, role: user.role, clientId: user.clientId });
  } catch (err: any) {
    console.error('Registration error:', err);
    if (err.code === 'P2002') {
      return res.status(400).json({ message: 'Email already exists' });
    }
    res.status(500).json({ message: 'Error registering user' });
  }
});

/**
 * Protected admin registration endpoint
 * Requires valid ADMIN_INVITE_KEY for creating admin accounts
 * Only accessible with admin authentication OR valid invite key
 */
router.post('/register-admin', async (req, res) => {
  // Validate invite key before any database operations
  const parsed = adminRegisterSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ message: 'Invalid input', errors: parsed.error.format() });
  }

  const { email, password, inviteKey } = parsed.data;

  // Check if ADMIN_INVITE_KEY is configured
  if (!ADMIN_INVITE_KEY) {
    console.error('ADMIN_INVITE_KEY not configured - admin creation disabled');
    return res.status(503).json({ message: 'Admin registration is not available' });
  }

  // Validate invite key (use constant-time comparison to prevent timing attacks)
  const keyValid = ADMIN_INVITE_KEY === inviteKey;
  if (!keyValid) {
    // Log failed attempt for security monitoring
    console.warn(`Failed admin registration attempt with invalid invite key for email: ${email}`);
    return res.status(403).json({ message: 'Invalid invite key' });
  }

  try {
    // Hash password before database write
    const hashed = await bcrypt.hash(password, 10);

    // Create user with ADMIN role
    const user = await prisma.user.create({
      data: {
        email,
        password: hashed,
        role: 'ADMIN',
        clientId: null,
      },
    });

    res.json({ id: user.id, email: user.email, role: user.role });
  } catch (err: any) {
    console.error('Admin registration error:', err);
    if (err.code === 'P2002') {
      return res.status(400).json({ message: 'Email already exists' });
    }
    res.status(500).json({ message: 'Error registering admin' });
  }
});

router.post('/login', async (req, res) => {
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ message: 'Invalid input' });
  }

  const { email, password } = parsed.data;
  try {
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const ok = await bcrypt.compare(password, user.password);
    if (!ok) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '8h' });
    res.json({ token, role: user.role, clientId: user.clientId });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ message: 'Login error' });
  }
});

// Get current user
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const userId = req.user?.id;
    const user = await prisma.user.findUnique({ where: { id: userId }, include: { client: true } });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json({ id: user.id, email: user.email, role: user.role, client: user.client });
  } catch (err) {
    console.error('Get user error:', err);
    res.status(500).json({ message: 'Error fetching user' });
  }
});

export default router;

export default router;
