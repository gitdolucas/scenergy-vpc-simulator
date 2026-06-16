#!/bin/sh
set -eu

TTL="${VCP_TTL_SECONDS:-1800}"
ENTRY="${VCP_ENTRY:-index_16_2_connectors.ts}"
echo "VCP session starting; TTL=${TTL}s ($((TTL / 60)) min) entry=${ENTRY}"

# Start admin/health listener before OCPP connect so Railway healthcheck can pass
# while the charge point negotiates BootNotification with the CSMS.
npm run start:auto-restart -- "${ENTRY}" &
VCP_PID=$!

cleanup() {
  echo "VCP session ending — sending SIGTERM to pid ${VCP_PID}"
  kill -TERM "$VCP_PID" 2>/dev/null || true
  wait "$VCP_PID" 2>/dev/null || true
}

trap cleanup INT TERM

# Give the VCP admin HTTP server time to bind before the platform probes /health.
sleep 5

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
