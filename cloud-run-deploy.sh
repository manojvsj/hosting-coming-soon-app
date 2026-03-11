#!/bin/bash
set -e

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/.env"

IMAGE_TAG="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE}:latest"

echo "==> Building image via Cloud Build"
gcloud builds submit \
  --tag ${IMAGE_TAG} \
  --project ${PROJECT_ID}

echo "==> Deploying to Cloud Run: ${SERVICE}"
gcloud run deploy ${SERVICE} \
  --image ${IMAGE_TAG} \
  --platform managed \
  --region ${REGION} \
  --port 8080 \
  --allow-unauthenticated \
  --min-instances 0 \
  --max-instances 3 \
  --memory 256Mi \
  --cpu 1 \
  --timeout 120 \
  --set-env-vars "WEB_CONCURRENCY=2,WEB_THREADS=4" \
  --quiet

echo "==> Deploy complete! Service URL:"
gcloud run services describe ${SERVICE} --region ${REGION} --format='value(status.url)'