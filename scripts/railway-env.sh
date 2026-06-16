# Shared Railway defaults for lifecycle scripts.
PROJECT_ID="${RAILWAY_PROJECT_ID:-e3b38292-35ba-4fa8-8bc3-000a43fa06d2}"
SERVICE_NAME="${RAILWAY_SERVICE_NAME:-scenergy-vpc-itaim}"
ENVIRONMENT="${RAILWAY_ENVIRONMENT:-production}"
VCP_TTL_SECONDS="${VCP_TTL_SECONDS:-1800}"

if ! command -v railway &>/dev/null; then
  echo "Install Railway CLI: npm i -g @railway/cli && railway login"
  exit 1
fi

railway link \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}" \
  --service "${SERVICE_NAME}" \
  --json >/dev/null 2>&1 || true
