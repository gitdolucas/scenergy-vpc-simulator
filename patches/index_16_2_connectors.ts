require("dotenv").config();

import { OcppVersion } from "./src/ocppVersion";
import { registerVcp } from "./src/close";
import { bootNotificationOcppMessage } from "./src/v16/messages/bootNotification";
import { statusNotificationOcppMessage } from "./src/v16/messages/statusNotification";
import { VCP } from "./src/vcp";

// Patched for scenergy-vpc-simulator: the upstream 2-connector entry never
// calls registerVcp(), so AUTO_RESTART (start:auto-restart) can't find a main
// factory after a WS drop and dies with "Main function not found for VCP".
// Wrapping in main() + registerVcp lets the in-process auto-restart reconnect.
async function main(): Promise<VCP> {
  const vcp = new VCP({
    endpoint: process.env.WS_URL ?? "ws://localhost:3000",
    chargePointId: process.env.CP_ID ?? "123456",
    ocppVersion: OcppVersion.OCPP_1_6,
    basicAuthPassword: process.env.PASSWORD ?? undefined,
    adminPort: Number.parseInt(process.env.ADMIN_PORT ?? "9999"),
  });
  await vcp.connect();
  vcp.send(
    bootNotificationOcppMessage.request({
      chargePointVendor: "Solidstudio",
      chargePointModel: "VirtualChargePoint",
      chargePointSerialNumber: "S001",
      firmwareVersion: "1.0.0",
    }),
  );
  vcp.send(
    statusNotificationOcppMessage.request({
      connectorId: 1,
      errorCode: "NoError",
      status: "Available",
    }),
  );
  vcp.send(
    statusNotificationOcppMessage.request({
      connectorId: 2,
      errorCode: "NoError",
      status: "Available",
    }),
  );
  return vcp;
}

main().then((vcp) => registerVcp(vcp, main));
