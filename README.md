# Febrian's Dotfiles

This repository contains my personal dotfiles and configuration files for various applications and tools that I use in my daily workflow. The configurations are primarily stored in the `.config` directory following the XDG Base Directory Specification.

## Overview

My dotfiles setup is designed to create a productive and customized development environment. Here's what's included:

- **Neovim**: Modern text editor with IDE-like features
- **Shell**: Configuration for my preferred shell (Bash/Fish/Zsh)
- **Terminal**: Terminal emulator configurations
- **Window Manager**: Configuration for tiling window manager
- **Other Tools**: Various utility configurations

## Directory Structure

```
.
├── .config/
│   ├── nvim/                  # Neovim configuration
│   │   ├── init.lua           # Main Neovim configuration
│   │   ├── lua/               # Lua modules for Neovim
│   │   └── ...
│   ├── fish/                  # Fish shell configuration
│   │   └── config.fish
│   ├── tmux/                  # Tmux configuration
│   │   └── tmux.conf
│   ├── alacritty/             # Alacritty terminal configuration
│   │   └── alacritty.yml
│   └── ...                    # Other tool configurations
└── scripts/                   # Utility scripts
    └── ...
```

## Neovim Configuration

My Neovim setup offers a full-featured development environment:

### Features

- Modern plugin management with [packer.nvim](https://github.com/wbthomason/packer.nvim)
- LSP integration for code completion and analysis
- Treesitter for improved syntax highlighting
- Telescope for fuzzy finding
- Custom key mappings for productivity
- Code snippets and autocompletion
- Theme and UI customization

### Key Plugins

- LSP configuration
- Treesitter for better syntax highlighting
- Telescope for fuzzy finding
- NvimTree for file explorer
- Which-key for keybinding help
- Lualine for status line

## Installation

### Prerequisites

- Git
- Stow (optional, for symlink management)
- Latest version of Neovim (>= 0.7)
- Node.js (for LSP servers)
- Ripgrep (for Telescope)

### Steps

1. Clone this repository to your home directory:

```bash
git clone https://github.com/febrianrz/dotfiles.git ~/.dotfiles
```

2. Create symbolic links (manual method):

```bash
ln -sf ~/.dotfiles/.config/nvim ~/.config/nvim
ln -sf ~/.dotfiles/.config/fish ~/.config/fish
# ... and so on for other config directories
```

Alternatively, if you use GNU Stow:

```bash
cd ~/.dotfiles
stow .
```

3. Install plugins for Neovim:
   - Start Neovim and run `:PackerSync`

## Customization

Feel free to fork this repository and customize it according to your preferences. The modular structure makes it easy to add, remove, or modify configurations.

### Making Changes

1. Modify the configuration files as needed
2. If you're using Stow, run `stow -R .` to update symlinks
3. Test your changes

## Tips and Tricks

- Check the comments in each configuration file for detailed explanations
- Neovim keybindings follow a logical structure for easy memorization
- Use `:checkhealth` in Neovim to ensure all plugins are properly configured

## Updating

To update the configurations with the latest changes:

```bash
cd ~/.dotfiles
git pull
```

## License

This project is open source and available under the [MIT License](LICENSE).

## Contact

If you have any questions or suggestions, feel free to reach out:

- GitHub: [@febrianrz](https://github.com/febrianrz)

---

**Note**: These dotfiles are continuously evolving as I refine my workflow. Feel free to check back for updates and improvements.
