# Based on https://github.com/hackmdio/docker-hackmd/blob/e112e088f3815c469a45b2fd9fc2a2ba6ff1e9a1/debian/Dockerfile

FROM node:8

ENV DEBIAN_FRONTEND=noninteractive \
    NODE_ENV=production

RUN adduser --uid 10000 --home /hackmd/ --disabled-password --system hackmd && \
    mkdir /db && chown hackmd /db

COPY . /hackmd

WORKDIR /hackmd

RUN apt-get update -q && \
    apt-get install -q -y build-essential && \
    yarn install --pure-lockfile --silent && \
    yarn install --production=false --pure-lockfile --silent && \
    npm run build && \
    yarn cache clean && \
    chown -R hackmd ./ && \
    apt-get remove -q -y --auto-remove build-essential && \
    apt-get clean -q && apt-get purge -q && rm -r /var/lib/apt/lists/*

EXPOSE 3000
USER hackmd

ENTRYPOINT ["/hackmd/docker-entrypoint.sh"]
