#!/bin/bash

# Maps a subdomain (e.g. dev.datapalli.io) to a Cloud Run service.
# For apex domains, use ./map-domain.sh instead.
#
# Usage:
#   SUBDOMAIN=dev ./map-subdomain.sh        # maps dev.datapalli.io
#   SUBDOMAIN=staging ./map-subdomain.sh    # maps staging.datapalli.io

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/.env"

if [[ -z "${SUBDOMAIN}" ]]; then
  echo "Error: SUBDOMAIN is required. Set it in .env (e.g. SUBDOMAIN=dev)"
  return 2>/dev/null || true
fi

FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN}"

# Step 1: Check parent domain is verified
echo "==> Checking if ${DOMAIN} is verified..."
if ! gcloud domains list-user-verified --project ${PROJECT_ID} 2>/dev/null | grep -q "${DOMAIN}"; then
  echo "ERROR: ${DOMAIN} is not verified. Run this first:"
  echo "  gcloud domains verify ${DOMAIN}"
  return 2>/dev/null || true
fi
echo "==> ✓ ${DOMAIN} is verified"
echo ""

# Step 2: Create subdomain mapping
echo "==> Mapping ${FULL_DOMAIN} to ${SERVICE}"
if ! gcloud beta run domain-mappings create \
  --service ${SERVICE} \
  --domain ${FULL_DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID} \
  --quiet; then
  echo "ERROR: Failed to map ${FULL_DOMAIN}. Check the error above."
  return 2>/dev/null || true
fi

echo ""
echo "==> Done! Add this DNS record at your domain registrar:"
echo ""
echo "  Type:  CNAME"
echo "  Name:  ${SUBDOMAIN}"
echo "  Value: ghs.googlehosted.com."
echo "  TTL:   1 Hour (or 3600)"
echo ""
echo "==> Once DNS propagates, verify with: ./verify-domain.sh"
