# KwanPay

KwanPay's repository contains:

- A Next.js 16 web app for product marketing, demo requests, early-access signups, the public roadmap, and internal signup administration.
- A Flutter companion app in `kwanpay_app/` for the wallet experience.

## Web stack

Next.js App Router, React 19, Tailwind CSS 4, Framer Motion, Supabase, Zod, and Vitest.

## Local setup

Requirements:

- Node.js 20 or newer
- npm
- A Supabase project

Install dependencies and create your local environment file:

```bash
npm ci
copy .env.example .env.local
```

Fill in every value in `.env.local`, then run:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Environment variables

- `NEXT_PUBLIC_SUPABASE_URL`: Supabase project URL.
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`: Public anon key used by browser-safe integrations.
- `SUPABASE_SERVICE_ROLE_KEY`: Server-only key used by lead ingestion and admin operations. Never expose it to the browser.
- `ADMIN_PASSWORD`: One-time bootstrap password for the first owner account. Remove it after the first successful owner login.
- `ADMIN_SESSION_SECRET`: Random secret used to sign admin session cookies. Generate at least 32 random bytes.

Use `.env.example` as the source of truth. Never commit `.env.local`.

## Database

Apply both files under `supabase/migrations/` in filename order. The second migration creates the operational CRM:

- `leads`: canonical waitlist and demo records, deduplicated by email.
- `admin_users`: individual Supabase Auth administrators and roles.
- `lead_audit_events`: append-only operational history.

Public waitlist and demo submissions go through `POST /api/leads`; clients do not write directly to Supabase tables. Legacy `early_access` and `demo_requests` rows are backfilled into `leads`.

## Admin

- Login: `/admin/login`
- Dashboard: `/admin`
- Logout: `POST /api/admin/logout`

The first login bootstraps an owner only when `admin_users` is empty and the submitted password matches `ADMIN_PASSWORD`. Enter the owner's email plus that password, then remove `ADMIN_PASSWORD` from the environment.

Owners can add individual administrators from the dashboard. Roles are:

- `viewer`: read-only CRM access.
- `operator`: update leads, ownership, notes, and follow-ups.
- `admin`: operator access reserved for future destructive operations.
- `owner`: full access plus administrator account management.

Admin sessions identify the individual user, use signed HTTP-only same-site cookies, and expire after 24 hours. Every admin mutation verifies the active account and role server-side. The dashboard includes combined funnels, operational fields, filtering, pagination, CSV export, conversion metrics, and lead audit history.

## Quality checks

```bash
npm run lint
npm run typecheck
npm test
npm run build
```

The GitHub Actions workflow runs these checks for pushes and pull requests.

## Deployment

Configure all environment variables in the hosting provider, apply the Supabase migration, and run `npm run build`. Vercel is the simplest deployment target for this Next.js app.

## Flutter app

The `kwanpay_app/` directory is a separate Flutter application with its own dependencies and environment setup. Run Flutter commands from that directory; npm commands at the repository root apply only to the web app.
