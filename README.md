# Zplit

Zplit is an example full-stack application for managing advertisements and hosting deep-linking assets.

Folders:

- `backend` - Node/Express + Prisma backend
- `frontend` - React + Vite frontend

## Requirements

- Node.js 18+
- PostgreSQL
- pnpm / npm / yarn

## Backend setup

1. Create `.env` from the example file and update configuration:

```powershell
cd backend
cp .env.example .env
```

   Then edit `.env` with your actual values:
   - `DATABASE_URL` - **REQUIRED** - PostgreSQL connection string
     - Example: `postgresql://postgres:postgres@localhost:5432/zplit_db?schema=public`
     - Application fails fast on startup if not set
   - `JWT_SECRET` - **REQUIRED** - Secure random string for token signing and validation
     - Generate with: `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`
     - Application fails fast on startup if not set
     - Must be the same value across all server instances (for distributed deployments)
     - Centralized configuration validation in `src/config.ts` ensures this is set before any routes load
   - `PORT` - Server port (default: 4000)
   - `NODE_ENV` - Environment (development/production, default: development)
   - `ADMIN_INVITE_KEY` - Optional: Secure invite key for creating admin accounts via API

   **Security Note:** Never commit `.env` to version control. Use `.env.example` as a template for developers.
   
   **Configuration Validation:** The application uses a centralized configuration module (`src/config.ts`) that validates all required environment variables at startup. If any critical configuration is missing, the app will fail immediately with a clear error message rather than starting with insecure defaults.

2. Install dependencies and generate Prisma client:

```powershell
npm install
npx prisma generate
```

3. Run migrations and seed (local dev):

```powershell
npx prisma migrate dev --name init
npx ts-node prisma/seed.ts
```

   **Seed Data Security:**
   - The seed file creates default dev credentials (admin and client users)
   - For development: Random secure passwords are auto-generated if not provided
   - To use custom passwords, set environment variables before seeding:
     ```powershell
     $env:SEED_ADMIN_PASSWORD="your-admin-password"
     $env:SEED_CLIENT_PASSWORD="your-client-password"
     npx ts-node prisma/seed.ts
     ```
   - **IMPORTANT:** These credentials are for LOCAL DEVELOPMENT ONLY
   - Never use seed credentials in production
   - Production environments require explicit password environment variables

4. Run dev server:

```powershell
npm run dev
```

Endpoints:

**Authentication:**
- POST `/auth/register` - Register CLIENT user (requires `email`, `password`, `clientName`)
- POST `/auth/register-admin` - Register ADMIN user (requires `email`, `password`, `inviteKey`; set `ADMIN_INVITE_KEY` env var to enable)
- POST `/auth/login` - Login (returns JWT token)
- GET `/auth/me` - Get current authenticated user (requires valid JWT)

**Ads (auth required):**
- GET `/ads` - list ads (supports `search` and `status` query)
- GET `/ads/:id` - view an ad
- POST `/ads` - create
- PUT `/ads/:id` - update
- DELETE `/ads/:id` - delete

**Public deep-link endpoints:**
- `/.well-known/assetlinks.json` (Android)
- `/.well-known/apple-app-site-association` (iOS)

**Admin endpoints (admin JWT required):**
- POST `/admin/deeplink` - create deep link asset
- PUT `/admin/deeplink/:id` - update
- GET `/admin/deeplink` - list

## Frontend setup

```powershell
cd frontend
npm install
npm run dev
```

### Frontend Production Deployment (Nginx)

The frontend is deployed as a static SPA using nginx. The configuration includes:
- **SPA Routing**: `try_files $uri $uri/ /index.html` - All routes fallback to index.html for client-side routing
- **Static Asset Caching**: 1-year cache for .js, .css, image files
- **Security Headers**: X-Frame-Options, X-Content-Type-Options, X-XSS-Protection
- **Compression**: Gzip compression for assets over 1KB
- **index.html Cache**: Short-lived cache (must-revalidate) to always get latest version

The `nginx.conf` is automatically copied during Docker build. For local nginx testing:

```bash
# Build frontend
cd frontend && npm run build

# Serve with nginx (requires nginx installed)
nginx -c /absolute/path/to/frontend/nginx.conf -p /absolute/path/to/frontend/dist
```

## UI Theme and Design Guidelines (Minimal Theme)

This repository includes a first theme called "Minimal, Clean, Sleek". It follows the following rules:

- Theme-based UI with layout-level changes supported via classes: `data-theme` (light/dark) and `data-orientation` (portrait/landscape).
- Prioritizes UX: intuitive and simple forms, clear calls to action, minimal distracting visual elements.
- Screens implemented: Onboarding, Account Setup, Groups, Invite Users, Add Expenses, Graphs.

To preview the different modes (light/dark and orientation):

```bash
# start the dev server
cd frontend
npm install
npm run dev
```

Open the app and toggle theme and layout from the top navigation bar to switch between the design variants. Each page includes a responsive layout for portrait and landscape sizes.

Design deadline: 1st December 2025

Design variants to cover for each page: Portrait Light, Portrait Dark, Landscape Light, Landscape Dark.

Where files live:

- Onboarding: `frontend/src/pages/Onboarding.tsx`
- Account Setup: `frontend/src/pages/AccountSetup.tsx`
- Groups: `frontend/src/pages/Groups.tsx`
- Invite Users: `frontend/src/pages/InviteUsers.tsx`
- Add Expenses: `frontend/src/pages/AddExpenses.tsx`
- Graphs: `frontend/src/pages/Graphs.tsx`

To propose a design submission, open a PR adding a theme folder (e.g. `frontend/themes/my-theme`) and include scss or css, and a ThemeProvider variant that sets `data-theme` and layout changes accordingly.

Set `VITE_API_URL` via `.env` or environment variables when running Vite.

## Security Considerations

### Backend

**Configuration Management:**
- Centralized configuration validation in `src/config.ts`
- All required environment variables (`JWT_SECRET`, `DATABASE_URL`) validated at application startup
- Application fails fast with clear error messages if critical config is missing
- No hardcoded defaults or fallback values for secrets
- All modules import from centralized config module instead of directly accessing `process.env`
- Single source of truth for configuration across the application

**Authentication & Authorization:**
- **JWT_SECRET**: Required environment variable - application will not start without it. Must be a cryptographically secure random string (minimum 32 bytes/256 bits recommended).
- **Admin Registration Protection**: 
  - Public `/auth/register` endpoint only creates CLIENT users
  - Admin accounts can ONLY be created via:
    - Database seed with environment variable credentials
    - Protected `/auth/register-admin` endpoint with valid `ADMIN_INVITE_KEY`
  - `ADMIN_INVITE_KEY` must be a secure random string (generate with: `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`)
  - Failed admin registration attempts are logged for security monitoring
  - `ADMIN_INVITE_KEY` is optional; if not set, admin registration is disabled (seed-only)

**Token Validation**: 
  - Authorization header strictly validated as `Bearer <token>` format
  - JWT signature and expiration verified on every request
  - Generic error messages returned to clients; detailed errors logged internally
  - Missing or invalid tokens return 401 (authentication failure)
  - Server errors return 500 to distinguish from auth failures

**Password Storage**: 
  - All passwords hashed with bcrypt before database storage
  - Password validation only via bcrypt.compare (never store/expose plaintext)

**Seed Data**: 
  - Development seed creates test credentials. Use environment variables to customize, never hardcode in code.

### Frontend
- Tokens stored in localStorage (consider more secure storage for production)
- Tokens sent as Bearer tokens in Authorization header
- Recommend replacing JWT + localStorage with session cookies for production deployments

### Environment Variables
- Never commit `.env` files with actual secrets
- Always use `.env.example` as a template
- For CI/CD, use your platform's secrets management (GitHub Secrets, AWS Secrets Manager, etc.)
- Rotate JWT_SECRET if ever exposed
- Rotate ADMIN_INVITE_KEY after each use or periodically in production

## Notes

- The deep-link endpoints are dynamically served from database content and cached for performance. Admin updates invalidate the cache.
- The example uses JWT for auth stored in localStorage for the frontend; replace with a more robust session approach for production.

## Roadmap

- Add tests, CI, and better RBAC
- Add pagination and audit logs
- Add refresh token / logout flows

Enjoy building on Zplit!
