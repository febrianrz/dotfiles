return {
  'nvim-treesitter/nvim-treesitter-context',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    -- Force global enable immediately
    vim.g.treesitter_context_enabled = true
    
    require('treesitter-context').setup({
      enable = true, -- Enable this plugin globally by default
      throttle = false, -- Disable throttling for more responsive updates
      max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0, -- Remove minimum height requirement
      line_numbers = true,
      multiline_threshold = 20, -- Maximum number of lines to show for a single context
      trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = nil,
      zindex = 20, -- The Z-index of the context window
      on_attach = function(buf)
        -- Always enable for all buffers
        return true
      end,

      -- Context patterns for different languages
      patterns = {
        -- For all filetypes - more comprehensive patterns
        default = {
          'class',
          'function',
          'method',
          'for',
          'while',
          'if',
          'switch',
          'case',
          'interface',
          'struct',
          'enum',
          'impl',
          'trait',
          'module',
          'namespace',
          'block',
          'try',
          'catch',
          'finally',
          'with',
          'def',
          'async',
          'loop',
          'match',
          'closure',
        },

        -- Patterns for specific filetypes
        -- If a pattern is missing here, *treesitter-context* will attempt
        -- to query the filetype for common class and function nodes.
        tex = {
          'chapter',
          'section',
          'subsection',
          'subsubsection',
        },
        haskell = {
          'adt'
        },
        rust = {
          'impl_item',
          'struct',
          'enum',
        },
        terraform = {
          'block',
          'object_elem',
          'attribute',
        },
        scala = {
          'object_definition',
        },
        vhdl = {
          'process_statement',
          'architecture_body',
          'entity_declaration',
        },
        markdown = {
          'section',
        },
        elixir = {
          'anonymous_function',
          'arguments',
          'block',
          'do_block',
          'list',
          'map',
          'tuple',
          'quoted_content',
        },
        json = {
          'pair',
        },
        typescript = {
          'export_statement',
          'class_declaration',
          'method_definition',
          'arrow_function',
          'function_declaration',
          'generator_function_declaration',
        },
        yaml = {
          'block_mapping_pair',
        },
        -- For PHP (Laravel)
        php = {
          'class_declaration',
          'method_declaration', 
          'function_definition',
          'if_statement',
          'foreach_statement',
          'for_statement',
          'while_statement',
          'switch_statement',
          'try_statement',
          'namespace_definition',
        },
        -- For Solidity
        solidity = {
          'contract_declaration',
          'function_definition',
          'modifier_definition',
          'struct_declaration',
          'enum_declaration',
          'event_definition',
        },
        -- For JavaScript/React
        javascript = {
          'export_statement',
          'class_declaration',
          'method_definition',
          'arrow_function',
          'function_declaration',
          'generator_function_declaration',
          'if_statement',
          'for_statement',
          'for_in_statement',
          'while_statement',
          'switch_statement',
          'try_statement',
        },
        -- For JSX/TSX
        javascriptreact = {
          'export_statement',
          'class_declaration', 
          'method_definition',
          'arrow_function',
          'function_declaration',
          'generator_function_declaration',
          'jsx_element',
          'jsx_fragment',
          'if_statement',
          'for_statement',
          'while_statement',
          'switch_statement',
          'try_statement',
        },
        typescriptreact = {
          'export_statement',
          'class_declaration',
          'method_definition', 
          'arrow_function',
          'function_declaration',
          'generator_function_declaration',
          'jsx_element',
          'jsx_fragment',
          'interface_declaration',
          'type_alias_declaration',
          'if_statement',
          'for_statement',
          'while_statement',
          'switch_statement',
          'try_statement',
        },
      }
    })

    -- Keymaps for treesitter-context
    vim.keymap.set("n", "[c", function()
      require("treesitter-context").go_to_context(vim.v.count1)
    end, { silent = true, desc = "Go to context (sticky scroll)" })

    -- Toggle treesitter-context on/off
    vim.keymap.set("n", "<leader>tc", "<cmd>TSContextToggle<cr>", 
      { desc = "Toggle Treesitter Context (sticky scroll)" })

    -- Custom highlight groups for better visibility
    vim.api.nvim_set_hl(0, 'TreesitterContext', { 
      bg = '#2d3748', 
      fg = '#e2e8f0',
      italic = true 
    })
    vim.api.nvim_set_hl(0, 'TreesitterContextBottom', { 
      underline = true, 
      sp = '#4a5568' 
    })
    vim.api.nvim_set_hl(0, 'TreesitterContextLineNumber', { 
      bg = '#2d3748', 
      fg = '#718096' 
    })
    
    -- Debug command to check if treesitter context is working
    vim.api.nvim_create_user_command('TSContextDebug', function()
      local context = require('treesitter-context')
      local parsers = require('nvim-treesitter.parsers')
      local lang = parsers.get_buf_lang()
      local buf_name = vim.fn.expand('%:t')
      local window_height = vim.api.nvim_win_get_height(0)
      
      vim.notify(string.format(
        "Treesitter Context Debug:\n" ..
        "• File: %s\n" ..
        "• Language: %s\n" ..
        "• Context enabled: %s\n" ..
        "• Window height: %d\n" ..
        "• Min height: 5\n" ..
        "• Parser available: %s",
        buf_name,
        lang or "unknown", 
        context.enabled() and "✅ Yes" or "❌ No",
        window_height,
        parsers.has_parser(lang) and "✅ Yes" or "❌ No"
      ), vim.log.levels.INFO, { title = "TSContext Debug" })
    end, { desc = "Debug treesitter context" })
    
    -- Force enable for current buffer
    vim.api.nvim_create_user_command('TSContextForceEnable', function()
      require('treesitter-context').enable()
      vim.notify("Treesitter context force enabled", vim.log.levels.INFO)
    end, { desc = "Force enable treesitter context" })
    
    -- Immediate force enable
    local context = require('treesitter-context')
    context.enable()
    
    -- Load the force context module for extra insurance
    pcall(require, 'custom.force_context')
    
    -- Override any disable attempts with a persistent enable check
    vim.api.nvim_create_autocmd({"BufEnter", "VimEnter", "TabEnter", "WinEnter"}, {
      callback = function()
        vim.schedule(function()
          local context = require('treesitter-context')
          -- Force enable regardless of any other conditions
          context.enable()
        end)
      end,
    })
    
    -- Extra insurance - check every few seconds
    local timer = vim.loop.new_timer()
    timer:start(2000, 3000, vim.schedule_wrap(function()
      local context = require('treesitter-context')
      if not context.enabled() then
        context.enable()
      end
    end))
    
    -- Global function for easy access
    _G.force_enable_ts_context = function()
      local context = require('treesitter-context')
      context.enable()
      vim.notify("🔥 Treesitter context manually enabled!", vim.log.levels.INFO)
    end
    
    -- Manual enable shortcut  
    vim.keymap.set("n", "<leader>te", function()
      _G.force_enable_ts_context()
    end, { desc = "Force enable treesitter context" })
    
    -- Override the tc keymap to always ensure it's enabled (no more toggle)
    vim.keymap.set("n", "<leader>tc", function()
      local context = require('treesitter-context')
      context.enable()
      vim.notify("🔥 Treesitter context FORCE ENABLED!", vim.log.levels.INFO)
    end, { desc = "Force Enable Treesitter Context" })
    
    -- Status check command
    vim.keymap.set("n", "<leader>ts", function()
      local context = require('treesitter-context')
      local status = context.enabled() and "✅ ENABLED" or "❌ DISABLED"
      vim.notify("Treesitter Context Status: " .. status, vim.log.levels.INFO)
    end, { desc = "Check Treesitter Context Status" })
    
  end,
  
  keys = {
    { "[c", function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "Go to context" },
    { "<leader>tc", "<cmd>TSContextToggle<cr>", desc = "Toggle Treesitter Context" },
  }
}