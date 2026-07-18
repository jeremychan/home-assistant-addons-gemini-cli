# Antigravity/Gemini Terminal Add-on

This add-on provides a Home Assistant Ingress terminal with Google's [Antigravity CLI](https://github.com/google-antigravity/antigravity-cli). It retains the Gemini Terminal name so existing users can find the migrated add-on.

This community add-on is not an official Google product.

## Installation

1. Add this repository to the Home Assistant Add-on Store.
2. Install **Antigravity/Gemini Terminal**.
3. Start the add-on.
4. Select **Open Web UI**.
5. Follow the Google sign-in URL shown by Antigravity.

Google currently publishes Antigravity CLI builds for 64-bit Linux only. The add-on therefore supports `amd64` and `aarch64`, but not `armv7`.

## Configuration

### `allow_write_access`

Default: `false`

- `false`: Antigravity starts in plan mode and receives workspace instructions that prohibit file changes.
- `true`: Antigravity starts in its default review mode and may propose edits. Review changes carefully and keep current Home Assistant backups.

The Home Assistant `/config` mount is writable inside the terminal in both modes. The setting controls Antigravity's behavior; it is not an operating-system filesystem sandbox. A user at the Bash prompt can still edit files directly.

### `auto_launch`

Default: `true`

- `true`: Open Antigravity automatically when the terminal loads.
- `false`: Open a Bash shell. Run `agy` to start Antigravity.

## Authentication and persistence

Antigravity uses Google Sign-In. In a remote terminal it displays a URL that you can open in another browser.

Credentials, settings, projects, and conversations are stored in the add-on's persistent `/data/.gemini` directory. Upgrades from the Gemini CLI version copy existing `/config/gemini_auth` state on first start when the new state directory is empty.

Use Antigravity's `/logout` command to sign out.

## ESPHome

The `esphome` command is available in the terminal. It can access ESPHome YAML files mounted below `/config`.

Examples:

```bash
esphome config /config/esphome/living-room.yaml
esphome compile /config/esphome/living-room.yaml
esphome logs /config/esphome/living-room.yaml
```

Compilation downloads platform toolchains on first use and can take several minutes. OTA upload and logs require the target device to be reachable from the add-on. USB flashing is not enabled by this add-on.

## Included tools

- `agy`: Antigravity CLI
- `esphome`: ESPHome CLI
- `nano`: text editor
- `curl`: HTTP client
- `git`: version control
- `jq`: JSON processor
- `yq`: YAML processor
- `yamllint`: YAML linter
- `rg`: fast text search

## Troubleshooting

### Antigravity does not start

Disable `auto_launch`, restart the add-on, open the web terminal, and run:

```bash
command -v agy
agy --version
```

### Sign-in repeats after restart

Check the add-on log for the `Antigravity state: /data/.gemini` message. Run `/logout` inside Antigravity and complete Google Sign-In again.

### 502 Bad Gateway

The add-on may still be starting. Wait a few seconds and refresh the page. If it persists, inspect the add-on log for the first startup error.
