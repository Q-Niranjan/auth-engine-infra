# Quick Start

Get AuthEngine running locally in three steps: databases + API, then the dashboard.

## Prerequisites

- Docker and Docker Compose (recommended for backend)
- Node.js 20+ and npm (frontend)
- `openssl rand -hex 32` for generating secrets

## 1. Backend (`auth-engine`)

```bash
cd auth-engine
cp .env.example .env
```

Edit `.env` — at minimum set:

- `SECRET_KEY` and `JWT_SECRET_KEY` (32+ characters each)
- `POSTGRES_URL`, `MONGODB_URL`, `REDIS_URL` (defaults work with Compose)

Start the stack and run migrations:

```bash
docker compose up -d
docker compose exec app auth-engine migrate
```

API explorer: [http://localhost:8000/docs](http://localhost:8000/docs)

### Manual run (without Compose app container)

```bash
uv sync
auth-engine migrate
auth-engine run
```

On first startup the API seeds RBAC roles and a super admin from `SUPERADMIN_EMAIL` / `SUPERADMIN_PASSWORD`.

## 2. Frontend (`auth-engine-frontend`)

```bash
cd auth-engine-frontend
cp .env.example .env.local
npm ci
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

Default API target:

```env
NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

## 3. Smoke test

1. Open Swagger at `http://localhost:8000/docs` and call `GET /api/v1/` (health).
2. Log in at `http://localhost:3000/login` with the super admin credentials from `.env`.
3. Platform routes (`/platform/*`) require a platform-scoped role; tenant routes require selecting a tenant in the dashboard.

## OAuth providers (optional)

To enable Google, GitHub, or Microsoft social login, set the matching `*_CLIENT_ID`, `*_CLIENT_SECRET`, and `*_REDIRECT_URI` in `.env`. Redirect URIs for local dev:

```text
http://localhost:8000/api/v1/auth/oauth/google/callback
http://localhost:8000/api/v1/auth/oauth/github/callback
http://localhost:8000/api/v1/auth/oauth/microsoft/callback
```

## Next steps

- [OAuth2 / OIDC Guides](oauth2-oidc-guides.md) — integrate apps as relying parties
- [API Reference](api-reference.md) — full endpoint list
- [Deployment Guide](deployment.md) — production on AWS
