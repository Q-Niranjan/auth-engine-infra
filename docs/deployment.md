# Deployment Guide

Production uses a **hybrid layout**: AWS for compute and PostgreSQL; Upstash (Redis) and MongoDB Atlas on managed free tiers. The API runs as a Docker container on EC2; the dashboard deploys to Amplify (or container hosting).

## Architecture summary

| Layer | Where | Notes |
|-------|-------|-------|
| API | EC2 + EIP | Single backend service, port 8000 |
| PostgreSQL | RDS (`db.t4g.micro`) | Created by Terraform |
| Redis | Upstash | TLS URL in app `.env` |
| MongoDB | Atlas M0 | Audit logs only |
| Frontend | Amplify / ECR image | `NEXT_PUBLIC_*` at build time |
| Docs | GitHub Pages / Cloudflare Pages | This `docs/` folder → `docs.bestcrmhub.com` |

No NAT gateway or ALB in the default Terraform module (cost-optimized).

## Terraform (`auth-engine-infra`)

```bash
cd auth-engine-infra/terraform
cp terraform.tfvars.example terraform.tfvars
# Set db_password (min 8 characters)

terraform init
terraform plan
terraform apply
```

### Resources created

- VPC with public subnet
- EC2 instance (`t4g.micro`) + Elastic IP
- RDS PostgreSQL (`db.t4g.micro`)
- ECR repositories: `authengine-api`, `authengine-frontend`
- Security groups (API, RDS, optional SSH)
- IAM role for EC2 (ECR pull, SSM)

Key outputs: `ec2_public_ip`, RDS endpoint, ECR URLs (see `outputs.tf`).

### Variables (common)

| Variable | Default | Purpose |
|----------|---------|---------|
| `aws_region` | `ap-south-1` | Region |
| `project_name` | `authengine` | Resource name prefix |
| `root_domain` | `bestcrmhub.com` | DNS documentation |
| `db_password` | (required) | RDS master password |

## EC2 API deployment

Create `/opt/authengine/.env` on the instance:

```env
POSTGRES_URL=postgresql+asyncpg://authengine:<password>@<rds-host>:5432/authengine
REDIS_URL=rediss://<upstash-url>
MONGODB_URL=mongodb+srv://<atlas-uri>
SECRET_KEY=<openssl rand -hex 32>
JWT_SECRET_KEY=<openssl rand -hex 32>
APP_URL=https://auth.bestcrmhub.com
CORS_ORIGINS=["https://app.bestcrmhub.com"]
```

Run the API container:

```bash
docker run -d --name authengine-api --restart unless-stopped \
  -p 8000:8000 --env-file /opt/authengine/.env \
  <ecr-api-url>:<tag>
```

Run migrations once per release:

```bash
docker exec authengine-api auth-engine migrate
```

### Reverse proxy

Use **Caddy** or **nginx** on EC2 so both hostnames proxy to port 8000:

- `api.bestcrmhub.com` — REST + Swagger + `/.well-known`
- `auth.bestcrmhub.com` — IdP login UI and OIDC (same process)

## DNS (example: bestcrmhub.com)

| Host | Type | Target |
|------|------|--------|
| `api` | A | `terraform output ec2_public_ip` |
| `auth` | A | Same EIP as `api` |
| `app` | CNAME | Amplify distribution |
| `docs` | CNAME | GitHub Pages or Cloudflare Pages |

### OAuth redirect URIs (production)

```text
https://api.bestcrmhub.com/api/v1/auth/oauth/google/callback
https://api.bestcrmhub.com/api/v1/auth/oauth/github/callback
https://api.bestcrmhub.com/api/v1/auth/oauth/microsoft/callback
```

Register these in each provider’s developer console.

## Frontend deployment

**Amplify (recommended):**

```env
NEXT_PUBLIC_API_URL=https://api.bestcrmhub.com/api/v1
NEXT_PUBLIC_APP_URL=https://app.bestcrmhub.com
```

**Docker:** build from `auth-engine-frontend/Dockerfile`, push to ECR `authengine-frontend`, run behind your host of choice.

## CI/CD

All workflows are **manual** (`workflow_dispatch`) for now. Run them from **Actions → Run workflow** in each repository. Uncomment the `on:` blocks in each workflow file when you want automatic triggers.

### auth-engine-infra

| Workflow | Purpose |
|----------|---------|
| auth-engine-infra · Terraform Plan | Format check, validate, and plan (no apply) |
| auth-engine-infra · Terraform Apply | Apply changes to AWS (type `apply` to confirm) |

**Secrets:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `TF_VAR_db_PASSWORD`

**Order:** Plan → review → Apply

### auth-engine (backend API)

| Workflow | Purpose |
|----------|---------|
| auth-engine · Lint, Typecheck, and Docker Build | Ruff, Mypy, Docker build (no push) |
| auth-engine · Create Version Tag | Create and push git tag (e.g. `v1.0.0`) |
| auth-engine · Build and Push Docker Image | Build `authengine` image to Docker Hub |
| auth-engine · Create GitHub Release | GitHub Release with changelog |
| auth-engine · Register Production Deployment | Record deployment for api.bestcrmhub.com |

**Secrets:** `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`

**Order:** Lint/Build → Tag → Build/Push (same tag) → Release → Deploy record (after EC2 pull + migrate)

### auth-engine-frontend

| Workflow | Purpose |
|----------|---------|
| auth-engine-frontend · Lint and Build | ESLint and Next.js production build |
| auth-engine-frontend · Create Version Tag | Create and push git tag |
| auth-engine-frontend · Build and Push Docker Image | Build `authengine-frontend` image |
| auth-engine-frontend · Create GitHub Release | GitHub Release with changelog |
| auth-engine-frontend · Register Production Deployment | Record deployment for app.bestcrmhub.com |

**Secrets:** `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN` (optional if using Amplify only)

**Order:** Lint/Build → Tag → Build/Push → Release → Amplify deploy → Deploy record

### Full platform release order

1. **auth-engine-infra · Terraform Plan** then **Terraform Apply**
2. Configure Upstash + Atlas; update EC2 `/opt/authengine/.env`
3. **auth-engine** workflows: CI → Tag → Build/Push → migrate on EC2
4. **auth-engine-frontend** workflows: CI → Tag → Build/Push → Amplify
5. Register deployments (both deploy workflows)
6. Publish docs from `auth-engine-infra/docs/` to docs.bestcrmhub.com

## Publish documentation

Host the `docs/` folder at **docs.bestcrmhub.com**:

- **GitHub Pages:** repo `auth-engine-infra`, branch `main`, folder `/docs`
- **Cloudflare Pages:** same root, custom domain `docs.bestcrmhub.com`

Update cross-links in README files if your org uses different GitHub URLs.

## Local vs production checklist

| Item | Local | Production |
|------|-------|------------|
| `APP_URL` | `http://localhost:8000` | `https://auth.bestcrmhub.com` |
| CORS | `http://localhost:3000` | `https://app.bestcrmhub.com` |
| TLS | Optional | Required (Upstash `rediss://`, HTTPS) |
| Secrets | `.env` | SSM or sealed `.env` on EC2 |
| Super admin password | Change after first login | Strong unique password |

## Related

- [Quick Start](quick-start.md)
- [Security Overview](security-overview.md)
- [Architecture](architecture.md)
