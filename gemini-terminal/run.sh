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
ANTIGRAVITY_SETTINGS_DIR="${ANTIGRAVITY_DIR}/antigravity-cli"
ANTIGRAVITY_SETTINGS_FILE="${ANTIGRAVITY_SETTINGS_DIR}/settings.json"
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

chmod 700 \
    "${DATA_HOME}" \
    "${CONFIG_DIR}" \
    "${CACHE_DIR}" \
    "${STATE_DIR}" \
    "${ANTIGRAVITY_DIR}"

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

mkdir -p "${ANTIGRAVITY_SETTINGS_DIR}"
chmod 700 "${ANTIGRAVITY_SETTINGS_DIR}"

log_info "Environment initialized:"
log_info "  - Home: ${HOME}"
log_info "  - Antigravity state: ${ANTIGRAVITY_DIR}"
log_info "  - ESPHome: $(esphome version)"

# Apply workspace instructions and managed permission rules matching the
# configured access level. Only rules owned by this add-on are added or removed;
# all other user settings remain unchanged.
WRITE_ACCESS=false

if [ -f /data/options.json ]; then
    WRITE_ACCESS="$(jq -r '.allow_write_access // false' /data/options.json)"
fi

if [ ! -f "${ANTIGRAVITY_SETTINGS_FILE}" ]; then
    echo '{}' >"${ANTIGRAVITY_SETTINGS_FILE}"
elif ! jq empty "${ANTIGRAVITY_SETTINGS_FILE}" >/dev/null 2>&1; then
    log_warning "Antigravity settings JSON is invalid; preserving it as settings.json.invalid."
    cp "${ANTIGRAVITY_SETTINGS_FILE}" "${ANTIGRAVITY_SETTINGS_FILE}.invalid"
    echo '{}' >"${ANTIGRAVITY_SETTINGS_FILE}"
fi

SETTINGS_TMP="$(mktemp "${ANTIGRAVITY_SETTINGS_DIR}/settings.json.XXXXXX")"

jq \
    --argjson read_only "$([ "${WRITE_ACCESS}" = "true" ] && echo false || echo true)" \
    --argjson managed_allow '[
        "command(ha-state)",
        "command(/usr/local/bin/ha-state)"
    ]' \
    --argjson managed_deny '[
        "write_file(/config)"
    ]' \
    '
        (if .agentMode == "default" then del(.agentMode) else . end)
        | .permissions = (.permissions // {})
        | .permissions.allow = (
            (((.permissions.allow // []) - $managed_allow) + $managed_allow)
            | unique
        )
        | .permissions.deny = (
            (((.permissions.deny // []) - $managed_deny)
                + (if $read_only then $managed_deny else [] end))
            | unique
        )
    ' \
    "${ANTIGRAVITY_SETTINGS_FILE}" >"${SETTINGS_TMP}"

mv "${SETTINGS_TMP}" "${ANTIGRAVITY_SETTINGS_FILE}"
chmod 600 "${ANTIGRAVITY_SETTINGS_FILE}"

if [ "${WRITE_ACCESS}" = "true" ]; then
    log_warning "WRITE ACCESS ENABLED! Antigravity may modify files after review."
    log_warning "Ensure you have a current Home Assistant backup."
    cp /GEMINI.readwrite.md /config/GEMINI.md
else
    log_info "Read-only help mode enabled; Antigravity file writes to /config are denied."
    cp /GEMINI.readonly.md /config/GEMINI.md
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
        bash -c "cd /config; echo 'Welcome to Antigravity Terminal!'; echo 'Starting Antigravity CLI...'; sleep 1; agy; exec bash"
else
    log_info "Starting the web terminal in Bash mode..."
    exec ttyd \
        --port 7682 \
        --interface 0.0.0.0 \
        --writable \
        bash -c "cd /config; echo 'Welcome to Antigravity Terminal!'; echo 'Type \"agy\" to start Antigravity or \"esphome --help\" for ESPHome.'; exec bash"
fi
