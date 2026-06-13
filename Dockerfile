FROM node:22-alpine

ARG VCP_REF=b32a57ccb5ce793cab2b8bc9bb9d6e26cc7d780a

RUN apk add --no-cache git bash

WORKDIR /app

RUN git clone https://github.com/solidstudiosh/ocpp-virtual-charge-point.git . \
    && git fetch --depth 1 origin "${VCP_REF}" \
    && git checkout "${VCP_REF}"

RUN npm ci

COPY scripts/run-with-ttl.sh /usr/local/bin/run-with-ttl.sh
RUN chmod +x /usr/local/bin/run-with-ttl.sh

ENV ADMIN_PORT=9999
ENV VCP_TTL_SECONDS=1800

EXPOSE 9999

CMD ["/usr/local/bin/run-with-ttl.sh"]
