# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS terminal proxy configuration utility that provides a one-click solution for configuring proxy settings across terminal environments and development tools. The project addresses the issue that macOS terminals don't automatically use system proxy settings.

## Commands

### Setup and Installation
```bash
# Initial setup (default SAFE: off, just installs aliases)
./setproxy.sh off

# Enable with tools (example)
./setproxy.sh on --with git,npm,pip

# Compatibility shim
source setup-proxy.sh   # forwards to setproxy.sh
```

### Daily Usage Commands (aliases map to setproxy)
- `proxy-on [--with ...|--all]`  – Persist on + set current env
- `proxy-off [--with ...|--all]` – Persist off + unset current env; tools only if specified
- `proxy-status` – Show persisted state (zshrc) and current env
- `proxy-test` – Basic connectivity test under current state

### Tool-Specific Commands
Use the unified switch:
```bash
./setproxy.sh on  --with git,npm      # enable tools + core
./setproxy.sh off --with git,npm      # disable tools + core off
./setproxy.sh on  --all               # core + all tools (git/npm/pip/go/docker/cargo)
```

### Testing and Validation
```bash
./setproxy.sh status
./setproxy.sh test
./test.sh            # dry-run sanity checks
```

## Architecture

The project uses a modular approach with separate configuration scripts for each tool:

- **setproxy.sh**: Primary CLI (on/off/status/test, handles zshrc marker + tool scripts)
- **setup-proxy.sh**: Compatibility shim forwarding to setproxy.sh
- **configs/zshrc-proxy**: Loads aliases in ~/.zshrc, dispatching to setproxy.sh
- **configs/*-proxy**: Tool-specific toggles (git/npm/pip/go/docker/cargo)

Principles:
- Default safe: `setproxy.sh off` (no exports, no tool changes) is the baseline.
- Use proxy server 127.0.0.1:PORT (default 7890; flag/env overrides).
- Marked zshrc block `# BEGIN setproxy` ... `# END setproxy`, rewritten on on/off.
- Missing tools are tolerated with warnings; scripts are idempotent.

## Key Technical Details

- **Proxy Server**: `127.0.0.1:7890` by default; override via `--port` or `SETPROXY_PORT`.
- **Shell**: Assumes zsh (default on modern macOS).
- **NO_PROXY**: Local + RFC1918 ranges (see setproxy.sh for list).
- **Configuration Markers**: `# BEGIN setproxy` / `# END setproxy` in ~/.zshrc.
- **Language**: User-facing messages in Chinese.
- **Error Handling**: Checks tool availability; `--force` for non-interactive overwrite; dry-run supported.

## Important Notes

- All documentation and user messages are in Chinese - maintain this convention
- Scripts are idempotent - safe to run multiple times
- The project assumes proxy software is running on port 7890
- Configuration changes are appended to existing config files, not replacing them
- Scripts use emoji indicators for status messages (🚀, ✅, ❌, ⚠️, etc.)

## User Preferences

- **Release Notes**: Keep release descriptions simple and concise, avoiding overly detailed explanations
- **Git Commits**: All commit messages should be in English following conventional commit format
