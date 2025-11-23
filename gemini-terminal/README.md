# Gemini Terminal Add-on

This add-on provides a web-based terminal with the Google Gemini CLI pre-installed, allowing you to interact with Google's Gemini AI directly from your Home Assistant dashboard.

## Features

-   **Web-based Terminal**: Access the Gemini CLI from any browser via Home Assistant Ingress.
-   **Persistent Authentication**: Log in once with Google, and your session is saved across restarts.
-   **Home Assistant Context**: The CLI runs with access to your `/config` directory, allowing you to easily reference your configuration files.

## Installation

1.  Add this repository to your Home Assistant Add-on Store.
2.  Install the "Gemini Terminal" add-on.
3.  Start the add-on.
4.  Click "Open Web UI" to access the terminal.

## Configuration

### Basic Setup (No Configuration Required)

The add-on works out of the box with safe defaults. Simply install, start, and use.

### Advanced Configuration Options

#### `allow_write_access` (Default: `false`)

**⚠️ IMPORTANT SAFETY SETTING**

This option controls whether the Gemini AI can modify files in your Home Assistant configuration directory.

**Default Behavior (Recommended):**
- `allow_write_access: false` (Read-Only Mode)
- The AI can **read** your configuration files
- The AI **cannot** create, modify, or delete files
- If you ask the AI to make changes, it will refuse and explain it's in read-only mode

**How to Enable Write Access:**

1. **Create a Backup First!**
   - Go to **Settings → System → Backups**
   - Click **Create Backup**
   - Wait for completion

2. **Enable Write Access:**
   - Go to the add-on's **Configuration** tab
   - Change `allow_write_access: false` to `allow_write_access: true`
   - Click **Save**

3. **Restart the Add-on:**
   - Go to the **Info** tab
   - Click **Restart**

4. **Verify in Logs:**
   - Go to the **Log** tab
   - Look for: `[WARNING] WRITE ACCESS ENABLED! The AI has permission to modify files.`

**Write Mode Behavior:**
- The AI **can** modify files when you ask
- The AI **must** show you the exact changes and ask for confirmation first
- Always review changes carefully before confirming

**When to Use Write Access:**
- You want the AI to help edit your configuration files
- You're comfortable reviewing and approving changes
- You have recent backups

**When NOT to Use Write Access:**
- You're just exploring or learning
- You don't have backups
- You're not sure what changes the AI might make

## Usage

1.  **First Run**: When you open the web UI for the first time, the Gemini CLI will prompt you to log in.
2.  **Authentication**:
    -   Select "Login with Google" (option 1)
    -   Follow the link provided or copy the code to your browser to authorize the application
    -   Your authentication will be saved and persist across restarts
3.  **Chatting**: Once authenticated, you can start chatting with Gemini immediately
    -   Example: "What integrations do I have configured?"
    -   Example: "Show me my automation.yaml file"
    -   Example: "Explain what this automation does" (paste automation YAML)

### Example Interactions

**Read-Only Mode (Default):**
```
You: Can you show me my configuration.yaml?
AI: [displays your configuration.yaml file]

You: Can you add a comment to my configuration.yaml?
AI: I'm currently in read-only mode and cannot modify files. 
    To enable write access, set allow_write_access: true in 
    the add-on configuration.
```

**Write Mode (allow_write_access: true):**
```
You: Can you add a comment "# Updated by Gemini" to the top of my configuration.yaml?
AI: I can help you with that. Here's the change I'll make:

    File: /config/configuration.yaml
    Change: Add "# Updated by Gemini" as the first line

    Current first line:
    homeassistant:

    After change:
    # Updated by Gemini
    homeassistant:

    Do you want me to proceed with this change? (yes/no)

You: yes
AI: [makes the change] Done! I've added the comment to your configuration.yaml.
```

## Safety

### Built-in Safety Features

1. **Read-Only by Default**: The add-on starts in read-only mode to prevent accidental changes
2. **Explicit Confirmation**: In write mode, the AI must show you changes and get approval
3. **Persistent Authentication**: OAuth credentials are stored securely in `/config/gemini_auth/`
4. **Isolated Environment**: The add-on runs in a Docker container with limited access

### Best Practices

- ✅ **Always have backups** before enabling write access
- ✅ **Review all changes** carefully before confirming
- ✅ **Test in read-only mode** first to understand how the AI interprets your requests
- ✅ **Start with small changes** when using write mode
- ⚠️ **Disable write access** when not actively using it
- ⚠️ **Never blindly approve** changes without reviewing them

### What the AI Can Access

**With Read Access (Default):**
- ✅ Read all files in `/config` directory
- ✅ View your configuration, automations, scripts, etc.
- ✅ Answer questions about your setup
- ❌ Cannot modify, create, or delete files

**With Write Access (allow_write_access: true):**
- ✅ Everything from read access, plus:
- ✅ Modify existing files (with your confirmation)
- ✅ Create new files (with your confirmation)
- ✅ Delete files (with your confirmation)

## Troubleshooting

### Port Conflict Error
If you see "Port 7681 is already in use":
- This should not happen with ingress enabled
- If it does, another add-on may be using the same port
- The add-on uses ingress and doesn't need port 7681 exposed

### Authentication Not Persisting
- Check logs for `/config/gemini_auth` directory creation
- Verify the add-on has write access to `/config`
- Try restarting the add-on

### AI Not Respecting Read-Only Mode
- Verify logs show "Read-only mode enabled"
- Check that `allow_write_access: false` in Configuration
- The system prompt should be copied to `/config/GEMINI.md`

## Support

- 🐛 [Report Issues](https://github.com/jeremychan/home-assistant-addons-gemini-cli/issues)
- 💬 [Discussions](https://github.com/jeremychan/home-assistant-addons-gemini-cli/discussions)
- 📧 Email: contact@jeremychan.net

