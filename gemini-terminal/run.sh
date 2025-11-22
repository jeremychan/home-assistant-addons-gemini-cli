#!/usr/bin/with-contenv bashio

# ==============================================================================
# Pre-start script for the Gemini Terminal add-on
# ==============================================================================

# --- Configure OAuth persistence ---
bashio::log.info "Configuring persistent storage for OAuth credentials..."
GEMINI_AUTH_DIR="/config/gemini_auth"
mkdir -p "${GEMINI_AUTH_DIR}"

# Symlink the gemini config directory from the root user's home to the persistent storage.
# This ensures that credentials from the "Login with Google" flow are saved across restarts.
ln -sfn "${GEMINI_AUTH_DIR}" "/root/.gemini"
bashio::log.info "OAuth credentials will be persisted in ${GEMINI_AUTH_DIR}."

# --- Start ttyd ---
bashio::log.info "Starting ttyd web terminal with Gemini CLI..."
# ttyd will launch the gemini command, which will prompt for login on the first run.
# On subsequent runs, it will use the credentials stored in the linked /root/.gemini directory.
/usr/bin/ttyd -p 7681 gemini
