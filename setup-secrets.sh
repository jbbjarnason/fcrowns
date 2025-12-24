#!/usr/bin/env bash
#
# Production Secrets Generator for Five Crowns
# This script generates cryptographically secure secrets using OpenSSL.
# Run this once on your production server. Secrets are written to .env files
# and should NEVER be committed to git.
#
set -euo pipefail

echo "================================================"
echo "  Five Crowns - Production Secrets Generator"
echo "================================================"
echo ""

# Check for OpenSSL
if ! command -v openssl &> /dev/null; then
    echo "ERROR: OpenSSL is required but not installed."
    exit 1
fi

# Generate cryptographically secure secrets
echo "Generating cryptographically secure secrets..."
JWT_SECRET=$(openssl rand -base64 48 | tr -d '\n')
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d '\n' | tr -d '/' | tr -d '+')
LIVEKIT_API_KEY=$(openssl rand -hex 12)
LIVEKIT_API_SECRET=$(openssl rand -base64 32 | tr -d '\n')

# Prompt for required configuration
echo ""
echo "Please provide your production configuration:"
echo ""

read -p "Production domain (e.g., fcrowns.example.com): " DOMAIN
if [[ -z "$DOMAIN" ]]; then
    echo "ERROR: Domain is required"
    exit 1
fi

read -p "SMTP Host (e.g., smtp.sendgrid.net): " SMTP_HOST
read -p "SMTP Port [587]: " SMTP_PORT
SMTP_PORT=${SMTP_PORT:-587}
read -p "SMTP Username: " SMTP_USERNAME
read -sp "SMTP Password: " SMTP_PASSWORD
echo ""
read -p "SMTP From Address (e.g., no-reply@${DOMAIN}): " SMTP_FROM
SMTP_FROM=${SMTP_FROM:-"no-reply@${DOMAIN}"}

# Create infra/.env for docker-compose
INFRA_ENV_FILE="infra/.env"
echo ""
echo "Writing ${INFRA_ENV_FILE}..."

cat > "${INFRA_ENV_FILE}" << EOF
# Production Environment - Generated $(date -Iseconds)
# DO NOT COMMIT THIS FILE TO GIT

# Environment mode
ENVIRONMENT=production

# Database (used by docker-compose)
POSTGRES_USER=fivecrowns
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_DB=fivecrowns

# Server configuration
DATABASE_URL=postgres://fivecrowns:${POSTGRES_PASSWORD}@postgres:5432/fivecrowns
JWT_SECRET=${JWT_SECRET}
JWT_ACCESS_TTL_DAYS=7

# CORS - your production domain(s), comma-separated
ALLOWED_ORIGINS=https://${DOMAIN}

# Trust proxy headers (X-Forwarded-For) for rate limiting
TRUST_PROXY=true

# SMTP Configuration
SMTP_HOST=${SMTP_HOST}
SMTP_PORT=${SMTP_PORT}
SMTP_FROM=${SMTP_FROM}
SMTP_USERNAME=${SMTP_USERNAME}
SMTP_PASSWORD=${SMTP_PASSWORD}
SMTP_SECURE=true

# Base URL (for email links)
BASE_URL=https://${DOMAIN}

# LiveKit
LIVEKIT_URL=wss://livekit.${DOMAIN}
LIVEKIT_API_KEY=${LIVEKIT_API_KEY}
LIVEKIT_API_SECRET=${LIVEKIT_API_SECRET}
EOF

chmod 600 "${INFRA_ENV_FILE}"
echo "Created ${INFRA_ENV_FILE} (permissions: 600)"

# Create livekit.yaml with the generated keys
LIVEKIT_CONFIG="infra/livekit.yaml"
echo "Writing ${LIVEKIT_CONFIG}..."

cat > "${LIVEKIT_CONFIG}" << EOF
# LiveKit Server Configuration - Generated $(date -Iseconds)
port: 7880
rtc:
  udp_port: 7882
  tcp_port: 7881
  use_external_ip: true
keys:
  ${LIVEKIT_API_KEY}: ${LIVEKIT_API_SECRET}
EOF

chmod 600 "${LIVEKIT_CONFIG}"
echo "Created ${LIVEKIT_CONFIG} (permissions: 600)"

# Summary
echo ""
echo "================================================"
echo "  Secrets Generated Successfully!"
echo "================================================"
echo ""
echo "Files created:"
echo "  - ${INFRA_ENV_FILE}"
echo "  - ${LIVEKIT_CONFIG}"
echo ""
echo "IMPORTANT:"
echo "  1. These files contain secrets - NEVER commit them to git"
echo "  2. Back up these files securely (password manager, vault, etc.)"
echo "  3. The following secrets were generated:"
echo "     - JWT_SECRET (64 chars)"
echo "     - POSTGRES_PASSWORD (32 chars)"
echo "     - LIVEKIT_API_KEY (24 chars)"
echo "     - LIVEKIT_API_SECRET (32 chars)"
echo ""
echo "To deploy:"
echo "  cd infra && docker-compose up -d"
echo ""
