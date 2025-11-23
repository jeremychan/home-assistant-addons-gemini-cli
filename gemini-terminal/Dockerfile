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
    ttyd

# Install Gemini CLI
RUN npm install -g @google/gemini-cli

# Copy run script and context files
COPY run.sh /
RUN chmod a+x /run.sh
COPY GEMINI.readonly.md /GEMINI.readonly.md
COPY GEMINI.readwrite.md /GEMINI.readwrite.md

# Set entrypoint
CMD [ "/run.sh" ]
