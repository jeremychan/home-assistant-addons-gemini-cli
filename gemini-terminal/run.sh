#!/usr/bin/env bash

# ==============================================================================
# Pre-start script for the Antigravity Terminal add-on
# ==============================================================================

set -Eeuo pipefail

DATA_HOME="/data/home"
CONFIG_DIR="/data/.config"
CACHE_DIR="/data/.cache"
STATE_DIR="/data/.local/state"
ANTIGRAVITY_DIR="/data/.gemini"
LEGACY_GEMINI_DIR="/config/gemini_auth"

log_info() {
    echo "[INFO] $*"
}

log_warning() {
    echo "[WARNING] $*" >&2
}

log_info "Initializing Antigravity Terminal environment..."

mkdir -p \
    "${DATA_HOME}" \
    "${CONFIG_DIR}" \
    "${CACHE_DIR}" \
    "${STATE_DIR}" \
    "${ANTIGRAVITY_DIR}"

chmod 700 "${DATA_HOME}" "${CONFIG_DIR}" "${CACHE_DIR}" "${STATE_DIR}" "${ANTIGRAVITY_DIR}"

export HOME="${DATA_HOME}"
export XDG_CONFIG_HOME="${CONFIG_DIR}"
export XDG_CACHE_HOME="${CACHE_DIR}"
export XDG_STATE_HOME="${STATE_DIR}"
export SHELL="/bin/bash"
export TERM="${TERM:-xterm-256color}"
export PATH="/usr/local/bin:/opt/esphome/bin:${PATH}"

# ttyd is a remote terminal but is not SSH. Antigravity uses the standard SSH
# variables to choose its copyable URL + authorization-code sign-in flow.
export SSH_CONNECTION="${SSH_CONNECTION:-ttyd 0 ttyd 0}"
export SSH_TTY="${SSH_TTY:-/dev/pts/0}"

# Antigravity stores credentials, settings, projects, and conversations below
# ~/.gemini. Keep that complete directory in the add-on's persistent /data area.
if [ -d "${LEGACY_GEMINI_DIR}" ] \
    && [ -z "$(find "${ANTIGRAVITY_DIR}" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
    log_info "Migrating saved Gemini state to Antigravity storage..."
    cp -a "${LEGACY_GEMINI_DIR}/." "${ANTIGRAVITY_DIR}/"
fi

ln -sfn "${ANTIGRAVITY_DIR}" "${HOME}/.gemini"

log_info "Environment initialized:"
log_info "  - Home: ${HOME}"
log_info "  - Antigravity state: ${ANTIGRAVITY_DIR}"
log_info "  - ESPHome: $(esphome version)"

# Apply a workspace instruction file matching the configured access level.
WRITE_ACCESS=false

if [ -f /data/options.json ]; then
    WRITE_ACCESS="$(jq -r '.allow_write_access // false' /data/options.json)"
fi

if [ "${WRITE_ACCESS}" = "true" ]; then
    log_warning "WRITE ACCESS ENABLED! Antigravity may modify files after review."
    log_warning "Ensure you have a current Home Assistant backup."
    cp /GEMINI.readwrite.md /config/GEMINI.md
    AGY_MODE="default"
else
    log_info "Read-only help mode enabled; Antigravity will start in plan mode."
    cp /GEMINI.readonly.md /config/GEMINI.md
    AGY_MODE="plan"
fi

AUTO_LAUNCH=true

if [ -f /data/options.json ]; then
    AUTO_LAUNCH="$(jq -r 'if has("auto_launch") then .auto_launch else true end' /data/options.json)"
fi

if [ "${AUTO_LAUNCH}" = "true" ]; then
    log_info "Starting the web terminal with Antigravity CLI..."
    exec ttyd \
        --port 7682 \
        --interface 0.0.0.0 \
        --writable \
        bash -c "cd /config; echo 'Welcome to Antigravity Terminal!'; echo 'Starting Antigravity CLI...'; sleep 1; agy --mode=${AGY_MODE}; exec bash"
else
    log_info "Starting the web terminal in Bash mode..."
    exec ttyd \
        --port 7682 \
        --interface 0.0.0.0 \
        --writable \
        bash -c "cd /config; echo 'Welcome to Antigravity Terminal!'; echo 'Type \"agy\" to start Antigravity or \"esphome --help\" for ESPHome.'; exec bash"
fi
