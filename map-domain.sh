#!/bin/bash
set -e

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/.env"

echo "==> Mapping ${DOMAIN} to ${SERVICE}"
gcloud beta run domain-mappings create \
  --service ${SERVICE} \
  --domain ${DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID} \
  --quiet

echo "==> Mapping www.${DOMAIN} to ${SERVICE}"
gcloud beta run domain-mappings create \
  --service ${SERVICE} \
  --domain www.${DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID} \
  --quiet

echo ""
echo "==> Add these DNS records at your domain registrar:"
gcloud beta run domain-mappings describe \
  --domain ${DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID} \
  --format='table(resourceRecords.type, resourceRecords.rrdata)'

echo ""
echo "==> Once DNS propagates, verify with: ./verify-domain.sh"