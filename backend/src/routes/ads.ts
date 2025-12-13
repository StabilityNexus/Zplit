import express from 'express';
import prisma from '../prisma';
import { authMiddleware } from '../middlewares/auth';

const router = express.Router();

// All routes require auth
router.use(authMiddleware);

// GET /ads - list ads (admins see all, clients only their own)
router.get('/', async (req, res) => {
  const role = req.user.role;
  const clientId = req.user.clientId;
  const { status, search } = req.query;
  const where: any = {};
  if (role === 'CLIENT') where.clientId = clientId;
  if (status) where.status = { equals: (status as string).toUpperCase() };
  if (search) {
    where.OR = [
      { ad_name: { contains: search as string, mode: 'insensitive' } },
      { target_url: { contains: search as string, mode: 'insensitive' } },
    ];
  }
  const ads = await prisma.advertisement.findMany({
    where,
    orderBy: { createdAt: 'desc' },
  });
  res.json(ads);
});

// GET /ads/:id
router.get('/:id', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const ad = await prisma.advertisement.findUnique({ where: { id } });
  if (!ad) return res.status(404).json({ message: 'Ad not found' });
  // Client users can only access their own
  if (req.user.role === 'CLIENT' && ad.clientId !== req.user.clientId) return res.status(403).json({ message: 'Forbidden' });
  res.json(ad);
});

// POST /ads
router.post('/', async (req, res) => {
  const { ad_name, target_url, start_date, end_date, status } = req.body;
  const role = req.user.role;
  const clientId = req.user.clientId;
  try {
    const data: any = { ad_name, target_url, start_date: new Date(start_date), end_date: new Date(end_date), status };
    if (role === 'ADMIN' && req.body.clientId) {
      data.clientId = req.body.clientId;
    } else if (role === 'CLIENT') {
      data.clientId = clientId;
    } else {
      return res.status(400).json({ message: 'Client ID required for admin ad creation' });
    }
    const ad = await prisma.advertisement.create({ data });
    res.json(ad);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error creating ad' });
  }
});

// PUT /ads/:id
router.put('/:id', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const ad = await prisma.advertisement.findUnique({ where: { id } });
  if (!ad) return res.status(404).json({ message: 'Ad not found' });
  if (req.user.role === 'CLIENT' && ad.clientId !== req.user.clientId) return res.status(403).json({ message: 'Forbidden' });
  const { ad_name, target_url, start_date, end_date, status } = req.body;
  try {
    const updated = await prisma.advertisement.update({
      where: { id },
      data: { ad_name, target_url, start_date: start_date ? new Date(start_date) : undefined, end_date: end_date ? new Date(end_date) : undefined, status },
    });
    res.json(updated);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error updating ad' });
  }
});

// DELETE /ads/:id
router.delete('/:id', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const ad = await prisma.advertisement.findUnique({ where: { id } });
  if (!ad) return res.status(404).json({ message: 'Ad not found' });
  if (req.user.role === 'CLIENT' && ad.clientId !== req.user.clientId) return res.status(403).json({ message: 'Forbidden' });
  await prisma.advertisement.delete({ where: { id } });
  res.json({ ok: true });
});

export default router;
