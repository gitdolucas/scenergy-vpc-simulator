#!/usr/bin/env bash
# Backward-compatible alias — bootstraps Itaim VCP service.
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/deploy-railway-itaim.sh" "$@"
