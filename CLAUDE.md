# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS terminal proxy configuration utility that provides a one-click solution for configuring proxy settings across terminal environments and development tools. The project addresses the issue that macOS terminals don't automatically use system proxy settings.

## Commands

### Setup and Installation
```bash
# Initial setup (run once)
source setup-proxy.sh

# Make all scripts executable
chmod +x configs/*
```

### Daily Usage Commands
After initial setup, these aliases are available in the terminal:
- `proxy-on` - Enable proxy for current terminal session
- `proxy-off` - Disable proxy for current terminal session
- `proxy-status` - Check current proxy configuration status
- `proxy-test` - Test proxy connectivity to Google

### Tool-Specific Commands
```bash
# Configure Git proxy
bash configs/gitconfig-proxy on    # Enable
bash configs/gitconfig-proxy off   # Disable

# Configure npm proxy
bash configs/npmrc-proxy on        # Enable
bash configs/npmrc-proxy off       # Disable

# Configure pip proxy
bash configs/pip-proxy on          # Enable
bash configs/pip-proxy off         # Disable
```

### Testing and Validation
```bash
# Check if proxy port is listening
lsof -i :7890

# Test proxy connectivity
curl -I https://google.com
curl -I https://github.com

# Check environment variables
echo $HTTP_PROXY
echo $HTTPS_PROXY
```

## Architecture

The project uses a modular approach with separate configuration scripts for each tool:

- **setup-proxy.sh**: Main orchestrator that runs all configurations and performs comprehensive checks
- **configs/zshrc-proxy**: Shell configuration template that adds proxy management aliases to ~/.zshrc
- **configs/gitconfig-proxy**: Manages Git's HTTP/HTTPS proxy settings via git config
- **configs/npmrc-proxy**: Configures npm proxy via npm config commands
- **configs/pip-proxy**: Sets up Python pip proxy by modifying ~/.pip/pip.conf

All scripts follow these patterns:
- Accept "on" or "off" as arguments for enabling/disabling proxy
- Use proxy server at 127.0.0.1:7890 (common proxy port)
- Add clear markers to configuration files for easy identification
- Check for existing configurations to avoid duplication
- Handle missing tools gracefully with warning messages

## Key Technical Details

- **Proxy Server**: `127.0.0.1:7890` (default port for most proxy tools)
- **Shell**: Assumes zsh (default on modern macOS)
- **NO_PROXY**: Excludes local networks, private IP ranges, and macOS-specific subnets
- **Configuration Markers**: Uses `# === macOS 终端代理配置 ===` to mark added configurations
- **Language**: All user-facing messages are in Chinese
- **Error Handling**: Scripts check for tool availability before attempting configuration

## Important Notes

- All documentation and user messages are in Chinese - maintain this convention
- Scripts are idempotent - safe to run multiple times
- The project assumes proxy software is running on port 7890
- Configuration changes are appended to existing config files, not replacing them
- Scripts use emoji indicators for status messages (🚀, ✅, ❌, ⚠️, etc.)

## User Preferences

- **Release Notes**: Keep release descriptions simple and concise, avoiding overly detailed explanations
- **Git Commits**: All commit messages should be in English following conventional commit format