#!/usr/bin/env bash
# Backward-compatible alias — starts Itaim VCP (2 connectors).
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/vcp-on-itaim.sh" "$@"
