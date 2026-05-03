#!/bin/bash
set -e

# Maps a subdomain (e.g. dev.datapalli.io) to a Cloud Run service.
# For apex domains, use ./map-domain.sh instead.
#
# Usage:
#   SUBDOMAIN=dev ./map-subdomain.sh        # maps dev.datapalli.io
#   SUBDOMAIN=staging ./map-subdomain.sh    # maps staging.datapalli.io

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/.env"

if [[ -z "${SUBDOMAIN}" ]]; then
  echo "Error: SUBDOMAIN is required. Example: SUBDOMAIN=dev ./map-subdomain.sh"
  exit 1
fi

FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN}"

echo "==> Mapping ${FULL_DOMAIN} to ${SERVICE}"
gcloud beta run domain-mappings create \
  --service ${SERVICE} \
  --domain ${FULL_DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID} \
  --quiet

echo ""
echo "==> Add this DNS record at your domain registrar:"
gcloud beta run domain-mappings describe \
  --domain ${FULL_DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID} \
  --format='table(resourceRecords.type, resourceRecords.rrdata)'

echo ""
echo "==> Subdomain: add a CNAME record for ${FULL_DOMAIN} pointing to ghs.googlehosted.com."
echo "==> Once DNS propagates, verify with: ./verify-domain.sh"
