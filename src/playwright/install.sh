#!/bin/sh
set -e

export DEBIAN_FRONTEND=noninteractive
export DOCKER_IMAGE_NAME_TEMPLATE="mcr.microsoft.com/playwright:v%version%-jammy"

export LANG=C.UTF-8
export LC_ALL=C.UTF-8

echo "Installing Node.js"

apt-get update
# Install Node.js
apt-get install -y curl wget gpg ca-certificates
mkdir -p /etc/apt/keyrings
curl -sL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" >> /etc/apt/sources.list.d/nodesource.list
apt-get update
apt-get install -y nodejs
# Feature-parity with node.js base images.
apt-get install -y --no-install-recommends git openssh-client
npm install -g yarn
# clean apt cache
rm -rf /var/lib/apt/lists/*


echo "Installing browsers"

export PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
echo "export PLAYWRIGHT_BROWSERS_PATH=/ms-playwright" >> /etc/bash.bashrc

mkdir /ms-playwright
mkdir /ms-playwright-agent
cd /ms-playwright-agent && npm init -y
npm i playwright
chown -R $_REMOTE_USER:$_REMOTE_USER ./node_modules
npm exec --no -- playwright-core mark-docker-image "${DOCKER_IMAGE_NAME_TEMPLATE}"
npm exec --no -- playwright-core install --with-deps && rm -rf /var/lib/apt/lists/*
# Workaround for https://github.com/microsoft/playwright/issues/27313
# While the gstreamer plugin load process can be in-process, it ended up throwing
# an error that it can't have libsoup2 and libsoup3 in the same process because
# libgstwebrtc is linked against libsoup2. So we just remove the plugin.
if [ "$(uname -m)" = "aarch64" ]; then \
    rm /usr/lib/aarch64-linux-gnu/gstreamer-1.0/libgstwebrtc.so; \
else \
    rm /usr/lib/x86_64-linux-gnu/gstreamer-1.0/libgstwebrtc.so; \
fi
rm -rf /ms-playwright-agent
rm -rf ~/.npm/
chmod -R 777 /ms-playwright