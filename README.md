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

1. Copy `.env` if needed and update `DATABASE_URL` and `JWT_SECRET`.

2. Install dependencies and generate Prisma client:

```powershell
cd backend
npm install
npx prisma generate
```

3. Run migrations and seed (local dev):

```powershell
npx prisma migrate dev --name init
npx ts-node prisma/seed.ts
```

4. Run dev server:

```powershell
npm run dev
```

Endpoints:

- POST `/auth/register` - register user
- POST `/auth/login` - login
- GET `/auth/me` - get current user

- Ads endpoints (auth required):

  - GET `/ads` - list ads (supports `search` and `status` query)
  - GET `/ads/:id` - view an ad
  - POST `/ads` - create
  - PUT `/ads/:id` - update
  - DELETE `/ads/:id` - delete

- Public deep-link endpoints:

  - `/.well-known/assetlinks.json` (Android)
  - `/.well-known/apple-app-site-association` (iOS)

- Admin endpoints (admin JWT required):
  - POST `/admin/deeplink` - create deep link asset
  - PUT `/admin/deeplink/:id` - update
  - GET `/admin/deeplink` - list

## Frontend setup

```powershell
cd frontend
npm install
npm run dev
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

## Notes

- The deep-link endpoints are dynamically served from database content and cached for performance. Admin updates invalidate the cache.
- The example uses JWT for auth stored in localStorage for the frontend; replace with a more robust session approach for production.

## Roadmap

- Add tests, CI, and better RBAC
- Add pagination and audit logs
- Add refresh token / logout flows

Enjoy building on Zplit!
