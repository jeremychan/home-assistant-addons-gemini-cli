# Antigravity CLI Add-on

[![Add Repository](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fjeremychan%2Fhome-assistant-addons-gemini-cli)

Run Google's [Antigravity CLI](https://github.com/google-antigravity/antigravity-cli) in a web terminal from the Home Assistant dashboard. The add-on opens in `/config`, includes ESPHome and common command-line tools, and keeps Antigravity authentication and session data across restarts.

This community add-on is not an official Google or ESPHome product.

## Features

- Antigravity's interactive terminal UI, launched with `agy`
- Home Assistant Ingress web terminal
- Persistent Google sign-in, settings, projects, and conversation history
- Read-only help mode by default
- Optional reviewed file editing
- ESPHome CLI for validating, compiling, uploading, and reading device logs
- `nano`, `curl`, `git`, `jq`, `yq`, `yamllint`, and `rg`

## Installation

1. Add this repository to the Home Assistant Add-on Store.
2. Install **Antigravity Terminal**.
3. Start the add-on and select **Open Web UI**.
4. Follow the displayed Google sign-in URL on first launch.

Antigravity provides native 64-bit Linux builds, so this release supports `amd64` and `aarch64`.

See the [add-on documentation](gemini-terminal/README.md) for configuration, ESPHome examples, and troubleshooting.
