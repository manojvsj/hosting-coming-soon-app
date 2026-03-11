# 🚀 Coming Soon — Cloud Run Deployment Guide

A **"Coming Soon"** landing page built with **Python + Flask**, containerized with **Docker**, deployed on **Google Cloud Run**, with a custom domain from **GoDaddy**.

---

## Table of Contents

- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [1. Local Development](#1-local-development)
- [2. Docker Setup](#2-docker-setup)
- [3. Environment Configuration](#3-environment-configuration)
- [4. Deploy (3 Scripts, Zero Manual Steps)](#4-deploy-3-scripts-zero-manual-steps)
- [5. Custom Domain Setup (GoDaddy)](#5-custom-domain-setup-godaddy)
- [6. CI/CD with GitHub Actions](#6-cicd-with-github-actions)
- [7. Useful Commands](#7-useful-commands)
- [8. Troubleshooting](#8-troubleshooting)
- [9. Cost Estimate](#9-cost-estimate)

---

## Architecture

```
┌──────────────┐     push to main     ┌─────────────────────┐
│   Developer   │ ──────────────────▶  │   GitHub Actions     │
│  (GitHub)     │                      │   CI/CD Pipeline     │
└──────────────┘                      └──────────┬──────────┘
                                                  │
                                      ┌───────────▼───────────┐
                                      │  Google Artifact       │
                                      │  Registry              │
                                      │  (Docker Image Store)  │
                                      └───────────┬───────────┘
                                                  │
                                      ┌───────────▼───────────┐
                                      │  Google Cloud Run      │
                                      │  Python 3.11 + Flask   │
                                      │  + Gunicorn (WSGI)     │
                                      └───────────┬───────────┘
                                                  │
                                      ┌───────────▼───────────┐
                                      │  Cloud Run Domain      │
                                      │  Mapping + Auto SSL    │
                                      └───────────┬───────────┘
                                                  │
                           ┌──────────────────────▼─────────────────┐
                           │  GoDaddy DNS                           │
                           │  A records → Google IPs                │
                           │  CNAME www → ghs.googlehosted.com     │
                           └──────────────────────┬────────────────┘
                                                  │
                                      ┌───────────▼───────────┐
                                      │   End User Browser     │
                                      │  https://yourdomain.com│
                                      └───────────────────────┘
```

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| **Backend** | Python 3.11, Flask 3.1, Gunicorn 23.0 |
| **Frontend** | HTML5, CSS3, Vanilla JavaScript |
| **Containerization** | Docker (multi-stage build) |
| **Container Registry** | Google Artifact Registry |
| **Hosting** | Google Cloud Run (Serverless) |
| **CI/CD** | GitHub Actions |
| **Domain Registrar** | GoDaddy |
| **SSL** | Google-managed (automatic) |

---

## Prerequisites

| Tool | Install |
|------|---------|
| Python 3.11+ | [python.org](https://python.org) |
| Docker Desktop | [docker.com](https://www.docker.com/products/docker-desktop) |
| Google Cloud SDK | [cloud.google.com/sdk](https://cloud.google.com/sdk/docs/install) |
| GCP Account | [cloud.google.com](https://cloud.google.com) |
| GoDaddy Domain | [godaddy.com](https://www.godaddy.com) |

---

## Project Structure

```
coming-soon-app/
├── .env                     # Environment variables (git-ignored)
├── .env.example             # Template for .env
├── .gitignore               # Git ignore rules
├── .dockerignore            # Docker build exclusions
├── app/
│   ├── __init__.py          # Flask application factory
│   ├── main.py              # Routes (/, /health)
│   ├── static/
│   │   ├── css/
│   │   │   └── style.css    # Landing page styles
│   │   └── js/
│   │       └── script.js    # Countdown timer & form handler
│   └── templates/
│       └── index.html       # Landing page HTML
├── wsgi.py                  # Gunicorn WSGI entry point
├── gunicorn.conf.py         # Gunicorn production config
├── requirements.txt         # Python dependencies
├── Dockerfile               # Multi-stage Docker build
├── gcloud-setup.sh          # Step 1: One-time GCP setup
├── cloud-run-deploy.sh      # Step 2: Build & deploy
├── map-domain.sh            # Step 3: Custom domain mapping
├── verify-domain.sh         # Check domain & SSL status
├── local-docker.sh          # Local Docker testing
├── README.md                # This file
└── .github/
    └── workflows/
        └── deploy.yml       # GitHub Actions CI/CD pipeline
```

---

## 1. Local Development

### 1.1 — Clone & Setup

```bash
git clone <your-repo-url>
cd coming-soon-app

# Create virtual environment
python -m venv venv
source venv/bin/activate        # macOS/Linux
# venv\Scripts\activate         # Windows

# Install dependencies
pip install -r requirements.txt
```

### 1.2 — Run Development Server

```bash
flask --app app:create_app run --host=0.0.0.0 --port=8080 --debug
```

Open: **http://localhost:8080**

### 1.3 — Run with Gunicorn (Production-like)

```bash
gunicorn --config gunicorn.conf.py "wsgi:application"
```

---

## 2. Docker Setup

### 2.1 — Build Image

```bash
docker build -t coming-soon-app .
```

### 2.2 — Run Container Locally

```bash
docker run -p 8080:8080 -e PORT=8080 coming-soon-app
```

Open: **http://localhost:8080**

### 2.3 — Key Dockerfile Features

- **Multi-stage build** — keeps final image ~120MB (vs ~900MB with full Python)
- **Non-root user** — runs as `appuser` for security
- **Health check** — built-in container health monitoring
- **Layer caching** — `requirements.txt` copied first for faster rebuilds

---

## 3. Environment Configuration

All project-specific values live in a single `.env` file — **no hardcoded values in scripts**.

### 3.1 — Create `.env` File

```bash
cp .env.example .env
```

Edit `.env` with your values:

```dotenv
export PROJECT_ID=your-gcp-project-id
export REGION=your-region
export REPO=your-artifact-repo
export IMAGE=your-image-name
export SERVICE=your-cloud-run-service
export DOMAIN=yourdomain.com
```

> The `.env` file is git-ignored — it will never be committed.

### 3.2 — Authenticate & Create Project

```bash
gcloud auth login

# Create project (skip if it already exists)
gcloud projects create ${PROJECT_ID} --name="Your Project"

# Enable billing (required for Cloud Run)
# https://console.cloud.google.com/billing
```

---

## 4. Deploy (3 Scripts, Zero Manual Steps)

The entire deployment is handled by three scripts. Each sources `.env` automatically.

### Step 1 — One-time GCP Setup

```bash
./gcloud-setup.sh
```

This enables APIs and creates the Artifact Registry repo. Safe to re-run (skips if repo already exists).

### Step 2 — Build & Deploy to Cloud Run

```bash
./cloud-run-deploy.sh
```

Builds the image via Cloud Build and deploys to Cloud Run. Prints the service URL on completion.

### Step 3 — Map Custom Domain (one-time)

```bash
./map-domain.sh
```

Maps your root domain and `www` subdomain. Prints the DNS records you need to add at your registrar.

### Verify Domain & SSL

```bash
./verify-domain.sh
```

> **Re-deploying after code changes?** Just run `./cloud-run-deploy.sh` again — that's it.

### Key Deploy Flags Explained

| Flag | Purpose |
|------|---------|
| `--port 8080` | Port the container listens on (must match Gunicorn config) |
| `--allow-unauthenticated` | Makes the service publicly accessible |
| `--min-instances 0` | Scales to zero when idle (saves cost) |
| `--max-instances 3` | Maximum concurrent containers |
| `--memory 512Mi` | Memory per container instance |
| `--cpu 1` | vCPUs per container instance |
| `--timeout 120` | Request timeout in seconds |

---

## 5. Custom Domain Setup (GoDaddy)

### 5.1 — Verify Domain Ownership

1. Go to [Google Search Console](https://search.google.com/search-console)
2. Add your domain → verify via DNS or automatic verification
3. Confirm verification:

```bash
source .env
gcloud domains list-user-verified --project ${PROJECT_ID}
```

### 5.2 — Create Domain Mapping

Already handled by `./map-domain.sh` in Step 3 above. Or run manually:

```bash
source .env
gcloud beta run domain-mappings create \
  --service ${SERVICE} \
  --domain ${DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID}
```

> ⚠️ **Domain mapping is NOT supported in all regions.**
> Supported regions include: `us-central1`, `us-east1`, `us-west1`,
> `europe-west1`, `asia-east1`, `asia-northeast1`, `asia-southeast1`.
> It is NOT supported in `asia-south1`.

### 5.3 — Configure GoDaddy DNS

Go to **GoDaddy** → **My Products** → your domain → **DNS Management**

**Delete** the default `A` record and `CNAME` for `www`, then add:

#### A Records (Root Domain)

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | `@` | `216.239.32.21` | 600 |
| A | `@` | `216.239.34.21` | 600 |
| A | `@` | `216.239.36.21` | 600 |
| A | `@` | `216.239.38.21` | 600 |

#### AAAA Records (IPv6)

| Type | Name | Value | TTL |
|------|------|-------|-----|
| AAAA | `@` | `2001:4860:4802:32::15` | 600 |
| AAAA | `@` | `2001:4860:4802:34::15` | 600 |
| AAAA | `@` | `2001:4860:4802:36::15` | 600 |
| AAAA | `@` | `2001:4860:4802:38::15` | 600 |

#### CNAME Record (www Subdomain)

| Type | Name | Value | TTL |
|------|------|-------|-----|
| CNAME | `www` | `ghs.googlehosted.com` | 600 |

### 5.4 — How the Domain Connection Works

```
yourdomain.com
    │
    ▼ (GoDaddy A records)
Google IPs (216.239.x.x)
    │
    ▼ (Google internal routing)
Cloud Run Domain Mapping
    │
    ▼ (maps domain → service)
coming-soon-service (Cloud Run)
    │
    ▼
Your Flask App responds
```

### 5.5 — Verify Domain & SSL

Use the provided script:

```bash
./verify-domain.sh
```

Or check manually:

```bash
source .env

# Check domain mapping status
gcloud beta run domain-mappings describe \
  --domain ${DOMAIN} \
  --region ${REGION} \
  --project ${PROJECT_ID}
# Look for: certificateStatus: ACTIVE

# Check DNS propagation
dig ${DOMAIN} A +short
# Expected: 216.239.32.21, 216.239.34.21, 216.239.36.21, 216.239.38.21

dig www.${DOMAIN} CNAME +short
# Expected: ghs.googlehosted.com.

# Test HTTPS
curl -I https://${DOMAIN}
```

### 5.6 — Timeline

| What | Expected Time |
|------|---------------|
| DNS propagation | 5 min – 48 hours (usually ~30 min) |
| SSL certificate | 15 min – 24 hours (usually ~15 min) |

Check propagation at: [dnschecker.org](https://dnschecker.org)

---

## 6. CI/CD with GitHub Actions

### 6.1 — Create GCP Service Account

```bash
source .env

# Create service account
gcloud iam service-accounts create github-deployer \
  --display-name="GitHub Actions Deployer" \
  --project ${PROJECT_ID}

# Grant roles
for ROLE in roles/run.admin roles/artifactregistry.writer roles/iam.serviceAccountUser; do
  gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:github-deployer@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="${ROLE}"
done

# Create JSON key
gcloud iam service-accounts keys create key.json \
  --iam-account=github-deployer@${PROJECT_ID}.iam.gserviceaccount.com

# Base64-encode for GitHub Secrets
cat key.json | base64 -w 0
# Copy this output, then DELETE key.json
```

### 6.2 — Add GitHub Repository Secrets

Go to: **Repo → Settings → Secrets and variables → Actions → New repository secret**

| Secret Name | Value |
|-------------|-------|
| `GCP_PROJECT_ID` | Your `PROJECT_ID` from `.env` |
| `GCP_SA_KEY` | Base64-encoded contents of `key.json` |
| `GCP_REGION` | Your `REGION` from `.env` |

### 6.3 — Workflow File

The workflow at `.github/workflows/deploy.yml` automatically builds and deploys
on every push to `main`:

1. Checks out code
2. Authenticates to Google Cloud
3. Builds Docker image
4. Pushes to Artifact Registry
5. Deploys to Cloud Run

---

## 7. Useful Commands

All commands below assume you've sourced your environment:

```bash
source .env
```

### Service Management

```bash
# List all services
gcloud run services list --project ${PROJECT_ID}

# Describe service
gcloud run services describe ${SERVICE} \
  --region ${REGION} --project ${PROJECT_ID}

# Get service URL
gcloud run services describe ${SERVICE} \
  --region ${REGION} --project ${PROJECT_ID} \
  --format="value(status.url)"

# View logs
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=${SERVICE}" \
  --project ${PROJECT_ID} \
  --limit 50 \
  --format="table(timestamp, textPayload)"

# Delete service
gcloud run services delete ${SERVICE} \
  --region ${REGION} --project ${PROJECT_ID}
```

### Domain Management

```bash
# List domain mappings
gcloud beta run domain-mappings list \
  --region ${REGION} --project ${PROJECT_ID}

# Describe domain mapping
gcloud beta run domain-mappings describe \
  --domain ${DOMAIN} \
  --region ${REGION} --project ${PROJECT_ID}

# Delete domain mapping
gcloud beta run domain-mappings delete \
  --domain ${DOMAIN} \
  --region ${REGION} --project ${PROJECT_ID}
```

### Image Management

```bash
# List images
gcloud artifacts docker images list \
  ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}

# Delete old images (keep latest)
gcloud artifacts docker images delete \
  ${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE}:old-tag
```

---

## 8. Troubleshooting

### "Failed to start and listen on PORT"

| Cause | Fix |
|-------|-----|
| Architecture mismatch (arm64 vs amd64) | Use `gcloud builds submit` or `docker build --platform linux/amd64` |
| Gunicorn not binding to `0.0.0.0` | Check `gunicorn.conf.py` → `bind = "0.0.0.0:PORT"` |
| Missing `wsgi.py` | Create `wsgi.py` at project root |
| Missing `app/__init__.py` | Ensure the file exists with `create_app()` |
| Not enough memory | Increase `--memory` to `512Mi` or `1Gi` |

### "Domain mapping not supported in region"

Domain mapping is only supported in select regions. Use `asia-southeast1`
instead of `asia-south1`. See [Section 5.2](#52--create-domain-mapping).

### "No logs found"

```bash
source .env
gcloud logging read \
  "resource.type=cloud_run_revision" \
  --project ${PROJECT_ID} \
  --limit 30 \
  --freshness=10m
```

### DNS Not Propagating

- Wait up to 48 hours (usually 30 min)
- Verify records at [dnschecker.org](https://dnschecker.org)
- Ensure you deleted GoDaddy's default A record
- TTL should be 600 (not 3600)

### SSL Certificate Stuck on "PROVISIONING"

- DNS must be correctly configured first
- Certificate provisioning starts only after DNS points to Google
- Can take up to 24 hours (usually 15 min)
- Check: `gcloud beta run domain-mappings describe --domain ...`

---

## 9. Cost Estimate

| Resource | Cost |
|----------|------|
| **Cloud Run** (min-instances=0) | Free tier: 2M requests/month, 360K vCPU-seconds. A coming-soon page stays well within free tier. |
| **Artifact Registry** | Free tier: 500MB storage. Our image is ~55MB. |
| **Cloud Build** | Free tier: 120 build-minutes/day. |
| **SSL Certificate** | Free (Google-managed) |
| **Domain (GoDaddy)** | Varies (~$10-15/year) |
| **Estimated monthly cost** | **$0 – $1/month** for a low-traffic coming-soon page |

---

## License

MIT