/**
 * Centralized Configuration Module
 * 
 * This module validates and exports all required environment variables
 * at application startup. If any critical config is missing, the app fails fast.
 * 
 * All modules should import from this file instead of directly accessing process.env
 * for required configuration values.
 */

// Required environment variables
const JWT_SECRET = process.env.JWT_SECRET;
const DATABASE_URL = process.env.DATABASE_URL;
const NODE_ENV = process.env.NODE_ENV || 'development';
const PORT = process.env.PORT || 4000;

// Optional environment variables
const ADMIN_INVITE_KEY = process.env.ADMIN_INVITE_KEY;

/**
 * Validate critical configuration at startup
 * Throws error if required environment variables are not set
 */
function validateConfig(): void {
  const errors: string[] = [];

  if (!JWT_SECRET) {
    errors.push('JWT_SECRET - Required for token signing and validation');
  }

  if (!DATABASE_URL) {
    errors.push('DATABASE_URL - Required for database connection');
  }

  if (errors.length > 0) {
    console.error('❌ CRITICAL: Missing required environment variables:');
    errors.forEach(err => console.error(`  - ${err}`));
    console.error('\nPlease set these variables in your .env file and restart the application.');
    process.exit(1);
  }

  // Log configuration on startup (excluding sensitive values)
  console.log('✅ Configuration loaded successfully');
  if (NODE_ENV === 'development') {
    console.log(`   Environment: ${NODE_ENV}`);
    console.log(`   Port: ${PORT}`);
  }
}

// Validate configuration on module load
validateConfig();

export const config = {
  jwt: {
    secret: JWT_SECRET as string, // Guaranteed to be set after validation
    expiresIn: '8h',
  },
  database: {
    url: DATABASE_URL as string, // Guaranteed to be set after validation
  },
  admin: {
    inviteKey: ADMIN_INVITE_KEY || null, // Optional
  },
  server: {
    port: Number(PORT),
    nodeEnv: NODE_ENV,
    isDevelopment: NODE_ENV === 'development',
    isProduction: NODE_ENV === 'production',
  },
};

export default config;
