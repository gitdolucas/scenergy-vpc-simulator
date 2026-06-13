# scenergy-vpc-simulator

Ephemeral **OCPP 1.6 Virtual Charge Point** for [SC Energy](https://github.com/gitdolucas/scenergy). Connects to production `scenergy-api` as the demo station **SC Energy Itaim** and shuts down automatically to save Railway compute.

## What this is

| Role | Service |
| ---- | ------- |
| Central System (CSMS) | `scenergy-api` on Railway |
| Charge point (this repo) | Simulated hardware over WebSocket |

This is **not** an OCPP server — it is a charge-point client that talks to the backend at:

```text
wss://scenergy-api-production.up.railway.app/ocpp/a1111111-1111-4111-a111-111111111111
```

While running, the mobile app can start/stop real OCPP charging sessions against the demo connectors (`SCIT-5123-01`, etc.). When idle, the charge point is offline and the API returns `OCPP_UNREACHABLE`.

## Lifecycle

| State | Compute cost | How |
| ----- | -------------- | --- |
| **Idle** | None | Default — no active deployment |
| **Running** | Billed | `./scripts/vcp-on.sh` |
| **Auto off** | None | Container exits after **30 min** (`VCP_TTL_SECONDS=1800`) |
| **Manual off** | None | `./scripts/vcp-off.sh` |

```bash
./scripts/vcp-on.sh    # start a fresh ~30 min session
./scripts/vcp-off.sh   # stop immediately
```

## One-time setup

### Prerequisites

- [Railway CLI](https://docs.railway.com/cli): `npm i -g @railway/cli && railway login`
- Access to Railway project `e3b38292-35ba-4fa8-8bc3-000a43fa06d2`
- Backend deployed with stable demo charge point ID (see scenergy-backend `prisma/demo-charge-point.ts`)

### Bootstrap Railway service

```bash
chmod +x scripts/*.sh
./scripts/deploy-railway.sh
./scripts/vcp-off.sh   # optional: leave idle after first deploy
```

Connect GitHub repo in Railway dashboard for future deploys, or keep using `vcp-on.sh` (redeploy) as the primary trigger.

## Environment variables

| Variable | Default | Description |
| -------- | ------- | ----------- |
| `WS_URL` | `wss://scenergy-api-production.up.railway.app/ocpp` | CSMS WebSocket base (VCP appends `/${CP_ID}`) |
| `CP_ID` | `a1111111-1111-4111-a111-111111111111` | Must match backend seed |
| `VCP_TTL_SECONDS` | `1800` | Session length before auto shutdown |
| `ADMIN_PORT` / `PORT` | `9999` | Health check + admin API |

Copy [`.env.example`](.env.example) for local reference; production values are set on Railway.

## Verify

1. `./scripts/vcp-on.sh`
2. `railway logs --service scenergy-vpc-simulator --lines 50`
   - Expect: WebSocket connected, `BootNotification` Accepted, heartbeats
3. API logs: `Charge point connected: a1111111-...`
4. Mobile (`FLAVOR=prod`): login `demo@scenergy.dev`, start charging at **SC Energy Itaim**
5. After TTL or `vcp-off.sh`, charging via OCPP should fail (expected)

## Admin API (while running)

```bash
railway run --service scenergy-vpc-simulator curl -s http://localhost:9999/health
```

See [ocpp-virtual-charge-point](https://github.com/solidstudiosh/ocpp-virtual-charge-point) for `POST /execute` actions.

## Local development

Point at local backend:

```bash
export WS_URL=ws://localhost:3000/ocpp
export CP_ID=a1111111-1111-4111-a111-111111111111
export VCP_TTL_SECONDS=3600
docker build -t scenergy-vpc .
docker run --rm -e WS_URL -e CP_ID -e VCP_TTL_SECONDS scenergy-vpc
```

## Upstream

Built on [solidstudiosh/ocpp-virtual-charge-point](https://github.com/solidstudiosh/ocpp-virtual-charge-point) (pinned in `Dockerfile` `VCP_REF`).
