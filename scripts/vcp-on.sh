#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/railway-env.sh
source "${SCRIPT_DIR}/railway-env.sh"

echo "Starting VCP session on ${SERVICE_NAME} (TTL ~$((VCP_TTL_SECONDS / 60)) min)..."
railway redeploy \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}" \
  --service "${SERVICE_NAME}" \
  --yes

echo "VCP started — auto-stops after ${VCP_TTL_SECONDS}s unless you run vcp-off.sh first"
echo "Logs: railway logs --service ${SERVICE_NAME} --project ${PROJECT_ID} --lines 50"
