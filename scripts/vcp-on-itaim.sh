#!/usr/bin/env bash
set -euo pipefail

export RAILWAY_SERVICE_NAME="${RAILWAY_SERVICE_NAME:-scenergy-vpc-itaim}"
export CP_ID="${CP_ID:-a1111111-1111-4111-a111-111111111111}"
export VCP_ENTRY="${VCP_ENTRY:-index_16_2_connectors.ts}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/railway-env.sh
source "${SCRIPT_DIR}/railway-env.sh"

REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Starting Itaim VCP on ${SERVICE_NAME} (TTL ~$((VCP_TTL_SECONDS / 60)) min, CP_ID=${CP_ID})..."

railway up \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}" \
  --service "${SERVICE_NAME}" \
  --path-as-root "${REPO_ROOT}" \
  --detach \
  --yes \
  --message "vcp-on-itaim session start"

echo "Itaim VCP deploy started — auto-stops after ${VCP_TTL_SECONDS}s unless you run vcp-off.sh first"
echo "Logs: railway logs --service ${SERVICE_NAME} --project ${PROJECT_ID} --lines 50"
