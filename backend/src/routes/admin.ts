import express from 'express';
import prisma from '../prisma';
import { authMiddleware, adminOnly } from '../middlewares/auth';
import cache from '../services/cache';

const router = express.Router();

router.use(authMiddleware);
router.use(adminOnly);

// Deep link management
router.post('/deeplink', async (req, res) => {
  const { platform, content } = req.body; // platform should be 'ANDROID' or 'IOS', content is JSON
  if (!platform || !content) return res.status(400).json({ message: 'platform+content required' });
  try {
    const record = await prisma.deepLinkAsset.create({ data: { platform, content } });
    // Invalidate caches for the platform
    if (platform === 'ANDROID') cache.del('ANDROID_ASSETLINKS');
    if (platform === 'IOS') cache.del('IOS_AASA');
    res.json(record);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error creating deep link asset' });
  }
});

router.put('/deeplink/:id', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const { content } = req.body;
  try {
    const updated = await prisma.deepLinkAsset.update({ where: { id }, data: { content } });
    // invalidate caches by detecting platform
    if (updated.platform === 'ANDROID') cache.del('ANDROID_ASSETLINKS');
    if (updated.platform === 'IOS') cache.del('IOS_AASA');
    res.json(updated);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error updating deep link asset' });
  }
});

router.get('/deeplink', async (req, res) => {
  const list = await prisma.deepLinkAsset.findMany({ orderBy: { updatedAt: 'desc' } });
  res.json(list);
});

export default router;
