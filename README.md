# auth-engine-infra

AWS Terraform and **canonical documentation** for the AuthEngine platform.

**Documentation:** [docs/](docs/) · on GitHub: [docs/](https://github.com/Q-Niranjan/auth-engine-infra/tree/main/docs) · published at [docs.bestcrmhub.com](https://docs.bestcrmhub.com)

| Guide | Description |
|-------|-------------|
| [docs/README.md](docs/README.md) | Documentation index |
| [Quick Start](docs/quick-start.md) | Local backend + frontend |
| [OAuth2 / OIDC Guides](docs/oauth2-oidc-guides.md) | Social login and OIDC provider |
| [API Reference](docs/api-reference.md) | REST endpoints |
| [Architecture](docs/architecture.md) | System design and diagrams |
| [Deployment Guide](docs/deployment.md) | AWS, DNS, CI/CD |
| [Security Overview](docs/security-overview.md) | Tokens, PBAC, hardening |

## Related repositories

| Repository | Role |
|------------|------|
| [auth-engine](https://github.com/Q-Niranjan/auth-engine) | Backend API |
| [auth-engine-frontend](https://github.com/Q-Niranjan/auth-engine-frontend) | Admin dashboard |

## Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform apply
```

See [Deployment Guide](docs/deployment.md) for full production steps.
