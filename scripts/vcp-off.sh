#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/railway-env.sh
source "${SCRIPT_DIR}/railway-env.sh"

echo "Stopping VCP on ${SERVICE_NAME}..."

if ! railway down \
  --project "${PROJECT_ID}" \
  --environment "${ENVIRONMENT}" \
  --service "${SERVICE_NAME}" \
  --yes 2>&1; then
  echo "VCP already idle (no active deployment)"
  exit 0
fi

echo "VCP stopped — no compute running"
