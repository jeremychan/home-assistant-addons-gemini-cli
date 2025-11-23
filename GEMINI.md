# Gemini Terminal Add-on for Home Assistant

## Overview
This project aims to create a Home Assistant add-on that provides a web-based terminal interface for the Google Gemini CLI. It leverages `ttyd` to expose the terminal over the web and integrates with Home Assistant's authentication and ingress system.

## Development Environment

### Setup
A development environment using Nix is not yet set up for this project. The following manual commands can be used for now.

### Core Development Commands
- `build-addon` - Build the Gemini Terminal add-on with Podman
- `run-addon` - Run add-on locally on port 7681 with volume mapping
- `lint-dockerfile` - Lint Dockerfile using hadolint
- `test-endpoint` - Test web endpoint availability (curl localhost:7681)

### Manual Commands (without aliases)
```bash
# Build
podman build --build-arg BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.19 -t local/gemini-terminal ./gemini-terminal

# Run locally
podman run -p 7681:7681 -v $(pwd)/config:/config local/gemini-terminal

# Lint
hadolint ./gemini-terminal/Dockerfile

# Test endpoint
curl -X GET http://localhost:7681/
```

## Architecture

### Add-on Structure (gemini-terminal/)
- **config.yaml** - Home Assistant add-on configuration (multi-arch, ingress, ports)
- **Dockerfile** - Alpine-based container with Node.js and Gemini CLI
- **build.yaml** - Multi-architecture build configuration (amd64, aarch64, armv7)
- **run.sh** - Main startup script with credential management and ttyd terminal
- **scripts/** - Modular credential management scripts

### Key Components
1. **Web Terminal**: Uses ttyd to provide browser-based terminal access
2. **Credential Management**: Persistent authentication storage in `/config/gemini_auth/`
3. **Service Integration**: Home Assistant ingress support with panel icon
4. **Multi-Architecture**: Supports amd64, aarch64, armv7 platforms

## Implementation and Testing Plan

This project will be implemented in three main phases.

### Phase 1: Basic Add-on & OAuth Implementation (Status: Mostly Complete)

**Goal:** Establish a minimal, installable Home Assistant add-on that starts, runs `ttyd`, and provides a persistent, authenticated Gemini CLI session using OAuth.

**Implementation Steps:**
1.  **Finalize `Dockerfile`:** Ensure `ttyd`, `nodejs`, `npm`, and the `@google/gemini-cli` package are installed correctly on an Alpine base image. (Done)
2.  **Update `run.sh`:** The script's primary role will be to ensure authentication persistence. (Done)
    *   It will create a directory at `/config/gemini_auth`.
    *   It will then create a symbolic link from the container's home directory for Gemini configuration (`/root/.gemini`) to the persistent `/config/gemini_auth` directory.
    *   Finally, it will launch `ttyd` with the `gemini` command to start the CLI directly.
3.  **Simplify `config.yaml`:** Remove all authentication options. Since we only support OAuth, no user-configurable options are needed for authentication. The add-on will work out-of-the-box. (Done)

**Testing Steps:**
1.  **Local Build & Run:**
    *   Build the Docker image (`docker build .`) and run it locally, mapping a local test directory to `/config`.
    *   `docker run -p 7681:7681 -v ./test-config:/config local/gemini-terminal`
2.  **Initial OAuth Login:**
    *   Access the web terminal at `http://localhost:7681`. It should present the Gemini CLI interface.
    *   Select the "Login with Google" option and complete the authentication in your browser.
    *   **Verification:** The CLI should become authenticated. Check your local `./test-config/gemini_auth` directory. The files `oauth_creds.json` and `google_accounts.json` should now exist.
3.  **Persistence Test:**
    *   Stop and restart the Docker container, keeping the same mapped volume.
    *   Access the web terminal again.
    *   **Verification:** The Gemini CLI should be immediately authenticated without requiring you to log in again.
4.  **Home Assistant Installation Test:**
    *   Install the add-on in a live Home Assistant instance.
    *   Perform the initial login flow.
    *   Restart the add-on from the Home Assistant UI.
    *   **Verification:** Confirm that the authentication is persisted across restarts.

---

### Phase 2: Finalization, Documentation & Polish

**Goal:** Clean up the codebase, refine all documentation for clarity, and ensure the add-on is robust and user-friendly.

**Implementation Steps:**
1.  **Finalize Documentation:** Review and update `README.md`, the add-on's description in `config.yaml`, and this `GEMINI.md` file to ensure they are clear, accurate, and reflect the OAuth-only approach.
2.  **Robust Environment Setup (Best Practice):**
    *   Update `run.sh` to use `/data` for the environment (HOME, XDG_CONFIG_HOME, etc.) instead of relying on `/root`. This ensures all addon state (caches, logs, etc.) is persisted correctly and follows HA best practices.
    *   Set `HOME=/data/home`, `XDG_CONFIG_HOME=/data/.config`, etc.
    *   Continue to symlink the specific auth directory to `/config/gemini_auth` if user visibility is desired, or keep it in `/data` for safety. (Decision: Keep in `/config/gemini_auth` for now for transparency).
3.  **Code Cleanup:** Add comments to `run.sh` to clearly explain the environment setup and linking.
4.  **Multi-Architecture Build:** Finalize the `build.yaml` file to ensure correct builds for `amd64`, `aarch64`, and `armv7`.

**Testing Steps:**
1.  **Multi-Architecture Build Test:** Trigger builds for all supported architectures to catch any platform-specific issues.
2.  **End-to-End User Testing:** Perform a full test cycle as a new user would: add the repository, install the add-on, complete the one-time authentication, and use the CLI.
3.  **Documentation Review:** Read all documentation from the perspective of a new user to check for clarity, accuracy, and completeness.

---

### Phase 3: Advanced Integration and Safety

**Goal:** Deeply integrate the Gemini CLI with the user's Home Assistant environment by providing configuration as context, and implement critical safety features to prevent accidental damage.

**Implementation Plan:**

1.  **Provide Home Assistant Context:**
    *   The add-on's `config.yaml` will be updated to map the user's Home Assistant `config` directory into the container. This directory will be available inside the add-on at `/config`.
    *   **Correction:** Ensure `working_dir` in `config.yaml` is set to `/config` (not `/ha-config`) so the CLI starts in the correct context.
    *   The `run.sh` script should verify it is in `/config` or `cd /config` before starting the CLI.

2.  **Implement Dynamic System Prompt:**
    *   Two system prompt files will be created: `GEMINI.readonly.md` and `GEMINI.readwrite.md`.
    *   `GEMINI.readonly.md` will instruct the AI that it has read-only access and **MUST NOT** use any tools to modify files, and should inform the user of its status if asked to make changes.
    *   `GEMINI.readwrite.md` will instruct the AI that it has write access, but it **MUST** confirm all file modifications with the user before proceeding.
    *   The `Dockerfile` will be updated to copy both of these files into the container's root directory (or `/opt`).

3.  **Implement Safety Feature (`allow_write_access`):**
    *   A new boolean option, `allow_write_access`, will be added to `config.yaml`, defaulting to `false`.
    *   The `run.sh` script will check this value at startup.
    *   If `false`, the script will copy `GEMINI.readonly.md` to `/config/GEMINI.md` and log a message informing the user that the add-on is in a safe, read-only mode.
    *   If `true`, the script will copy `GEMINI.readwrite.md` to `/config/GEMINI.md` and log a prominent warning about the risks of enabling write access and recommend that the user has backups.

**Testing Plan:**

1.  **Read-Only Mode Test:**
    *   With `allow_write_access: false` (the default), start the add-on.
    *   **Verification:** Check the logs to confirm the "read-only mode" message is present. In the CLI, ask the AI to describe a file (e.g., `/config/configuration.yaml`). It should succeed. Then, ask the AI to add a comment to the same file. It should refuse and state that it is in read-only mode.

2.  **Read-Write Mode Test:**
    *   Set `allow_write_access: true` in the add-on configuration and restart.
    *   **Verification:** Check the logs to confirm the "risk warning" message is present. In the CLI, ask the AI to add a comment to `/config/configuration.yaml`. It should respond by stating the exact change it wants to make and ask for confirmation.

3.  **Context Awareness Test:**
    *   In either mode, ask the AI questions about your Home Assistant setup (e.g., "How many automations do I have?" or "What integrations are defined in my configuration.yaml?").
    *   **Verification:** The AI should be able to answer these questions by referencing the files within `/config`, demonstrating that it is using the environment as context.
