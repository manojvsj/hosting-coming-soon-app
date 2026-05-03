#!/bin/bash

# Deletes a Cloud Run domain mapping.
# DNS records (CNAME/A/AAAA) are NOT affected — only the Google-side routing is removed.
#
# Usage:
#   ./delete-domain-mapping.sh              # deletes subdomain mapping (if SUBDOMAIN is set in .env)
#   ./delete-domain-mapping.sh --apex       # deletes apex domain + www mapping

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/.env"

APEX_MODE=false
if [[ "$1" == "--apex" ]]; then
  APEX_MODE=true
fi

if [[ "${APEX_MODE}" == "true" ]]; then
  # Delete apex domain mapping
  echo "==> Deleting mapping for ${DOMAIN}"
  if ! gcloud beta run domain-mappings delete \
    --domain ${DOMAIN} \
    --region ${REGION} \
    --project ${PROJECT_ID} \
    --quiet; then
    echo "ERROR: Failed to delete mapping for ${DOMAIN}."
    return 2>/dev/null || true
  fi
  echo "==> ✓ ${DOMAIN} mapping deleted"

  echo ""
  echo "==> Deleting mapping for www.${DOMAIN}"
  if ! gcloud beta run domain-mappings delete \
    --domain www.${DOMAIN} \
    --region ${REGION} \
    --project ${PROJECT_ID} \
    --quiet; then
    echo "ERROR: Failed to delete mapping for www.${DOMAIN}."
    return 2>/dev/null || true
  fi
  echo "==> ✓ www.${DOMAIN} mapping deleted"
else
  # Delete subdomain mapping
  if [[ -z "${SUBDOMAIN}" ]]; then
    echo "Error: SUBDOMAIN is required in .env, or use --apex for apex domain."
    return 2>/dev/null || true
  fi

  FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN}"

  echo "==> Deleting mapping for ${FULL_DOMAIN}"
  if ! gcloud beta run domain-mappings delete \
    --domain ${FULL_DOMAIN} \
    --region ${REGION} \
    --project ${PROJECT_ID} \
    --quiet; then
    echo "ERROR: Failed to delete mapping for ${FULL_DOMAIN}."
    return 2>/dev/null || true
  fi
  echo "==> ✓ ${FULL_DOMAIN} mapping deleted"
fi

echo ""
echo "==> Done. DNS records are NOT affected."
echo "==> To remap, update SERVICE in .env and re-run ./map-subdomain.sh or ./map-domain.sh"
