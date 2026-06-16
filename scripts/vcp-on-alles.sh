#!/usr/bin/env bash
set -euo pipefail

export RAILWAY_SERVICE_NAME="${RAILWAY_SERVICE_NAME:-scenergy-vpc-alles}"
export CP_ID="${CP_ID:-b2222222-2222-4222-b222-222222222222}"
export VCP_ENTRY="${VCP_ENTRY:-index_16.ts}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/railway-env.sh
source "${SCRIPT_DIR}/railway-env.sh"

REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Starting Alles Park VCP on ${SERVICE_NAME} (TTL ~$((VCP_TTL_SECONDS / 60)) min, CP_ID=${CP_ID})..."

railway up \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}" \
  --service "${SERVICE_NAME}" \
  --path-as-root "${REPO_ROOT}" \
  --detach \
  --yes \
  --message "vcp-on-alles session start"

echo "Alles VCP deploy started — auto-stops after ${VCP_TTL_SECONDS}s unless you run vcp-off.sh first"
echo "Logs: railway logs --service ${SERVICE_NAME} --project ${PROJECT_ID} --lines 50"
