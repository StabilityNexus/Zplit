import express from 'express';
import prisma from '../prisma';
import cache from '../services/cache';

// export the cache so admins can invalidate it when updating entries
// export the cache so admins can invalidate it when updating entries
// export const cache = new NodeCache({ stdTTL: 60 }); // cache 60s

const router = express.Router();

// Public endpoints for deep linking
router.get('/assetlinks.json', async (req, res) => {
  // Android assetlinks
  const cacheKey = 'ANDROID_ASSETLINKS';
  const cached = cache.get(cacheKey);
  if (cached) {
    res.set('Content-Type', 'application/json');
    return res.json(cached);
  }

  const record = await prisma.deepLinkAsset.findFirst({ where: { platform: 'ANDROID' }, orderBy: { updatedAt: 'desc' } });
  if (!record) return res.status(404).json({ message: 'Not configured' });

  cache.set(cacheKey, record.content);
  res.set('Content-Type', 'application/json');
  res.json(record.content);
});

router.get('/apple-app-site-association', async (req, res) => {
  const cacheKey = 'IOS_AASA';
  const cached = cache.get(cacheKey);
  if (cached) {
    res.set('Content-Type', 'application/json');
    return res.json(cached);
  }
  const record = await prisma.deepLinkAsset.findFirst({ where: { platform: 'IOS' }, orderBy: { updatedAt: 'desc' } });
  if (!record) return res.status(404).json({ message: 'Not configured' });
  cache.set(cacheKey, record.content);
  res.set('Content-Type', 'application/json');
  res.json(record.content);
});

export default router;
