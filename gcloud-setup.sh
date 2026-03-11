#!/bin/bash
set -e

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/.env"

echo "==> Setting project to ${PROJECT_ID}"
gcloud config set project ${PROJECT_ID}

echo "==> Enabling required APIs"
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com

echo "==> Creating Artifact Registry repo: ${REPO}"
gcloud artifacts repositories create ${REPO} \
  --repository-format=docker \
  --location=${REGION} \
  --description="Docker repo for Coming Soon app" \
  --quiet 2>/dev/null || echo "    (repo already exists, skipping)"

echo "==> Setup complete! Next run: ./cloud-run-deploy.sh"
