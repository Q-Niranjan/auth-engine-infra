# AuthEngine Documentation

Canonical documentation for the AuthEngine platform. Published at [docs.bestcrmhub.com](https://docs.bestcrmhub.com).

## Platform URLs

| Host | Role |
|------|------|
| [auth.bestcrmhub.com](https://auth.bestcrmhub.com) | Identity Provider (OIDC login, consent) |
| [api.bestcrmhub.com](https://api.bestcrmhub.com) | REST API · [Swagger](https://api.bestcrmhub.com/docs) |
| [app.bestcrmhub.com](https://app.bestcrmhub.com) | Admin dashboard |
| [docs.bestcrmhub.com](https://docs.bestcrmhub.com) | This documentation |

## Repositories

| Repository | Purpose |
|------------|---------|
| [auth-engine](https://github.com/Q-Niranjan/auth-engine) | FastAPI backend — IAM, OIDC, introspection |
| [auth-engine-frontend](https://github.com/Q-Niranjan/auth-engine-frontend) | Next.js dashboard |
| [auth-engine-infra](https://github.com/Q-Niranjan/auth-engine-infra) | AWS Terraform + this `docs/` folder |

> **View docs on GitHub:** use the `auth-engine-infra` repository, not the `auth-engine` repo.  
> Example: `https://github.com/Q-Niranjan/auth-engine-infra/blob/main/docs/architecture.md`

## Guides

| Guide | Description |
|-------|-------------|
| [Quick Start](quick-start.md) | Run backend, frontend, and databases locally |
| [OAuth2 / OIDC Guides](oauth2-oidc-guides.md) | Social login, OIDC provider, relying-party integration |
| [API Reference](api-reference.md) | Endpoints, auth headers, request/response patterns |
| [Architecture](architecture.md) | System design, data stores, request flow |
| [Deployment Guide](deployment.md) | AWS hybrid layout, DNS, CI/CD, docs publishing |
| [Security Overview](security-overview.md) | Tokens, sessions, PBAC, hardening checklist |

## Quick links

- OIDC discovery: `GET https://api.bestcrmhub.com/.well-known/openid-configuration`
- JWKS: `GET https://api.bestcrmhub.com/.well-known/jwks.json`
- Token introspect: `POST https://api.bestcrmhub.com/api/v1/platform/service-keys/introspect` (header `X-API-Key`)
