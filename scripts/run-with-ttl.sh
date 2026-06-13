#!/bin/sh
set -eu

TTL="${VCP_TTL_SECONDS:-1800}"
echo "VCP session starting; TTL=${TTL}s ($((TTL / 60)) min)"

npm run start:auto-restart -- index_16_2_connectors.ts &
VCP_PID=$!

cleanup() {
  echo "VCP session ending — sending SIGTERM to pid ${VCP_PID}"
  kill -TERM "$VCP_PID" 2>/dev/null || true
  wait "$VCP_PID" 2>/dev/null || true
}

trap cleanup INT TERM

(
  remaining="$TTL"
  while [ "$remaining" -gt 0 ]; do
    sleep 300
    remaining=$((remaining - 300))
    if [ "$remaining" -gt 0 ]; then
      echo "VCP session active — ${remaining}s remaining (~$((remaining / 60)) min)"
    fi
  done
) &
COUNTDOWN_PID=$!

sleep "$TTL"
kill "$COUNTDOWN_PID" 2>/dev/null || true
wait "$COUNTDOWN_PID" 2>/dev/null || true

cleanup
echo "VCP TTL elapsed — exiting to stop Railway compute"
exit 0
