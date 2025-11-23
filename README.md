# Gemini Terminal for Home Assistant

[![Add Repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fjeremychan%2Fhome-assistant-addons-gemini-cli)

A Home Assistant add-on that provides a web-based terminal with Google Gemini AI CLI, allowing you to interact with your Home Assistant configuration using natural language.

## Features

🤖 **AI-Powered Configuration Management**
- Use natural language to interact with your Home Assistant setup
- Ask questions about your configuration, automations, and integrations
- Get explanations and suggestions from Gemini AI

🔒 **Built-in Safety Controls**
- Read-only mode by default prevents accidental changes
- Explicit confirmation required for all file modifications
- Dynamic system prompts guide AI behavior

🔐 **Secure Authentication**
- One-time Google OAuth login
- Persistent authentication across restarts
- Credentials stored securely in `/config/gemini_auth/`

🌐 **Easy Access**
- Web-based interface accessible from any device
- Integrated into Home Assistant sidebar
- No additional software required

🏗️ **Multi-Architecture Support**
- Works on amd64, aarch64, and armv7 platforms
- Optimized for Raspberry Pi and x86 systems

## Quick Start

### Installation

1. **Click the button above** or manually add this repository:
   - Go to **Settings → Add-ons → Add-on Store → ⋮ (menu) → Repositories**
   - Add: `https://github.com/jeremychan/home-assistant-addons-gemini-cli`

2. **Install the add-on:**
   - Find "Gemini Terminal" in the Add-on Store
   - Click **Install**
   - Wait for the build to complete (5-10 minutes)

3. **Start using it:**
   - Enable "Show in sidebar"
   - Click **Start**
   - Click "Gemini" in your sidebar
   - Complete the one-time Google login

### First Steps

Once installed and authenticated, try asking:
- "What integrations do I have configured?"
- "Show me my automation.yaml file"
- "Explain what this automation does"
- "How many devices do I have?"

## Configuration

### Read-Only Mode (Default - Recommended)
The add-on starts in read-only mode for safety:
- ✅ AI can read your configuration files
- ❌ AI cannot modify, create, or delete files
- 🛡️ Safe for exploration and learning

### Write Mode (Advanced)
Enable write access if you want the AI to help edit files:

1. **Create a backup first!** (Settings → System → Backups)
2. Go to add-on **Configuration** tab
3. Set `allow_write_access: true`
4. Click **Save** and **Restart**

**Important:** In write mode, the AI will show you exact changes and ask for confirmation before modifying any files.

## Documentation

- [Detailed Add-on Documentation](./gemini-terminal/README.md)
- [Configuration Guide](./gemini-terminal/DOCS.md)
- [Changelog](./gemini-terminal/CHANGELOG.md)

## Safety & Privacy

- **Read-only by default**: Prevents accidental configuration changes
- **Explicit confirmation**: All file modifications require your approval
- **Local authentication**: OAuth credentials stored locally in your HA config
- **Isolated environment**: Runs in a Docker container with limited access
- **No telemetry**: No usage data is collected or sent anywhere

## Support

- 🐛 [Report a Bug](https://github.com/jeremychan/home-assistant-addons-gemini-cli/issues/new)
- 💡 [Request a Feature](https://github.com/jeremychan/home-assistant-addons-gemini-cli/issues/new)
- 💬 [Discussions](https://github.com/jeremychan/home-assistant-addons-gemini-cli/discussions)
- 📧 Email: contact@jeremychan.net

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## Acknowledgments

- Built with [ttyd](https://github.com/tsl0922/ttyd) for the web terminal
- Powered by [Google Gemini AI](https://ai.google.dev/)
- Inspired by the Home Assistant community

---

**Note:** This is an add-on (Docker container), not a custom integration. It does not appear in HACS. Users must add this repository manually to their Home Assistant add-on store.
