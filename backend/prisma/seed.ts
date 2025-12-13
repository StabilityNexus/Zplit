import prisma from '../src/prisma';
import bcrypt from 'bcrypt';
import crypto from 'crypto';

/**
 * DEVELOPMENT-ONLY SEED FILE
 * 
 * This file creates seed data with default admin and client credentials.
 * 
 * ⚠️  SECURITY WARNING ⚠️
 * - These credentials are for DEVELOPMENT/LOCAL TESTING ONLY
 * - NEVER use these credentials in production environments
 * - NEVER commit actual production credentials to version control
 * - Always use environment variables or secrets management in production
 * 
 * Environment Variables (Optional):
 * - SEED_ADMIN_EMAIL: Admin user email (default: admin@example.com)
 * - SEED_ADMIN_PASSWORD: Admin user password (generates secure random if not provided)
 * - SEED_CLIENT_EMAIL: Client user email (default: clientuser@example.com)
 * - SEED_CLIENT_PASSWORD: Client user password (generates secure random if not provided)
 * 
 * In production (NODE_ENV=production), missing passwords will cause the seed to fail.
 */

function generateSecurePassword(length = 16): string {
  return crypto.randomBytes(length).toString('hex');
}

function getPasswordFromEnv(envVar: string, defaultEmail: string, isProduction: boolean): string {
  const password = process.env[envVar];
  
  if (!password) {
    if (isProduction) {
      throw new Error(
        `Missing required environment variable: ${envVar}\n` +
        `Production seeds require explicit passwords. ` +
        `Set ${envVar} in your environment and try again.`
      );
    }
    // Development: generate a secure random password
    const generated = generateSecurePassword();
    console.log(`ℹ️  Generated random password for ${defaultEmail}: ${generated}`);
    return generated;
  }
  
  return password;
}

async function main() {
  const isProduction = process.env.NODE_ENV === 'production';
  
  // Admin credentials
  const adminEmail = process.env.SEED_ADMIN_EMAIL || 'admin@example.com';
  const adminPassword = getPasswordFromEnv('SEED_ADMIN_PASSWORD', adminEmail, isProduction);
  const adminPasswordHashed = await bcrypt.hash(adminPassword, 10);
  
  // Client credentials
  const clientEmail = process.env.SEED_CLIENT_EMAIL || 'client@example.com';
  const clientUserEmail = process.env.SEED_CLIENT_USER_EMAIL || 'clientuser@example.com';
  const clientPassword = getPasswordFromEnv('SEED_CLIENT_PASSWORD', clientUserEmail, isProduction);
  const clientPasswordHashed = await bcrypt.hash(clientPassword, 10);
  
  // Create clients
  const clientA = await prisma.client.upsert({ where: { email: clientEmail }, update: {}, create: { name: 'Client A', email: clientEmail } });

  // Create admin
  await prisma.user.upsert({ where: { email: adminEmail }, update: {}, create: { email: adminEmail, password: adminPasswordHashed, role: 'ADMIN' } });

  // Create client user
  await prisma.user.upsert({ where: { email: clientUserEmail }, update: {}, create: { email: clientUserEmail, password: clientPasswordHashed, role: 'CLIENT', clientId: clientA.id } });

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
