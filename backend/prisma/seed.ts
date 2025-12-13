import prisma from '../src/prisma';
import bcrypt from 'bcrypt';

async function main() {
  // Create clients
  const clientA = await prisma.client.upsert({ where: { email: 'client@example.com' }, update: {}, create: { name: 'Client A', email: 'client@example.com' } });

  // Create admin
  const adminPw = await bcrypt.hash('adminpass', 10);
  await prisma.user.upsert({ where: { email: 'admin@example.com' }, update: {}, create: { email: 'admin@example.com', password: adminPw, role: 'ADMIN' } });

  // Create client user
  const clientPw = await bcrypt.hash('clientpass', 10);
  await prisma.user.upsert({ where: { email: 'clientuser@example.com' }, update: {}, create: { email: 'clientuser@example.com', password: clientPw, role: 'CLIENT', clientId: clientA.id } });

  // Ads
  await prisma.advertisement.createMany({ data: [
    { ad_name: 'Holiday Sale', target_url: 'https://example.com/holiday', start_date: new Date(), end_date: new Date(new Date().getTime() + 1000*60*60*24*30), status: 'ACTIVE', clientId: clientA.id },
    { ad_name: 'New Product', target_url: 'https://example.com/new', start_date: new Date(), end_date: new Date(new Date().getTime() + 1000*60*60*24*15), status: 'PAUSED', clientId: clientA.id }
  ]});

  // Deep link assets
  await prisma.deepLinkAsset.upsert({ where: { id: 1 }, update: { content: { apps: [] } }, create: { platform: 'ANDROID', content: { statements: [] } } as any }).catch(()=>{});
  await prisma.deepLinkAsset.upsert({ where: { id: 2 }, update: { content: { applinks: {} } }, create: { platform: 'IOS', content: { applinks: {} } } as any }).catch(()=>{});

  console.log('Seed done');
}

main().catch(e => { console.error(e); process.exit(1); }).finally(async () => { await prisma.$disconnect(); });
