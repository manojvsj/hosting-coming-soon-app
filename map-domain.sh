#!/bin/bash

# Maps apex domain (e.g. datapalli.io) + www to a Cloud Run service.
# For subdomains, use ./map-subdomain.sh instead.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/.env"

# Step 1: Check domain is verified
echo "==> Checking if ${DOMAIN} is verified..."
if ! gcloud domains list-user-verified --project ${PROJECT_ID} 2>/dev/null | grep -q "${DOMAIN}"; then
  echo "ERROR: ${DOMAIN} is not verified. Run this first:"
  echo "  gcloud domains verify ${DOMAIN}"
  return 2>/dev/null || true
fi
echo "==> ✓ ${DOMAIN} is verified"
echo ""

# Step 2: Create domain mappings
echo "==> Mapping ${DOMAIN} to ${SERVICE}"
if ! gcloud beta run domain-mappings create \
  --service ${SERVICE} \
  --domain ${DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID} \
  --quiet; then
  echo "ERROR: Failed to map ${DOMAIN}. Check the error above."
  return 2>/dev/null || true
fi

echo "==> Mapping www.${DOMAIN} to ${SERVICE}"
if ! gcloud beta run domain-mappings create \
  --service ${SERVICE} \
  --domain www.${DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID} \
  --quiet; then
  echo "ERROR: Failed to map www.${DOMAIN}. Check the error above."
  return 2>/dev/null || true
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