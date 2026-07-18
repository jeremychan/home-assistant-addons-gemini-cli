# Dockerfile for Antigravity Terminal Add-on
FROM debian:trixie-slim

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG ANTIGRAVITY_VERSION=1.1.4
ARG ESPHOME_VERSION=2026.7.0
ARG TTYD_VERSION=1.7.7
ARG BUILD_ARCH
ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive

ENV AGY_CLI_DISABLE_AUTO_UPDATE=true \
    LANG=C.UTF-8

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    nano \
    curl \
    git \
    jq \
    yq \
    yamllint \
    ripgrep \
    coreutils \
    ncurses-term \
    python3 \
    python3-pip \
    python3-venv \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Install ttyd's official static release binary.
RUN ARCH="${BUILD_ARCH:-${TARGETARCH}}" \
    && case "${ARCH}" in \
        aarch64|arm64) \
            TTYD_ARCH="aarch64"; \
            TTYD_SHA256="b38acadd89d1d396a0f5649aa52c539edbad07f4bc7348b27b4f4b7219dd4165" \
            ;; \
        amd64) \
            TTYD_ARCH="x86_64"; \
            TTYD_SHA256="8a217c968aba172e0dbf3f34447218dc015bc4d5e59bf51db2f2cd12b7be4f55" \
            ;; \
        *) \
            echo "Unsupported ttyd architecture: ${ARCH}" >&2; \
            exit 1 \
            ;; \
    esac \
    && TTYD_URL="https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.${TTYD_ARCH}" \
    && curl -fsSL --retry 3 "${TTYD_URL}" -o /usr/local/bin/ttyd \
    && echo "${TTYD_SHA256}  /usr/local/bin/ttyd" | sha256sum -c - \
    && chmod 0755 /usr/local/bin/ttyd \
    && ttyd --version

# Install a pinned Antigravity release from Google's official GitHub release.
# BUILD_ARCH is supplied by the Home Assistant builder; TARGETARCH keeps local
# Docker builds convenient.
RUN ARCH="${BUILD_ARCH:-${TARGETARCH}}" \
    && case "${ARCH}" in \
        aarch64|arm64) \
            AGY_ASSET="agy_cli_linux_arm64.tar.gz"; \
            AGY_SHA256="333199327cc29e21cb8fcc4e19f7c02c462bf41dd876f1328d64e9922c631700" \
            ;; \
        amd64) \
            AGY_ASSET="agy_cli_linux_x64.tar.gz"; \
            AGY_SHA256="aaab42e395cb4e3bfe5ae88994a340865d949f7a9e7f0604ffa2a3f1e8aadbfa" \
            ;; \
        *) \
            echo "Unsupported Antigravity architecture: ${ARCH}" >&2; \
            exit 1 \
            ;; \
    esac \
    && AGY_URL="https://github.com/google-antigravity/antigravity-cli/releases/download/${ANTIGRAVITY_VERSION}/${AGY_ASSET}" \
    && curl -fsSL --retry 3 "${AGY_URL}" -o /tmp/agy.tar.gz \
    && echo "${AGY_SHA256}  /tmp/agy.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/agy.tar.gz -C /usr/local/bin antigravity \
    && mv /usr/local/bin/antigravity /usr/local/bin/agy \
    && chmod 0755 /usr/local/bin/agy \
    && agy --version \
    && rm -f /tmp/agy.tar.gz

# Install ESPHome in an isolated environment so its Python dependencies do not
# modify packages supplied by the base image.
RUN python3 -m venv /opt/esphome \
    && /opt/esphome/bin/pip install --no-cache-dir "esphome==${ESPHOME_VERSION}" \
    && ln -s /opt/esphome/bin/esphome /usr/local/bin/esphome \
    && esphome version

# Copy runtime helpers and context files.
COPY ha-state /usr/local/bin/ha-state
RUN chmod 0755 /usr/local/bin/ha-state
COPY run.sh /
RUN chmod a+x /run.sh
COPY GEMINI.readonly.md /GEMINI.readonly.md
COPY GEMINI.readwrite.md /GEMINI.readwrite.md

# Set entrypoint
CMD [ "/run.sh" ]
