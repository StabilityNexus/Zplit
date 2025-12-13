import express from 'express';
import prisma from '../prisma';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { authMiddleware } from '../middlewares/auth';

const router = express.Router();
const JWT_SECRET = process.env.JWT_SECRET || 'changeme';

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  role: z.enum(['ADMIN', 'CLIENT']),
  clientName: z.string().optional(),
});

const loginSchema = z.object({ email: z.string().email(), password: z.string() });

router.post('/register', async (req, res) => {
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ message: 'Invalid input', errors: parsed.error.format() });

  const { email, password, role, clientName } = parsed.data;
  try {
    let clientId: number | null = null;
    // Create a client for role CLIENT if it doesn't exist
    if (role === 'CLIENT') {
      if (!clientName) return res.status(400).json({ message: 'clientName required for CLIENT role' });
      const existing = await prisma.client.findUnique({ where: { email } });
      const client = existing ?? (await prisma.client.create({ data: { name: clientName, email } }));
      clientId = client.id;
    }

    const hashed = await bcrypt.hash(password, 10);
    const user = await prisma.user.create({
      data: {
        email,
        password: hashed,
        role,
        clientId,
      },
    });
    res.json({ id: user.id, email: user.email, role: user.role, clientId: user.clientId });
  } catch (err: any) {
    console.error(err);
    if (err.code === 'P2002') return res.status(400).json({ message: 'Email already exists' });
    res.status(500).json({ message: 'Error registering user' });
  }
});

router.post('/login', async (req, res) => {
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ message: 'Invalid input' });
  const { email, password } = parsed.data;
  try {
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) return res.status(401).json({ message: 'Invalid credentials' });
    const ok = await bcrypt.compare(password, user.password);
    if (!ok) return res.status(401).json({ message: 'Invalid credentials' });
    const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '8h' });
    res.json({ token, role: user.role, clientId: user.clientId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Login error' });
  }
});

// Get current user
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const userId = req.user?.id;
    const user = await prisma.user.findUnique({ where: { id: userId }, include: { client: true } });
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json({ id: user.id, email: user.email, role: user.role, client: user.client });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error fetching user' });
  }
});

export default router;
