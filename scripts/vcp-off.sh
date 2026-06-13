#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/railway-env.sh
source "${SCRIPT_DIR}/railway-env.sh"

echo "Stopping VCP on ${SERVICE_NAME}..."
railway down \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}" \
  --service "${SERVICE_NAME}" \
  --yes

echo "VCP stopped — no compute running"
