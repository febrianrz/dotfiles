# Obsidian Sync dengan App - Setup Guide

## ✅ **Vault Synchronization Fixed!**

Neovim sekarang sudah terhubung dengan vault Obsidian app yang sudah ada.

## 📁 **Available Workspaces:**

1. **main** - `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian` ⭐ (default)
2. **work** - `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work`
3. **nextcloud** - `~/Nextcloud2/Project Doc/Obsidian`
4. **amazing** - `~/Nextcloud2/Project Doc/Obsidian/Amazing`
5. **project** - `~/Nextcloud2/Project Doc/Obsidian/Amazing/Project`

## 🚀 **How to Use:**

### Switch Workspaces
```bash
# List all workspaces
:ObsidianWorkspaces

# Switch workspace with picker
<leader>mww   # or :ObsidianWorkspace

# List workspaces shortcut
<leader>mws
```

### Navigate to Existing Vault
```bash
# Go to main iCloud vault
cd "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian"
nvim .

# Or open specific note
nvim "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian/Your Note.md"
```

### Create Notes (will sync with app)
```bash
# Create new note in current workspace
<leader>mn   # or <leader>on

# Search existing notes
<leader>ms   # or <leader>os

# Daily note
<leader>md   # or <leader>od
```

## 🔄 **Sync Workflow:**

1. **Edit di Neovim** → **Auto-sync ke Obsidian app** ✅
2. **Edit di Obsidian app** → **Auto-sync ke Neovim** ✅
3. **iCloud sync** → **Available di semua device** ✅

## 🛠 **Commands for Sync:**

```bash
# Test connection
:ObsidianTest

# List workspaces
:ObsidianWorkspaces

# Switch workspace
:ObsidianWorkspace

# Open in Obsidian app
<leader>mo
```

## 💡 **Tips:**

1. **Default workspace** adalah `main` (iCloud Obsidian folder)
2. **File changes** akan langsung sync dengan Obsidian app
3. **Gunakan** `<leader>mww` untuk switch antar vault
4. **iCloud vault** akan sync otomatis ke device lain

## 🎯 **Recommended Workflow:**

```bash
# 1. Navigate to your main vault
cd "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian"

# 2. Open Neovim
nvim .

# 3. Create/edit notes
<leader>mn   # new note
<leader>ms   # search notes

# 4. Check in Obsidian app - should be synced!
```

**Sekarang Neovim dan Obsidian app sudah fully synchronized!** 🎉