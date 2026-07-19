# Antigravity Gemini Terminal Add-on for Home Assistant

This repository contains a Home Assistant add-on that exposes Google's Antigravity CLI through `ttyd`.

## Add-on structure

- `gemini-terminal/Dockerfile`: Debian image with Antigravity, ESPHome, and terminal tools
- `gemini-terminal/config.yaml`: add-on metadata, options, ingress, and mounts
- `gemini-terminal/run.sh`: persistent state setup, access-mode selection, and ttyd startup
- `gemini-terminal/GEMINI.*.md`: workspace instructions selected from `allow_write_access`

The directory and slug retain their historical Gemini names so existing installations upgrade in place.

## Local checks

```bash
bash -n gemini-terminal/run.sh
yamllint repository.yaml gemini-terminal/config.yaml
docker build -t local/antigravity-terminal ./gemini-terminal
```

For a runtime smoke test, mount temporary `/config` and `/data` directories, expose port 7682, and verify `agy --version` and `esphome version`.

## Design constraints

- Antigravity's native Linux releases support amd64 and aarch64, not armv7.
- All Antigravity state below `~/.gemini` must persist under `/data/.gemini`.
- On first launch, existing `/config/gemini_auth` contents migrate only when `/data/.gemini` is empty.
- The default access setting launches `agy --mode plan` and installs read-only workspace instructions.
- The `/config` mount remains writable to the container; plan mode is an agent safety control, not an operating-system filesystem boundary.
- Enabling writes launches Antigravity's default review mode and requires the user to review proposed edits.
- Keep the ESPHome Python installation isolated in `/opt/esphome`.
