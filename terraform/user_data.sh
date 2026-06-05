#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

dnf install -y amazon-ecr-credential-helper

mkdir -p /opt/authengine
cat >/opt/authengine/README.txt <<'EOF'
AuthEngine API host. Deploy with GitHub Actions (pull from ECR) or manually:

  docker pull <ecr-api-url>:<tag>
  docker run -d --name authengine-api -p 8000:8000 --env-file /opt/authengine/.env <image>

Place environment file at /opt/authengine/.env (POSTGRES_URL, REDIS_URL, MONGODB_URL, secrets).
EOF

echo "ECR API repository: ${ecr_api_url}" >>/opt/authengine/README.txt
