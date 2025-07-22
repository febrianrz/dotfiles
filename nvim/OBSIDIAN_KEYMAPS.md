# Obsidian Keymaps in Neovim

## ✅ Conflict Resolution
- **Aerial plugin**: Uses `<leader>o` for outline
- **Obsidian**: Moved to `<leader>m` (memo/markdown) prefix
- **nvim-spectre**: Moved options to `<leader>so`

## 🚀 Main Obsidian Keymaps

### Primary commands (using `<leader>m` prefix)
- `<leader>mo` - Open in Obsidian app
- `<leader>mn` - New Obsidian note
- `<leader>mq` - Quick switch between notes
- `<leader>mf` - Follow link under cursor
- `<leader>mb` - Show backlinks
- `<leader>ms` - Search notes
- `<leader>md` - Open today's daily note
- `<leader>my` - Open yesterday's daily note
- `<leader>mt` - Insert template
- `<leader>mp` - Paste image from clipboard
- `<leader>mr` - Rename current note
- `<leader>mws` - List workspaces
- `<leader>mww` - Switch workspace
- `<leader>mc` - Toggle conceallevel (UI features on/off)

### Convenience shortcuts (still under `<leader>o`)
- `<leader>on` - New Obsidian note (same as `<leader>mn`)
- `<leader>os` - Search notes (same as `<leader>ms`)
- `<leader>od` - Today's daily note (same as `<leader>md`)

### In-buffer actions (markdown files only)
- `<leader>ch` - Toggle checkbox
- `<Enter>` - Smart action (follow link or toggle checkbox)
- `gf` - Follow link under cursor

## 🔧 Other Plugin Keymaps (for reference)

### Aerial (Code Outline)
- `<leader>o` - Toggle Aerial outline
- `<leader>oo` - Open Aerial outline  
- `<leader>oc` - Close Aerial outline
- `<leader>of` - Focus Aerial outline
- `<leader>ot` - Telescope Aerial symbols

### nvim-spectre (Search/Replace)
- `<leader>so` - Show spectre options (moved from `<leader>o`)

## 📝 Usage Examples

1. **Create new note**: `<leader>mn` or `<leader>on`
2. **Quick switch**: `<leader>mq`
3. **Daily note**: `<leader>md` or `<leader>od`
4. **Search notes**: `<leader>ms` or `<leader>os`
5. **Toggle code outline**: `<leader>o` (aerial)

## 💡 Workflow Tips

- Use `<leader>m*` for all Obsidian-specific actions
- Use `<leader>o*` for code outline (aerial) when coding
- Use `<leader>on/os/od` as quick shortcuts for common Obsidian actions