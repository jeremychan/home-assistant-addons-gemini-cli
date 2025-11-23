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

# --- Start ttyd ---
bashio::log.info "Starting ttyd web terminal with Gemini CLI..."
# ttyd will launch the gemini command, which will prompt for login on the first run.
# On subsequent runs, it will use the credentials stored in the linked directory.
/usr/bin/ttyd --writable -p 7681 gemini
