# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing configuration files for a macOS development environment. The configurations are organized following the XDG Base Directory Specification under `.config/`.

## Key Configuration Architecture

### Neovim Setup
- **Primary config**: `nvim/init.lua` - Based on Kickstart.nvim template
- **Architecture**: Modular Lua-based configuration with plugin management
- **Key features**: LSP integration, Treesitter, Telescope fuzzy finding, custom keymaps
- **Plugin management**: Uses built-in package manager (likely Packer or Lazy.nvim)

### Terminal & Shell Environment
- **Terminal**: WezTerm with adaptive theming (`wezterm/wezterm.lua`)
- **Shell**: Zsh with Oh-My-Zsh plugins, using Starship prompt instead of Powerlevel10k
- **Theme system**: Dynamic light/dark mode switching via `toggle_theme.sh`

### Development Environment
- **Node.js**: NVM with lazy loading optimization
- **Go**: GOPATH configured, binaries in PATH
- **Package managers**: Homebrew, Yarn (global packages)
- **Tools**: Mason binaries for Neovim LSPs, tmux configuration

## Theme System Architecture

The repository implements a unified theming system:
- `toggle_theme.sh`: Central theme switcher that updates multiple applications
- `TERM_BACKGROUND` environment variable controls light/dark mode
- EZA_COLORS and LS_COLORS dynamically configured based on theme
- WezTerm automatically adapts colors based on system appearance
- Neovim receives theme change signals via SIGUSR1

## Common Commands

### Neovim Plugin Management
```bash
# Install/update plugins
nvim +PackerSync
# OR if using Lazy.nvim
nvim +Lazy sync

# Check health
nvim +checkhealth
```

### Theme Management
```bash
# Toggle between light/dark themes
source ~/.config/toggle_theme.sh

# Set specific theme
TERM_BACKGROUND=light source ~/.config/toggle_theme.sh
TERM_BACKGROUND=dark source ~/.config/toggle_theme.sh
```

### Development Setup
```bash
# Reload shell configuration
source ~/.zshrc

# Install new global packages
yarn global add <package>

# Update Homebrew and packages
brew update && brew upgrade
```

## File Organization Patterns

- Configuration files use Lua (Neovim, WezTerm) or shell scripts for customization
- Theme-related configurations are centralized and cross-application
- Shell configuration separates plugin management (oh-my-zsh) from prompt (Starship)
- Git ignore patterns specifically exclude Claude Code local settings

## Integration Points

When modifying configurations:
- Theme changes should update `toggle_theme.sh` and relevant app configs
- Shell modifications require sourcing `.zshrc` and may affect PATH variables
- Neovim changes may need `:PackerSync` or equivalent plugin manager command
- WezTerm config changes are live-reloaded automatically

## Development Workflow Notes

- The repository uses symlinks for deployment (via GNU Stow or manual linking)
- Configuration changes are tested in the live environment
- No build process required - configurations are applied directly
- Neovim LSP servers are managed through Mason, installed in `~/.local/share/nvim/mason/bin`