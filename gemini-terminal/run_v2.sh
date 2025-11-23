#!/usr/bin/with-contenv bashio

# ==============================================================================
# Pre-start script for the Gemini Terminal add-on
# ==============================================================================

# --- Configure Environment (HA Best Practice) ---
# Use /data exclusively - guaranteed writable by HA Supervisor
DATA_HOME="/data/home"
CONFIG_DIR="/data/.config"
CACHE_DIR="/data/.cache"
STATE_DIR="/data/.local/state"
GEMINI_AUTH_DIR="/config/gemini_auth"

bashio::log.info "Initializing Gemini Terminal environment in /data..."

# Create all required directories
mkdir -p "${DATA_HOME}" "${CONFIG_DIR}" "${CACHE_DIR}" "${STATE_DIR}" "${GEMINI_AUTH_DIR}"

# Set permissions
chmod 755 "${DATA_HOME}" "${CONFIG_DIR}" "${CACHE_DIR}" "${STATE_DIR}"

# Set XDG and application environment variables
export HOME="${DATA_HOME}"
export XDG_CONFIG_HOME="${CONFIG_DIR}"
export XDG_CACHE_HOME="${CACHE_DIR}"
export XDG_STATE_HOME="${STATE_DIR}"

bashio::log.info "Environment initialized:"
bashio::log.info "  - Home: ${HOME}"
bashio::log.info "  - Config: ${XDG_CONFIG_HOME}"

# --- Configure OAuth persistence ---
bashio::log.info "Configuring persistent storage for OAuth credentials..."

# Symlink the gemini config directory from the new HOME to the persistent storage.
# This ensures that credentials from the "Login with Google" flow are saved across restarts.
# The Gemini CLI uses ~/.gemini by default (or XDG_CONFIG_HOME/gemini depending on version, 
# but usually ~/.gemini or ~/.config/google-gemini-cli). 
# We will link ~/.gemini just in case, and also check if we need to link inside .config.
# Based on common node CLI behavior, it might use ~/.config/google-gemini-cli or similar.
# However, the previous implementation used /root/.gemini, so we assume ~/.gemini is the target.

ln -sfn "${GEMINI_AUTH_DIR}" "${HOME}/.gemini"
bashio::log.info "OAuth credentials will be persisted in ${GEMINI_AUTH_DIR} linked to ${HOME}/.gemini."

# --- Configure Safety & System Prompt ---
# Check if allow_write_access is true.
# We check bashio first (standard HA), but fallback to checking options.json directly
# to support local development where the Supervisor API is not available.
if [ -f /data/options.json ]; then
    bashio::log.info "DEBUG: /data/options.json found"
    cat /data/options.json
    bashio::log.info "DEBUG: jq output: $(jq -r '.allow_write_access' /data/options.json)"
else
    bashio::log.info "DEBUG: /data/options.json NOT found"
fi

if bashio::config.true 'allow_write_access' || \
   ( [ -f /data/options.json ] && [ "$(jq -r '.allow_write_access' /data/options.json)" == "true" ] ); then
    bashio::log.warning "WRITE ACCESS ENABLED! The AI has permission to modify files."
    bashio::log.warning "Ensure you have backups of your configuration."
    cp /GEMINI.readwrite.md /config/GEMINI.md
else
    bashio::log.info "Read-only mode enabled (default). The AI cannot modify files."
    cp /GEMINI.readonly.md /config/GEMINI.md
fi

# --- Start ttyd ---
bashio::log.info "Starting ttyd web terminal with Gemini CLI..."
# ttyd will launch the gemini command, which will prompt for login on the first run.
# On subsequent runs, it will use the credentials stored in the linked directory.
/usr/bin/ttyd --writable -p 7682 gemini
