#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for service in scenergy-vpc-itaim scenergy-vpc-alles; do
  RAILWAY_SERVICE_NAME="${service}" "${SCRIPT_DIR}/vcp-off.sh"
done

echo "All VCPs stopped — no compute running"
