-- Obsidian setup utilities
local M = {}

-- Function to create Obsidian vault structure
M.create_vault_structure = function(vault_path)
  local paths = {
    vault_path .. "/notes",
    vault_path .. "/dailies", 
    vault_path .. "/templates",
    vault_path .. "/assets",
    vault_path .. "/assets/imgs",
  }
  
  for _, path in ipairs(paths) do
    vim.fn.mkdir(path, "p")
  end
  
  -- Create basic templates
  local daily_template = [[---
tags: [daily-notes]
date: {{date}}
---

# {{title}}

## Today's Goals
- [ ] 

## Notes


## Reflections


]]

  local note_template = [[---
tags: []
created: {{date}}
---

# {{title}}


]]

  -- Write templates
  local daily_template_file = io.open(vault_path .. "/templates/daily.md", "w")
  if daily_template_file then
    daily_template_file:write(daily_template)
    daily_template_file:close()
  end
  
  local note_template_file = io.open(vault_path .. "/templates/note.md", "w")
  if note_template_file then
    note_template_file:write(note_template)
    note_template_file:close()
  end
  
  vim.notify("✅ Obsidian vault structure created at: " .. vault_path, vim.log.levels.INFO)
end

-- Function to setup Obsidian for current directory
M.setup_current_dir = function()
  local current_dir = vim.fn.getcwd()
  local vault_name = vim.fn.fnamemodify(current_dir, ":t")
  
  local input_opts = {
    prompt = "Vault name (default: " .. vault_name .. "): ",
    default = vault_name,
  }
  
  vim.ui.input(input_opts, function(input)
    if input then
      M.create_vault_structure(current_dir)
      
      -- Update obsidian.nvim config to include this vault
      local obsidian = require("obsidian")
      local client = obsidian.new_client({
        workspaces = {
          {
            name = input,
            path = current_dir,
          }
        }
      })
      
      vim.notify("📝 Obsidian vault '" .. input .. "' setup complete!", vim.log.levels.INFO)
    end
  end)
end

-- Function to open Obsidian quick switcher
M.quick_note = function()
  local obsidian = require("obsidian")
  local client = obsidian.get_client()
  
  if not client then
    vim.notify("❌ No Obsidian workspace found", vim.log.levels.ERROR)
    return
  end
  
  vim.ui.input({ prompt = "Note title: " }, function(title)
    if title and title ~= "" then
      vim.cmd("ObsidianNew " .. title)
    end
  end)
end

-- Function to setup markdown file type settings
M.setup_markdown_ft = function()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
      -- Enable spell checking
      vim.opt_local.spell = true
      vim.opt_local.spelllang = { "en", "id" } -- English and Indonesian
      
      -- Enable text wrapping
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
      vim.opt_local.breakindent = true
      
      -- Set conceallevel for better Obsidian syntax (required for UI features)
      vim.opt_local.conceallevel = 2
      vim.opt_local.concealcursor = 'nv' -- Don't conceal on current line in normal/visual mode
      
      -- Enable folding
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
      vim.opt_local.foldenable = false -- Start with folds open
      
      -- Markdown-specific keymaps
      local opts = { buffer = true, silent = true }
      
      -- Bold text
      vim.keymap.set("v", "<leader>b", "c**<C-r>\"**<Esc>", { desc = "Bold text", unpack(opts) })
      
      -- Italic text  
      vim.keymap.set("v", "<leader>i", "c*<C-r>\"*<Esc>", { desc = "Italic text", unpack(opts) })
      
      -- Code block
      vim.keymap.set("v", "<leader>c", "c`<C-r>\"`<Esc>", { desc = "Inline code", unpack(opts) })
      
      -- Link creation
      vim.keymap.set("v", "<leader>l", "c[<C-r>\"]()<Esc>i", { desc = "Create link", unpack(opts) })
      
      -- Heading shortcuts
      vim.keymap.set("n", "<leader>h1", "I# <Esc>", { desc = "H1 heading", unpack(opts) })
      vim.keymap.set("n", "<leader>h2", "I## <Esc>", { desc = "H2 heading", unpack(opts) })
      vim.keymap.set("n", "<leader>h3", "I### <Esc>", { desc = "H3 heading", unpack(opts) })
      
      -- Task list
      vim.keymap.set("n", "<leader>-", "I- [ ] <Esc>A", { desc = "Add task", unpack(opts) })
      vim.keymap.set("n", "<leader>x", function()
        local line = vim.api.nvim_get_current_line()
        if line:match("%- %[ %]") then
          local new_line = line:gsub("%- %[ %]", "- [x]")
          vim.api.nvim_set_current_line(new_line)
        elseif line:match("%- %[x%]") then
          local new_line = line:gsub("%- %[x%]", "- [ ]")
          vim.api.nvim_set_current_line(new_line)
        end
      end, { desc = "Toggle task", unpack(opts) })
    end,
  })
end

-- Function to create Obsidian commands
M.create_commands = function()
  vim.api.nvim_create_user_command("ObsidianSetup", function()
    M.setup_current_dir()
  end, { desc = "Setup Obsidian vault in current directory" })
  
  vim.api.nvim_create_user_command("ObsidianQuickNote", function()
    M.quick_note()
  end, { desc = "Create new note with prompt" })
  
  vim.api.nvim_create_user_command("ObsidianVaultInfo", function()
    local obsidian = require("obsidian")
    local client = obsidian.get_client()
    
    if client then
      local workspace = client.current_workspace
      vim.notify(
        string.format("📁 Current vault: %s\n📂 Path: %s", workspace.name, workspace.path),
        vim.log.levels.INFO,
        { title = "Obsidian Vault Info" }
      )
    else
      vim.notify("❌ No active Obsidian workspace", vim.log.levels.WARN)
    end
  end, { desc = "Show current vault info" })
end

-- Initialize
M.setup = function()
  M.setup_markdown_ft()
  M.create_commands()
  
  -- Global keymaps for Obsidian
  vim.keymap.set("n", "<leader>oqn", M.quick_note, { desc = "Quick new note" })
  vim.keymap.set("n", "<leader>ovi", "<cmd>ObsidianVaultInfo<cr>", { desc = "Vault info" })
  vim.keymap.set("n", "<leader>ovs", "<cmd>ObsidianSetup<cr>", { desc = "Setup vault" })
end

return M