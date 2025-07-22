# Obsidian UI Features & Conceallevel

## ✅ **Conceallevel Warning Fixed!**

Obsidian UI features sekarang properly configured dengan `conceallevel = 2`.

## 🎨 **UI Features yang Available:**

### Visual Enhancements
- ✅ **Checkboxes**: `- [ ]` dan `- [x]` dengan icons
- ✅ **Bullets**: Bullets dengan symbols  
- ✅ **External Links**: Links dengan icons
- ✅ **Tags**: Styled tags dengan highlighting
- ✅ **Block IDs**: Styled block references
- ✅ **Highlighted text**: Background highlighting

### Checkbox Icons
- `- [ ]` → 󰄱 (empty checkbox)
- `- [x]` → ✓ (completed checkbox) 
- `- [>]` → → (forwarded)
- `- [~]` → 󰰱 (cancelled)
- `- [!]` → ! (important)

## 🔧 **Conceallevel Controls:**

### Commands
```bash
# Toggle between raw markdown and UI view
:ObsidianToggleConceal
<leader>mc

# Manual control
:set conceallevel=0    # Raw markdown
:set conceallevel=1    # Partial concealing  
:set conceallevel=2    # Full UI features (default)
```

### Settings Applied
- **conceallevel = 2**: Full Obsidian UI features
- **concealcursor = 'nv'**: Don't conceal on current line (normal/visual mode)

## 📝 **Markdown Features:**

### Auto-configured for markdown files:
- ✅ Spell checking (English + Indonesian)
- ✅ Text wrapping with line breaks
- ✅ Proper concealing for Obsidian UI
- ✅ Treesitter folding (disabled by default)

### Keymaps in markdown files:
- `<leader>b` - Bold text (visual mode)
- `<leader>i` - Italic text (visual mode)
- `<leader>c` - Inline code (visual mode)
- `<leader>l` - Create link (visual mode)
- `<leader>h1/h2/h3` - Headings
- `<leader>-` - Add task
- `<leader>x` - Toggle task checkbox

## 🎯 **Best Practices:**

### For Writing
- Keep `conceallevel = 2` for best Obsidian experience
- Use `<leader>mc` to toggle to raw view when needed
- UI features make reading more pleasant

### For Editing
- Concealing is disabled on current line
- You can see raw markdown syntax when cursor is on line
- Toggle to `conceallevel = 0` for pure markdown editing

## 🔥 **Quick Test:**

```markdown
# Test Obsidian UI Features

## Checkboxes
- [ ] Todo item
- [x] Completed item  
- [>] Forwarded item
- [!] Important item

## Links
[[Internal Link]]
[External Link](https://example.com)

## Tags
#obsidian #markdown #neovim

## Code
`inline code`
```

**UI features should now display beautifully!** 🎨