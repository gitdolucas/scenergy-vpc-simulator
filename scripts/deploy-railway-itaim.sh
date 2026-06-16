#!/usr/bin/env bash
set -euo pipefail

export RAILWAY_SERVICE_NAME="${RAILWAY_SERVICE_NAME:-scenergy-vpc-itaim}"
export WS_URL="${WS_URL:-wss://scenergy-api-production.up.railway.app/ocpp}"
export CP_ID="${CP_ID:-a1111111-1111-4111-a111-111111111111}"
export VCP_ENTRY="${VCP_ENTRY:-index_16_2_connectors.ts}"
export VCP_TTL_SECONDS="${VCP_TTL_SECONDS:-1800}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/railway-env.sh
source "${SCRIPT_DIR}/railway-env.sh"

echo "Linking project ${PROJECT_ID} / environment ${ENVIRONMENT} / service ${SERVICE_NAME}..."
railway link \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}" \
  --service "${SERVICE_NAME}" \
  --json >/dev/null 2>&1 || railway add --service "${SERVICE_NAME}" --json

railway link \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}" \
  --service "${SERVICE_NAME}" \
  --json >/dev/null

echo "Setting environment variables for Itaim (2 connectors)..."
railway variable set \
  WS_URL="${WS_URL}" \
  CP_ID="${CP_ID}" \
  VCP_ENTRY="${VCP_ENTRY}" \
  VCP_TTL_SECONDS="${VCP_TTL_SECONDS}" \
  ADMIN_PORT=9999 \
  PORT=9999 \
  --service "${SERVICE_NAME}" \
  --environment "${ENVIRONMENT}" \
  --project "${PROJECT_ID}"

REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
echo "Deploying from ${REPO_ROOT}..."
railway up \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}" \
  --service "${SERVICE_NAME}" \
  --path-as-root "${REPO_ROOT}" \
  --detach \
  --yes \
  --message "bootstrap scenergy-vpc-itaim"

echo ""
echo "Itaim VCP bootstrap complete. Start a session: ./scripts/vcp-on-itaim.sh"
echo "Stop immediately: RAILWAY_SERVICE_NAME=${SERVICE_NAME} ./scripts/vcp-off.sh"
