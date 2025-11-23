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

# --- Configure Authentication Method ---
# Determine which authentication method to use
AUTH_METHOD="oauth"

if [ -f /data/options.json ]; then
    # Local testing mode - read from options.json
    AUTH_METHOD=$(jq -r '.auth_method // "oauth"' /data/options.json)
elif bashio::config.exists 'auth_method'; then
    # Home Assistant mode - use supervisor API
    AUTH_METHOD=$(bashio::config 'auth_method')
fi

bashio::log.info "Authentication method: ${AUTH_METHOD}"

case "${AUTH_METHOD}" in
    "api_key")
        # Gemini API Key authentication
        if [ -f /data/options.json ]; then
            API_KEY=$(jq -r '.gemini_api_key // ""' /data/options.json)
        else
            API_KEY=$(bashio::config 'gemini_api_key')
        fi
        
        if [ -n "${API_KEY}" ]; then
            export GEMINI_API_KEY="${API_KEY}"
            bashio::log.info "Using Gemini API Key authentication"
        else
            bashio::log.error "API Key authentication selected but no gemini_api_key provided!"
        fi
        ;;
    
    "vertex_ai")
        # Vertex AI authentication
        if [ -f /data/options.json ]; then
            GOOGLE_KEY=$(jq -r '.vertex_ai_api_key // ""' /data/options.json)
            GCP_PROJECT=$(jq -r '.google_cloud_project // ""' /data/options.json)
        else
            GOOGLE_KEY=$(bashio::config 'vertex_ai_api_key')
            GCP_PROJECT=$(bashio::config 'google_cloud_project')
        fi
        
        if [ -n "${GOOGLE_KEY}" ]; then
            export GOOGLE_API_KEY="${GOOGLE_KEY}"
            export GOOGLE_GENAI_USE_VERTEXAI=true
            bashio::log.info "Using Vertex AI authentication"
            
            if [ -n "${GCP_PROJECT}" ]; then
                export GOOGLE_CLOUD_PROJECT="${GCP_PROJECT}"
                bashio::log.info "Google Cloud Project: ${GCP_PROJECT}"
            fi
        else
            bashio::log.error "Vertex AI authentication selected but no vertex_ai_api_key provided!"
        fi
        ;;
    
    "oauth"|*)
        # OAuth authentication (default)
        bashio::log.info "Using OAuth authentication (Login with Google)"
        ;;
esac

# --- Configure Safety & System Prompt ---
# Determine write access mode
# Priority: 1) /data/options.json (for local testing), 2) bashio config (for HA)
WRITE_ACCESS=false

if [ -f /data/options.json ]; then
    # Local testing mode - read from options.json
    WRITE_ACCESS=$(jq -r '.allow_write_access // false' /data/options.json)
    bashio::log.info "Local mode: allow_write_access=${WRITE_ACCESS}"
elif bashio::config.true 'allow_write_access'; then
    # Home Assistant mode - use supervisor API
    WRITE_ACCESS=true
fi

if [ "$WRITE_ACCESS" = "true" ]; then
    bashio::log.warning "WRITE ACCESS ENABLED! The AI has permission to modify files."
    bashio::log.warning "Ensure you have backups of your configuration."
    cp /GEMINI.readwrite.md /config/GEMINI.md
else
    bashio::log.info "Read-only mode enabled (default). The AI cannot modify files."
    cp /GEMINI.readonly.md /config/GEMINI.md
fi

# Create a wrapper script for gemini-auth
cat > /usr/local/bin/gemini-auth <<EOF
#!/bin/bash
echo "Checking Gemini authentication status..."
if [ -n "\$GEMINI_API_KEY" ]; then
    echo "✅ Authenticated (API Key)"
elif [ -n "\$GOOGLE_API_KEY" ] && [ "\$GOOGLE_GENAI_USE_VERTEXAI" = "true" ]; then
    echo "✅ Authenticated (Vertex AI)"
elif [ -f "\$HOME/.gemini/oauth_creds.json" ]; then
    echo "✅ Authenticated (OAuth - Credentials found)"
    ls -l "\$HOME/.gemini/oauth_creds.json"
else
    echo "❌ Not authenticated"
fi
EOF
chmod +x /usr/local/bin/gemini-auth

# Create a wrapper script for gemini-logout
cat > /usr/local/bin/gemini-logout <<EOF
#!/bin/bash
echo "Logging out of Gemini..."
rm -f "\$HOME/.gemini/oauth_creds.json"
rm -f "\$HOME/.gemini/google_accounts.json"
echo "✅ Credentials cleared. Run 'gemini' to login again."
EOF
chmod +x /usr/local/bin/gemini-logout

# --- Start ttyd ---
bashio::log.info "Starting ttyd web terminal..."

# Determine launch command
AUTO_LAUNCH=true

if [ -f /data/options.json ]; then
    # Local testing mode - read from options.json
    AUTO_LAUNCH=$(jq -r '.auto_launch // true' /data/options.json)
elif bashio::config.exists 'auto_launch'; then
    # Home Assistant mode
    AUTO_LAUNCH=$(bashio::config 'auto_launch')
fi

LAUNCH_CMD=""

if [ "$AUTO_LAUNCH" = "true" ]; then
    bashio::log.info "Auto-launch enabled: Gemini CLI will start automatically."
    # We use a small delay to ensure the terminal is ready
    LAUNCH_CMD="echo 'Welcome to Gemini Terminal!' && echo 'Starting Gemini CLI...' && sleep 1 && gemini"
else
    bashio::log.info "Auto-launch disabled: Starting in Bash shell."
    LAUNCH_CMD="echo 'Welcome to Gemini Terminal!' && echo 'Type \"gemini\" to start the AI assistant.'"
fi

# ttyd configuration for Home Assistant ingress
# We run bash, which then executes the launch command
exec ttyd \
    --port 7682 \
    --interface 0.0.0.0 \
    --writable \
    bash -c "cd /config && $LAUNCH_CMD; exec bash"
