# Gemini Terminal Add-on

This add-on provides a web-based terminal with the Google Gemini CLI pre-installed, allowing you to interact with Google's Gemini AI directly from your Home Assistant dashboard.

**Note:** This add-on is **not** an official Google product.

The add‑on supports two usage modes:
1. **Help mode (default)** – you can ask Gemini for information, explanations, or guidance about your Home Assistant configuration.
2. **Agentic editing mode** – when `allow_write_access` is set to `true`, Gemini can suggest and apply changes to your Home Assistant settings and automations, always showing the proposed edits for your confirmation.

![Gemini Terminal Screenshot](screenshot.png)

## Features

-   **Web-based Terminal**: Access the Gemini CLI from any browser via Home Assistant Ingress.
-   **Persistent Authentication**: Log in once with Google, and your session is saved across restarts.
-   **Home Assistant Context**: The CLI runs with access to your `/config` directory, allowing you to easily reference your configuration files.

## Installation

1.  Add this repository to your Home Assistant Add-on Store.
2.  Install the "Gemini Terminal" add-on.
3.  Start the add-on.
4.  Click "Open Web UI" to access the terminal.

## Authentication Options

The add-on supports three authentication methods for accessing Google's Gemini AI:

### 1. OAuth (Login with Google) - **Default**
✨ **Best for**: Individual developers and anyone with a Gemini Code Assist License

**Setup**: No configuration needed - just follow the OAuth flow when you first open the terminal.

### 2. Gemini API Key
✨ **Best for**: Developers who need specific model control or paid tier access

**Setup**:
1. Get your API key from [Google AI Studio](https://aistudio.google.com/apikey)
2. In the add-on configuration, set:
   - `auth_method: api_key`
   - `gemini_api_key: YOUR_API_KEY`
3. Restart the add-on

### 3. Vertex AI
✨ **Best for**: Enterprise teams and production workloads

**Setup**:
1. Get your API key from [Google Cloud Console](https://console.cloud.google.com/)
2. In the add-on configuration, set:
   - `auth_method: vertex_ai`
   - `vertex_ai_api_key: YOUR_API_KEY`
   - `google_cloud_project: YOUR_PROJECT_ID` (optional)
3. Restart the add-on

> **Security Note**: API keys are stored in the add-on configuration. Ensure your Home Assistant instance is properly secured.

## Configuration
The add-on works out of the box with safe defaults.

### `allow_write_access` (Default: `false`)
Controls whether the Gemini AI can modify files in your Home Assistant configuration directory.
- **`false` (default)**: Read-only mode - AI can read files but cannot modify them
- **`true`**: Write mode - AI can modify files after showing you the changes and getting confirmation

### `auto_launch` (Default: `true`)
Controls whether the Gemini CLI starts automatically when you open the terminal.
- **`true` (default)**: Gemini starts immediately.
- **`false`**: The terminal opens a standard Bash shell. You can start Gemini manually by typing `gemini`.

**To enable write access:**
1. Create a backup first (Settings → System → Backups)
2. Go to the add-on's Configuration tab
3. Set `allow_write_access: true`
4. Click Save and Restart
5. Confirm in logs for: `[WARNING] WRITE ACCESS ENABLED!`

## Usage

**Authentication**: By default, this add-on uses OAuth to connect to your personal Google account. You can also configure it to use a Gemini API Key or Vertex AI (see Authentication Options above).

### OAuth Method (Default)
The authentication tokens are stored securely in the Home Assistant host under `/config/gemini_auth/` and are persisted across restarts.

1. **First Run**: Open the web UI - the Gemini CLI will prompt you to log in
2. **Authentication**: Select "Login with Google" (option 1) and follow the OAuth flow
3. **Start Chatting**: Once authenticated, ask questions
   - "Explain what this automation does"
   - "My hallway lights are not coming on when I come home, why?"
   - "Make an automation to turn the christmas tree on at 5pm"

### API Key or Vertex AI Method
If you've configured an API key, the CLI will automatically authenticate using the provided credentials - no login flow needed.

### Terminal & Tools
The add-on provides a full Bash terminal with common tools pre-installed:
- `nano`: Text editor
- `curl`: Network tool
- `git`: Version control
- `jq`: JSON processor
- `yq`: YAML processor
- `yamllint`: YAML linter
- `ripgrep` (`rg`): Fast file searcher

You can use these tools alongside Gemini to manage your configuration.

### Helper Commands
- `gemini`: Start the AI assistant
- `gemini-auth`: Check authentication status
- `gemini-logout`: Clear credentials and logout

## Troubleshooting

### Authentication Issues
If you are stuck in a login loop or need to switch accounts:
1. Run `gemini-logout` in the terminal
2. Restart the add-on (optional)
3. Run `gemini` to log in again

### "Bad Gateway" Error
If you see a 502 Bad Gateway error when opening the Web UI, it usually means the add-on is still starting up. Wait a few seconds and refresh the page.