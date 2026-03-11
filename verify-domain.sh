#!/bin/bash
set -e

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/.env"

echo "==> Domain mapping status"
gcloud beta run domain-mappings describe \
  --domain ${DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID}

echo ""
echo "==> DNS propagation check"
dig ${DOMAIN} A +short

echo ""
echo "==> HTTPS check"
curl -sI https://${DOMAIN} | head -5