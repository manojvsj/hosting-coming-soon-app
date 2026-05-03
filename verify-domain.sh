#!/bin/bash

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/.env"

# Determine which domain to verify
if [[ -n "${SUBDOMAIN}" ]]; then
  CHECK_DOMAIN="${SUBDOMAIN}.${DOMAIN}"
  echo "==> Verifying subdomain: ${CHECK_DOMAIN}"
else
  CHECK_DOMAIN="${DOMAIN}"
  echo "==> Verifying apex domain: ${CHECK_DOMAIN}"
fi

echo ""
echo "==> Domain mapping status"
gcloud beta run domain-mappings describe \
  --domain ${CHECK_DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID}

echo ""
echo "==> DNS propagation check"
if [[ -n "${SUBDOMAIN}" ]]; then
  dig ${CHECK_DOMAIN} CNAME +short
else
  dig ${CHECK_DOMAIN} A +short
fi

echo ""
echo "==> HTTPS check"
curl -sI https://${CHECK_DOMAIN} | head -5