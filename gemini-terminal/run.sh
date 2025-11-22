#!/usr/bin/with-contenv bashio

# ==============================================================================
# Pre-start script for the Gemini Terminal add-on
# ==============================================================================

# --- Read configuration ---
AUTH_METHOD=$(bashio::config 'auth.method')

# --- Configure authentication ---
bashio::log.info "Configuring authentication method: ${AUTH_METHOD}"

if [ "${AUTH_METHOD}" == "oauth" ]; then
  bashio::log.info "Using OAuth 2.0 for authentication. Persisting credentials in /config/gemini_auth."
  GEMINI_AUTH_DIR="/config/gemini_auth"
  mkdir -p "${GEMINI_AUTH_DIR}"
  # Symlink the gemini config directory to the persistent storage
  ln -sfn "${GEMINI_AUTH_DIR}" "/root/.gemini"
else
  # Unset any OAuth credentials if another method is chosen
  rm -rf /root/.gemini
fi

case "${AUTH_METHOD}" in
  "gemini_api_key")
    GEMINI_API_KEY=$(bashio::config 'auth.gemini_api_key')
    if [ -n "${GEMINI_API_KEY}" ]; then
      export GEMINI_API_KEY
      bashio::log.info "Using Gemini API Key for authentication."
    else
      bashio::log.warning "Gemini API Key is not set. Authentication might fail."
    fi
    ;;
  "vertex_ai_service_account")
    VERTEX_PROJECT_ID=$(bashio::config 'auth.vertex_ai_project_id')
    VERTEX_LOCATION=$(bashio::config 'auth.vertex_ai_location')
    VERTEX_SERVICE_ACCOUNT_JSON=$(bashio::config 'auth.vertex_ai_service_account_json')
    if [ -n "${VERTEX_SERVICE_ACCOUNT_JSON}" ] && [ -n "${VERTEX_PROJECT_ID}" ] && [ -n "${VERTEX_LOCATION}" ]; then
      SERVICE_ACCOUNT_FILE="/tmp/service_account.json"
      echo "${VERTEX_SERVICE_ACCOUNT_JSON}" > "${SERVICE_ACCOUNT_FILE}"
      chmod 600 "${SERVICE_ACCOUNT_FILE}"
      export GOOGLE_APPLICATION_CREDENTIALS="${SERVICE_ACCOUNT_FILE}"
      export GOOGLE_CLOUD_PROJECT="${VERTEX_PROJECT_ID}"
      export GOOGLE_CLOUD_LOCATION="${VERTEX_LOCATION}"
      bashio::log.info "Using Vertex AI Service Account for authentication."
    else
      bashio::log.warning "Vertex AI Service Account details are not fully set. Authentication might fail."
    fi
    ;;
  "vertex_ai_api_key")
    VERTEX_PROJECT_ID=$(bashio::config 'auth.vertex_ai_project_id')
    VERTEX_LOCATION=$(bashio::config 'auth.vertex_ai_location')
    VERTEX_API_KEY=$(bashio::config 'auth.vertex_ai_api_key')
    if [ -n "${VERTEX_API_KEY}" ] && [ -n "${VERTEX_PROJECT_ID}" ] && [ -n "${VERTEX_LOCATION}" ]; then
      export GOOGLE_API_KEY="${VERTEX_API_KEY}"
      export GOOGLE_GENAI_USE_VERTEXAI=true
      export GOOGLE_CLOUD_PROJECT="${VERTEX_PROJECT_ID}"
      export GOOGLE_CLOUD_LOCATION="${VERTEX_LOCATION}"
      bashio::log.info "Using Vertex AI API Key for authentication."
    else
      bashio::log.warning "Vertex AI API Key details are not fully set. Authentication might fail."
    fi
    ;;
  "oauth")
    # OAuth is handled by the symlink, no environment variables needed
    :
    ;;
  *)
    bashio::log.warning "Unknown authentication method: ${AUTH_METHOD}. No authentication will be configured."
    ;;
esac

# --- Start ttyd ---
bashio::log.info "Starting ttyd web terminal with Gemini CLI..."
# Now we can start gemini directly
/usr/bin/ttyd -p 7681 gemini