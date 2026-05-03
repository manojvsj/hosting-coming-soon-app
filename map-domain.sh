#!/bin/bash

# Maps apex domain (e.g. datapalli.io) + www to a Cloud Run service.
# For subdomains, use ./map-subdomain.sh instead.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/.env"

echo "==> Mapping ${DOMAIN} to ${SERVICE}"
if ! gcloud beta run domain-mappings create \
  --service ${SERVICE} \
  --domain ${DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID} \
  --quiet; then
  echo "ERROR: Failed to map ${DOMAIN}. Check the error above."
  exit 1
fi

echo "==> Mapping www.${DOMAIN} to ${SERVICE}"
if ! gcloud beta run domain-mappings create \
  --service ${SERVICE} \
  --domain www.${DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID} \
  --quiet; then
  echo "ERROR: Failed to map www.${DOMAIN}. Check the error above."
  exit 1
fi

echo ""
echo "==> Add these DNS records at your domain registrar:"
gcloud beta run domain-mappings describe \
  --domain ${DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID} \
  --format='table(resourceRecords.type, resourceRecords.rrdata)'

echo ""
echo "==> www DNS records:"
gcloud beta run domain-mappings describe \
  --domain www.${DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID} \
  --format='table(resourceRecords.type, resourceRecords.rrdata)'

echo ""
echo "==> Apex domain: add A/AAAA records at your registrar"
echo "==> Once DNS propagates, verify with: ./verify-domain.sh"