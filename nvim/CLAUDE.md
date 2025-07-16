# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Neovim configuration repository based on Kickstart.nvim, extended with custom plugins and Laravel-specific tooling. The configuration is organized as a modular Lua-based setup with extensive customization for web development, particularly PHP/Laravel projects.

## Architecture

### Core Structure
- **Base**: Built on Kickstart.nvim template with single-file approach (init.lua)
- **Plugin Manager**: Lazy.nvim for plugin management and lazy loading
- **Custom Extensions**: Modular plugins in `lua/custom/plugins/` directory
- **Configuration**: Lua-based configuration with extensive customization

### Plugin Organization
- **Core plugins**: Defined in main `init.lua` file
- **Custom plugins**: Located in `lua/custom/plugins/` directory
- **Import system**: Uses `{ import = 'custom.plugins' }` in lazy.nvim setup
- **Modular approach**: Each plugin has its own configuration file

## Key Development Features

### Laravel Development
- **Laravel Tinker Integration**: Custom module for creating and running Laravel Tinker commands
  - `<leader>tw` - Open/create .tinker.php file
  - `<leader>tr` - Run .tinker.php in Laravel Tinker
- **PHP LSP**: Configured with Phpactor language server
- **PHP Formatting**: php-cs-fixer integration via conform.nvim

### Essential Keybindings
- **Leader Key**: `<space>` (space)
- **File Operations**: 
  - `<leader>wf` - Save current file
  - `<leader>wg` - Save all modified files
- **Buffer Management**:
  - `<leader>ba` - Close all buffers
  - `<leader>bo` - Close other buffers
  - `<leader>bl` - Close left buffers
  - `<leader>br` - Close right buffers
- **Git Operations**:
  - `<leader>go` - Open Git repository
  - `<leader>gp` - Open Pull Request

### Theme System
- **Dynamic Theme Switching**: Environment-based theme switching via `TERM_BACKGROUND`
- **Theme Commands**: `:SwitchTheme` and `:ToggleTheme`
- **Auto-detection**: Responds to SIGUSR1 signals for theme changes

## Common Commands

### Plugin Management
```bash
# Open Lazy.nvim plugin manager
:Lazy

# Update all plugins
:Lazy update

# Check plugin status
:Lazy check

# Install missing plugins
:Lazy install
```

### LSP and Language Features
```bash
# Check LSP health
:checkhealth lsp

# Mason tool installer
:Mason

# Format current buffer
<leader>f

# LSP actions (when in a file)
grn    # Rename symbol
gra    # Code action
grr    # Find references
grd    # Go to definition
gri    # Go to implementation
```

### Custom Utilities
```bash
# Clean unused imports (custom utility)
:CleanUse

# Laravel Tinker workflow
<leader>tw    # Open .tinker.php
<leader>tr    # Run Laravel Tinker

# File explorer (nvim-tree)
<leader>ee    # Toggle file explorer
<leader>ef    # Toggle file explorer on current file
```

### Telescope (Fuzzy Finder)
```bash
<leader>sf    # Find files
<leader>sg    # Live grep
<leader>sh    # Search help
<leader>sk    # Search keymaps
<leader>sb    # Search buffers
<leader>sd    # Search diagnostics
```

## Configuration Patterns

### Adding New Plugins
1. Create new file in `lua/custom/plugins/`
2. Follow the pattern:
```lua
return {
  'plugin/name',
  config = function()
    -- Configuration here
  end,
}
```

### Custom Keybindings
- Use `vim.keymap.set()` for new keybindings
- Follow the existing pattern with descriptive `desc` field
- Group related commands under logical leader prefixes

### LSP Configuration
- LSP servers configured in `lua/custom/plugins/lsp.lua`
- Mason handles automatic installation
- Custom on_attach functions for PHP development

## Development Workflow

### For PHP/Laravel Projects
1. Use `<leader>tw` to open Laravel Tinker file
2. Write PHP code in .tinker.php
3. Use `<leader>tr` to execute in Laravel Tinker
4. Use `<leader>pi` for Phpactor import class

### General Development
1. Use `<leader>sf` to find files
2. Use `<leader>sg` for project-wide search
3. Use LSP shortcuts for navigation and refactoring
4. Use `<leader>f` for formatting

## File Structure Notes

### Important Files
- `init.lua` - Main configuration file with core settings
- `lua/custom/plugins/` - Custom plugin configurations
- `lua/custom/laravel_tinker.lua` - Laravel Tinker integration
- `lua/custom/open_git_repo.lua` - Git repository utilities
- `lua/custom/formatter_check.lua` - Formatter checking utilities

### Custom Utilities
- **Theme switcher**: Global function `_G.switch_theme()`
- **Buffer management**: Custom functions for buffer operations
- **Laravel Tinker**: Complete workflow for Laravel development
- **Git integration**: Custom functions for repository operations

## Dependencies

### External Requirements
- Neovim 0.9+ (targets stable and nightly)
- ripgrep (for Telescope grep functionality)
- Node.js (for some LSP servers and formatters)
- PHP and Composer (for Laravel development)
- Git (for version control features)

### Optional Dependencies
- Nerd Font (set `vim.g.have_nerd_font = true` in init.lua)
- Clipboard tool (xclip/pbcopy for system clipboard)
- Make (for building telescope-fzf-native)

## Troubleshooting

### Common Issues
- **LSP not working**: Check `:Mason` for installed servers
- **Formatting issues**: Verify formatter installation via Mason
- **Theme not switching**: Check `TERM_BACKGROUND` environment variable
- **Laravel Tinker not working**: Ensure you're in a Laravel project directory

### Health Checks
```bash
:checkhealth          # General health check
:checkhealth lsp      # LSP-specific health check
:checkhealth lazy     # Plugin manager health
```