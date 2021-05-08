FROM node:14 AS base

ENV DEBIAN_FRONTEND=noninteractive \
    NODE_ENV=production

# -------------------------

FROM base AS builder

COPY . /hackmd

RUN cd /hackmd && \
    yarn install --production=false --pure-lockfile --silent --non-interactive && \
    yarn run build && \
    rm -rf node_modules && \
    yarn install --production=true --pure-lockfile --silent --non-interactive

# -------------------------

FROM base

RUN apt-get update -q && \
    apt-get install -qy fonts-noto && \
    rm -r /var/lib/apt/lists/*

ARG UID=10000
RUN adduser --uid $UID --home /hackmd/ --disabled-password --system hackmd && \
    mkdir /db && chown hackmd /db

COPY --chown=$UID --from=builder /hackmd /hackmd
WORKDIR /hackmd

EXPOSE 3000
USER hackmd

ENTRYPOINT ["node", "app.js"]
