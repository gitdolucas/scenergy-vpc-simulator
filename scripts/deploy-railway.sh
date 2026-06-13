#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/railway-env.sh
source "${SCRIPT_DIR}/railway-env.sh"

WS_URL="${WS_URL:-wss://scenergy-api-production.up.railway.app/ocpp}"
CP_ID="${CP_ID:-a1111111-1111-4111-a111-111111111111}"
VCP_TTL_SECONDS="${VCP_TTL_SECONDS:-1800}"

echo "Linking project ${PROJECT_ID} / environment ${ENVIRONMENT} / service ${SERVICE_NAME}..."
railway link \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}" \
  --service "${SERVICE_NAME}" \
  --json >/dev/null

echo "Setting environment variables..."
railway variable set \
  WS_URL="${WS_URL}" \
  CP_ID="${CP_ID}" \
  VCP_TTL_SECONDS="${VCP_TTL_SECONDS}" \
  ADMIN_PORT=9999 \
  PORT=9999 \
  --service "${SERVICE_NAME}" \
  --environment "${ENVIRONMENT}" \
  --project "${PROJECT_ID}"

echo "Deploying from $(pwd)..."
railway up \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}" \
  --service "${SERVICE_NAME}" \
  --detach

echo ""
echo "Bootstrap complete. To leave idle immediately:"
echo "  ./scripts/vcp-off.sh"
echo ""
echo "To start a session later:"
echo "  ./scripts/vcp-on.sh"
