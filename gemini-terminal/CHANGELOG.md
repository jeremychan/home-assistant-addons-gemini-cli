# Changelog

All notable changes to the Gemini Terminal add-on will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-11-23

### Fixed
- Removed port mapping from config.yaml to fix "Port 7681 already in use" error
- Add-on now uses ingress exclusively for web access (no port conflicts)

### Changed
- Enhanced README with comprehensive `allow_write_access` documentation
- Added detailed example interactions for read-only and write modes
- Added troubleshooting section to README
- Improved root README with "Add Repository" button for easy installation
- Converted SVG icon to PNG format (icon.png 256x256, logo.png 512x512)
- Clarified that this is an add-on, not a HACS integration

### Documentation
- Added step-by-step guide for enabling write access
- Added safety best practices section
- Added "What the AI Can Access" section
- Added example conversations showing AI behavior in both modes

## [1.0.0] - 2025-11-23

### Added
- Initial release of Gemini Terminal add-on
- Web-based terminal interface using ttyd
- Google Gemini CLI integration with OAuth authentication
- Persistent authentication storage in `/config/gemini_auth/`
- Multi-architecture support (amd64, aarch64, armv7)
- Home Assistant ingress integration
- Sidebar panel for easy access
- Safety controls with read-only mode by default
- Dynamic system prompts based on `allow_write_access` setting
- Read-only mode: AI cannot modify files
- Read-write mode: AI must confirm all file modifications
- Robust environment setup using `/data` for persistence
- Local testing support via `/data/options.json`
- Home Assistant configuration context for AI interactions

### Security
- Read-only mode enabled by default to prevent accidental configuration changes
- Explicit user confirmation required for all file modifications in read-write mode
- OAuth-based authentication for secure Google account access
