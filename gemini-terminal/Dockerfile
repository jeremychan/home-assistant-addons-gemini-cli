# Dockerfile for Gemini Terminal Add-on
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.19
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set up arguments
ARG BUILD_ARCH

# Install dependencies
RUN apk add --no-cache \
    nodejs \
    npm \
    ttyd \
    nano \
    curl \
    git \
    jq \
    yq \
    yamllint \
    ripgrep

# Install Gemini CLI with retry logic
RUN npm config set registry https://registry.npmjs.org/ \
    && npm config set fetch-retries 3 \
    && npm config set fetch-retry-mintimeout 20000 \
    && npm config set fetch-retry-maxtimeout 120000 \
    && npm config set fetch-timeout 300000 \
    && for i in 1 2 3; do \
    echo "Attempt $i: Installing Gemini CLI..." && \
    npm install -g @google/gemini-cli && \
    echo "Successfully installed Gemini CLI" && \
    break || \
    (echo "Attempt $i failed, retrying in 10 seconds..." && sleep 10); \
    done \
    && npm cache clean --force

# Copy run script and context files
COPY run.sh /
RUN chmod a+x /run.sh
COPY GEMINI.readonly.md /GEMINI.readonly.md
COPY GEMINI.readwrite.md /GEMINI.readwrite.md

# Set entrypoint
CMD [ "/run.sh" ]
