# scenergy-vpc-simulator

Ephemeral **OCPP 1.6 Virtual Charge Point** simulators for [SC Energy](https://github.com/gitdolucas/scenergy). Two Railway services connect to production `scenergy-api` and shut down automatically to save compute.

## Stations

| Railway service | Station | CP_ID | VCP entry |
| --------------- | ------- | ----- | --------- |
| `scenergy-vpc-itaim` | SC Energy Itaim (2× 150 kW) | `a1111111-1111-4111-a111-111111111111` | `index_16_2_connectors.ts` |
| `scenergy-vpc-alles` | SC Energy Alles Park (40 kW) | `b2222222-2222-4222-b222-222222222222` | `index_16.ts` |

WebSocket URLs:

```text
wss://scenergy-api-production.up.railway.app/ocpp/a1111111-1111-4111-a111-111111111111
wss://scenergy-api-production.up.railway.app/ocpp/b2222222-2222-4222-b222-222222222222
```

While a VCP is running, the mobile app can start/stop real OCPP sessions on that station. When idle, the charge point is offline and the API returns `OCPP_UNREACHABLE`.

## Lifecycle

| State | Compute cost | How |
| ----- | -------------- | --- |
| **Idle** | None | Default — no active deployment |
| **Running** | Billed | `./scripts/vcp-on-all.sh` (both) or per-station scripts below |
| **Auto off** | None | Container exits after **30 min** (`VCP_TTL_SECONDS=1800`) |
| **Manual off** | None | `./scripts/vcp-off-all.sh` or per-station `vcp-off.sh` |

```bash
./scripts/vcp-on-all.sh      # both stations (~30 min each)
./scripts/vcp-off-all.sh     # stop both immediately

./scripts/vcp-on-itaim.sh    # Itaim only
./scripts/vcp-on-alles.sh    # Alles Park only
RAILWAY_SERVICE_NAME=scenergy-vpc-itaim ./scripts/vcp-off.sh   # stop one
```

`vcp-on-*` runs `railway up` (fresh Docker build). Avoid `railway redeploy` — it reuses a stale image and fails after `vcp-off` removed the deployment.

**Railway services:** only `scenergy-vpc-itaim` and `scenergy-vpc-alles`. The legacy `scenergy-vpc-simulator` service was removed — use Itaim instead.

## One-time setup

### Prerequisites

- [Railway CLI](https://docs.railway.com/cli): `npm i -g @railway/cli && railway login`
- Access to Railway project `e3b38292-35ba-4fa8-8bc3-000a43fa06d2`
- Backend deployed with stable charge point IDs (see `scenergy-backend/prisma/demo-charge-point.ts`)

### Bootstrap Railway services

```bash
chmod +x scripts/*.sh
./scripts/deploy-railway-itaim.sh
./scripts/deploy-railway-alles.sh
RAILWAY_SERVICE_NAME=scenergy-vpc-itaim ./scripts/vcp-off.sh   # optional: leave idle
```

Aliases: `deploy-railway.sh` → Itaim bootstrap, `vcp-on.sh` → Itaim only.

## Environment variables

| Variable | Itaim default | Alles default | Description |
| -------- | ------------- | ------------- | ----------- |
| `WS_URL` | `wss://scenergy-api-production.up.railway.app/ocpp` | same | CSMS WebSocket base (VCP appends `/${CP_ID}`) |
| `CP_ID` | `a1111111-...` | `b2222222-...` | Must match backend seed |
| `VCP_ENTRY` | `index_16_2_connectors.ts` | `index_16.ts` | Patched VCP entry script |
| `VCP_TTL_SECONDS` | `1800` | `1800` | Session length before auto shutdown |
| `ADMIN_PORT` / `PORT` | `9999` | `9999` | Health check + admin API |

Copy [`.env.example`](.env.example) for local reference.

## Verify

1. `./scripts/vcp-on-all.sh`
2. `railway logs --service scenergy-vpc-itaim --lines 50` — BootNotification Accepted
3. `railway logs --service scenergy-vpc-alles --lines 50` — same for Alles
4. Mobile (`FLAVOR=prod`): start charging at **SC Energy Itaim** or **SC Energy Alles Park**
5. `./scripts/vcp-off-all.sh` when done

## Local development

```bash
export WS_URL=ws://localhost:3000/ocpp
export CP_ID=a1111111-1111-4111-a111-111111111111
export VCP_ENTRY=index_16_2_connectors.ts
docker build -t scenergy-vpc-itaim .
docker run --rm -e WS_URL -e CP_ID -e VCP_ENTRY -e VCP_TTL_SECONDS=3600 scenergy-vpc-itaim
```

## Upstream

Built on [solidstudiosh/ocpp-virtual-charge-point](https://github.com/solidstudiosh/ocpp-virtual-charge-point) (pinned in `Dockerfile` `VCP_REF`).
