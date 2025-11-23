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

No configuration is required for basic usage.

### Options

-   `allow_write_access` (optional): Set to `true` to allow the AI to modify files in your `/config` directory. **Use with caution.** Default is `false`.

## Usage

1.  **First Run**: When you open the web UI for the first time, the Gemini CLI will prompt you to log in.
2.  **Authentication**:
    -   Select "Login with Google".
    -   Follow the link provided or copy the code to your browser to authorize the application.
3.  **Chatting**: Once authenticated, you can start chatting with Gemini immediately.
    -   Example: `gemini "What is in my configuration.yaml?"`
    -   Interactive mode: Type `gemini` to enter an interactive session.

## Safety

By default, the add-on runs in a mode that discourages file modifications. If you enable `allow_write_access`, ensure you have backups of your Home Assistant configuration.
