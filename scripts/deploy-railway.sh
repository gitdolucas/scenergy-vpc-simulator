#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${RAILWAY_PROJECT_ID:-e3b38292-35ba-4fa8-8bc3-000a43fa06d2}"
SERVICE_NAME="${RAILWAY_SERVICE_NAME:-scenergy-vpc-simulator}"
ENVIRONMENT="${RAILWAY_ENVIRONMENT:-production}"
WS_URL="${WS_URL:-wss://scenergy-api-production.up.railway.app/ocpp}"
CP_ID="${CP_ID:-a1111111-1111-4111-a111-111111111111}"
VCP_TTL_SECONDS="${VCP_TTL_SECONDS:-1800}"

export RAILWAY_CALLER="${RAILWAY_CALLER:-scenergy-vpc-simulator@deploy}"
export RAILWAY_AGENT_SESSION="${RAILWAY_AGENT_SESSION:-vpc-simulator-deploy-$(date +%s)-$$}"

if ! command -v railway &>/dev/null; then
  echo "Install Railway CLI: npm i -g @railway/cli"
  exit 1
fi

echo "Linking project ${PROJECT_ID} / environment ${ENVIRONMENT}..."
railway link \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}" \
  --json >/dev/null

echo "Ensuring ${SERVICE_NAME} service exists..."
if ! railway service list \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}" \
  --json | jq -e --arg n "${SERVICE_NAME}" '.[] | select(.name == $n)' >/dev/null 2>&1; then
  railway add --service "${SERVICE_NAME}" --project "${PROJECT_ID}" --json
fi

echo "Setting environment variables..."
railway variable set \
  WS_URL="${WS_URL}" \
  CP_ID="${CP_ID}" \
  VCP_TTL_SECONDS="${VCP_TTL_SECONDS}" \
  ADMIN_PORT=9999 \
  PORT=9999 \
  --service "${SERVICE_NAME}" \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}"

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
