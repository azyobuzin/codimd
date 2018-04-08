# Based on https://github.com/hackmdio/docker-hackmd/blob/e112e088f3815c469a45b2fd9fc2a2ba6ff1e9a1/debian/Dockerfile

FROM node:8.11.1

# Set some default config variables
ENV DEBIAN_FRONTEND noninteractive
ENV NODE_ENV=production

RUN adduser --uid 10000 --home /hackmd/ --disabled-password --system hackmd

COPY --chown=hackmd:root . /hackmd

WORKDIR /hackmd

RUN apt-get update && \
    apt-get install -y build-essential sudo && \
    sudo -EHu hackmd sh -c "\
        yarn install --pure-lockfile && \
        yarn install --production=false --pure-lockfile && \
        npm run build && \
        yarn cache clean" && \
    SUDO_FORCE_REMOVE=yes apt-get remove -y --auto-remove build-essential sudo && \
    apt-get clean && apt-get purge && rm -r /var/lib/apt/lists/*

EXPOSE 3000
USER hackmd

ENTRYPOINT ["/hackmd/docker-entrypoint.sh"]
