#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/railway-env.sh
source "${SCRIPT_DIR}/railway-env.sh"

REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Starting VCP session on ${SERVICE_NAME} (TTL ~$((VCP_TTL_SECONDS / 60)) min)..."

# Always build + deploy from source. `railway redeploy` reuses the previous
# image (can miss Dockerfile fixes) and fails when vcp-off removed all deployments.
railway up \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}" \
  --service "${SERVICE_NAME}" \
  --path-as-root "${REPO_ROOT}" \
  --detach \
  --yes \
  --message "vcp-on session start"

echo "VCP deploy started — auto-stops after ${VCP_TTL_SECONDS}s unless you run vcp-off.sh first"
echo "Logs: railway logs --service ${SERVICE_NAME} --project ${PROJECT_ID} --lines 50"
