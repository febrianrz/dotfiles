return {
  "folke/which-key.nvim", -- We'll extend which-key functionality
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim"
  },
  config = function()
    local telescope = require('telescope')
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    -- Function to get all keybindings
    local function get_all_keybindings()
      local keybindings = {}
      
      -- Get keymaps from all modes
      local modes = {'n', 'i', 'v', 'x', 'o', 'c', 't'}
      
      for _, mode in ipairs(modes) do
        -- Get global keymaps
        local global_keymaps = vim.api.nvim_get_keymap(mode)
        
        -- Get buffer-local keymaps
        local buffer_keymaps = vim.api.nvim_buf_get_keymap(0, mode)
        
        -- Combine both
        local all_keymaps = {}
        for _, keymap in ipairs(global_keymaps) do
          keymap.scope = 'global'
          table.insert(all_keymaps, keymap)
        end
        for _, keymap in ipairs(buffer_keymaps) do
          keymap.scope = 'buffer'
          table.insert(all_keymaps, keymap)
        end
        
        for _, keymap in ipairs(all_keymaps) do
          local lhs = keymap.lhs or ''
          local rhs = keymap.rhs or ''
          local desc = keymap.desc or ''
          local scope = keymap.scope or 'global'
          
          -- Handle callback functions
          if keymap.callback and type(keymap.callback) == 'function' then
            rhs = '<function>'
          elseif keymap.callback then
            rhs = tostring(keymap.callback)
          end
          
          -- Clean up the command string
          if type(rhs) == 'string' then
            rhs = rhs:gsub('\n', ' '):gsub('%s+', ' ')
          end
          
          -- Skip internal/empty mappings but be more lenient
          if lhs ~= '' and not lhs:match('^<SNR>') then
            table.insert(keybindings, {
              mode = mode,
              key = lhs,
              command = rhs,
              description = desc,
              scope = scope,
              display = string.format('[%s%s] %-18s → %-28s %s', 
                mode:upper(),
                scope == 'buffer' and '*' or '',
                lhs, 
                type(rhs) == 'string' and (rhs ~= '' and rhs:sub(1, 28) or '<command>') or '<function>',
                desc ~= '' and desc or '(no description)'
              )
            })
          end
        end
      end
      
      -- Add some common Vim keybindings manually for reference
      local common_bindings = {
        { mode = 'n', key = 'j', command = 'down', description = 'Move cursor down' },
        { mode = 'n', key = 'k', command = 'up', description = 'Move cursor up' },
        { mode = 'n', key = 'h', command = 'left', description = 'Move cursor left' },
        { mode = 'n', key = 'l', command = 'right', description = 'Move cursor right' },
        { mode = 'n', key = 'w', command = 'word forward', description = 'Move to next word' },
        { mode = 'n', key = 'b', command = 'word backward', description = 'Move to previous word' },
        { mode = 'n', key = 'gg', command = 'goto first line', description = 'Go to first line' },
        { mode = 'n', key = 'G', command = 'goto last line', description = 'Go to last line' },
        { mode = 'n', key = 'dd', command = 'delete line', description = 'Delete current line' },
        { mode = 'n', key = 'yy', command = 'yank line', description = 'Copy current line' },
        { mode = 'n', key = 'p', command = 'paste', description = 'Paste after cursor' },
        { mode = 'n', key = 'P', command = 'paste before', description = 'Paste before cursor' },
        { mode = 'n', key = 'u', command = 'undo', description = 'Undo last change' },
        { mode = 'n', key = '<C-r>', command = 'redo', description = 'Redo last change' },
        { mode = 'n', key = '/', command = 'search', description = 'Search forward' },
        { mode = 'n', key = '?', command = 'search backward', description = 'Search backward' },
        { mode = 'n', key = 'n', command = 'next search', description = 'Next search result' },
        { mode = 'n', key = 'N', command = 'prev search', description = 'Previous search result' },
        { mode = 'i', key = '<Esc>', command = 'normal mode', description = 'Exit insert mode' },
        { mode = 'v', key = 'd', command = 'delete selection', description = 'Delete selected text' },
        { mode = 'v', key = 'y', command = 'yank selection', description = 'Copy selected text' },
      }
      
      for _, binding in ipairs(common_bindings) do
        binding.display = string.format('[%s] %-20s → %-30s %s', 
          binding.mode:upper(), 
          binding.key, 
          binding.command,
          binding.description
        )
        table.insert(keybindings, binding)
      end
      
      -- Remove duplicates based on mode + key combination
      local seen = {}
      local unique_keybindings = {}
      
      for _, binding in ipairs(keybindings) do
        local key_id = binding.mode .. "|" .. binding.key
        if not seen[key_id] then
          seen[key_id] = true
          table.insert(unique_keybindings, binding)
        end
      end
      
      -- Sort by mode then by key
      table.sort(unique_keybindings, function(a, b)
        if a.mode == b.mode then
          return a.key < b.key
        end
        return a.mode < b.mode
      end)
      
      return unique_keybindings
    end

    -- Function to show keybindings picker
    local function show_keybindings()
      local keybindings = get_all_keybindings()
      
      pickers.new({}, {
        prompt_title = "🔍 All Keybindings",
        finder = finders.new_table({
          results = keybindings,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.display,
              ordinal = entry.mode .. " " .. entry.key .. " " .. entry.description .. " " .. entry.command,
              -- Add unique identifier to prevent grouping
              id = entry.mode .. "|" .. entry.key .. "|" .. (entry.scope or "global"),
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = false,
        layout_config = {
          height = 0.8,
          width = 0.9,
        },
        results_title = false,
        disable_devicons = true,
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              -- Show detailed info about the keybinding
              vim.notify(
                string.format(
                  "Mode: %s\nKey: %s\nCommand: %s\nDescription: %s",
                  selection.value.mode:upper(),
                  selection.value.key,
                  selection.value.command,
                  selection.value.description
                ),
                vim.log.levels.INFO,
                { title = "Keybinding Details" }
              )
            end
          end)
          
          -- Add custom action to execute the keybinding
          map('i', '<C-e>', function()
            local selection = action_state.get_selected_entry()
            if selection and selection.value.mode == 'n' then
              actions.close(prompt_bufnr)
              -- Try to execute the keybinding
              local key = selection.value.key
              if key:match('^<leader>') then
                key = key:gsub('<leader>', vim.g.mapleader or ' ')
              end
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), 'n', false)
            end
          end)
          
          return true
        end,
      }):find()
    end

    -- Function to show only leader keybindings
    local function show_leader_keybindings()
      local all_keybindings = get_all_keybindings()
      local leader_keybindings = {}
      local leader = vim.g.mapleader or ' '
      
      for _, binding in ipairs(all_keybindings) do
        -- Check for <leader> pattern or actual leader key
        if binding.key:match('^<leader>') or 
           binding.key:match('^<Leader>') or
           binding.key:match('^' .. vim.pesc(leader)) then
          table.insert(leader_keybindings, binding)
        end
      end
      
      -- Add debug info
      vim.notify(string.format("Found %d leader keybindings (leader key: '%s')", 
        #leader_keybindings, leader), vim.log.levels.INFO)
      
      pickers.new({}, {
        prompt_title = "🎯 Leader Keybindings",
        finder = finders.new_table({
          results = leader_keybindings,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.display,
              ordinal = entry.mode .. " " .. entry.key .. " " .. entry.description .. " " .. entry.command,
              -- Add unique identifier to prevent grouping
              id = entry.mode .. "|" .. entry.key .. "|" .. (entry.scope or "global"),
            }
          end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = false,
        layout_config = {
          height = 0.8,
          width = 0.9,
        },
        results_title = false,
        disable_devicons = true,
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              vim.notify(
                string.format(
                  "Mode: %s\nKey: %s\nCommand: %s\nDescription: %s",
                  selection.value.mode:upper(),
                  selection.value.key,
                  selection.value.command,
                  selection.value.description
                ),
                vim.log.levels.INFO,
                { title = "Leader Keybinding Details" }
              )
            end
          end)
          
          return true
        end,
      }):find()
    end

    -- Create user commands
    vim.api.nvim_create_user_command('KeybindingsList', show_keybindings, {
      desc = 'Show all keybindings in Telescope'
    })
    
    vim.api.nvim_create_user_command('LeaderKeybindings', show_leader_keybindings, {
      desc = 'Show leader keybindings in Telescope'
    })

    -- Set up keybindings
    vim.keymap.set('n', '<leader>?', show_keybindings, { 
      desc = 'Show all keybindings' 
    })
    
    vim.keymap.set('n', '<leader>?l', show_leader_keybindings, { 
      desc = 'Show leader keybindings' 
    })

    -- Also extend the existing which-key functionality with updated API
    require("which-key").setup({
      preset = "classic",
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
        mappings = false,
      },
      keys = {
        scroll_down = "<c-d>",
        scroll_up = "<c-u>",
      },
      win = {
        border = "rounded",
        padding = { 1, 2 }, -- top/bottom, left/right
        wo = {
          winblend = 0,
        },
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "left",
      },
      filter = function(mapping)
        -- Filter out mappings we don't want to show
        return mapping.desc and mapping.desc ~= ""
      end,
      show_help = true,
      triggers = {
        { "<auto>", mode = "nxso" },
      },
    })
  end,
}