#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting both VCPs (Itaim + Alles Park)..."

"${SCRIPT_DIR}/vcp-on-itaim.sh"
"${SCRIPT_DIR}/vcp-on-alles.sh"

echo ""
echo "Both VCP sessions started — auto-stop after ~30 min unless you run ./scripts/vcp-off-all.sh"
