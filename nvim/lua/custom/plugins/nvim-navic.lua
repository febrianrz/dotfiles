return {
  "SmiteshP/nvim-navic",
  dependencies = { "neovim/nvim-lspconfig" },
  config = function()
    local navic = require("nvim-navic")
    
    navic.setup({
      icons = {
        File          = "󰈙 ",
        Module        = " ",
        Namespace     = "󰌗 ",
        Package       = " ",
        Class         = "󰌗 ",
        Method        = "󰆧 ",
        Property      = " ",
        Field         = " ",
        Constructor   = " ",
        Enum          = "󰕘",
        Interface     = "󰕘",
        Function      = "󰊕 ",
        Variable      = "󰆧 ",
        Constant      = "󰏿 ",
        String        = "󰀬 ",
        Number        = "󰎠 ",
        Boolean       = "◩ ",
        Array         = "󰅪 ",
        Object        = "󰅩 ",
        Key           = "󰌋 ",
        Null          = "󰟢 ",
        EnumMember    = " ",
        Struct        = "󰌗 ",
        Event         = " ",
        Operator      = "󰆕 ",
        TypeParameter = "󰊄 ",
      },
      lsp = {
        auto_attach = false, -- We'll manually attach in LSP on_attach
        preference = { "phpactor", "intelephense" }, -- Prefer phpactor over intelephense
      },
      highlight = true,
      separator = " > ",
      depth_limit = 0,
      depth_limit_indicator = "..",
      safe_output = true,
      lazy_update_context = true, -- Enable lazy update for better tab support
      click = false,
      format_text = function(text)
        return text
      end,
    })
    
    -- Set up navic highlights to make it visible
    vim.api.nvim_set_hl(0, 'NavicIconsFile', { fg = '#7aa2f7', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsModule', { fg = '#f7768e', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsNamespace', { fg = '#bb9af7', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsPackage', { fg = '#9ece6a', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsClass', { fg = '#f7768e', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsMethod', { fg = '#7dcfff', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsProperty', { fg = '#c0caf5', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsField', { fg = '#c0caf5', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsConstructor', { fg = '#f7768e', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsEnum', { fg = '#bb9af7', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsInterface', { fg = '#ff9e64', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsFunction', { fg = '#7dcfff', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsVariable', { fg = '#9ece6a', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsConstant', { fg = '#e0af68', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsString', { fg = '#9ece6a', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsNumber', { fg = '#ff9e64', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsBoolean', { fg = '#ff9e64', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsArray', { fg = '#7dcfff', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsObject', { fg = '#7dcfff', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsKey', { fg = '#c0caf5', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsNull', { fg = '#565f89', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsEnumMember', { fg = '#9ece6a', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsStruct', { fg = '#f7768e', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsEvent', { fg = '#bb9af7', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsOperator', { fg = '#c0caf5', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicIconsTypeParameter', { fg = '#73daca', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicText', { fg = '#c0caf5', bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NavicSeparator', { fg = '#565f89', bg = 'NONE' })
    
    -- Function to attach navic to LSP
    local function lsp_on_attach(client, bufnr)
      if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
      end
    end
    
    -- Make the attach function available globally so LSP configs can use it
    _G.navic_on_attach = lsp_on_attach
    
    -- Debug command to manually attach navic to current LSP clients
    vim.api.nvim_create_user_command('NavicAttachAll', function()
      local bufnr = vim.api.nvim_get_current_buf()
      local navic = require("nvim-navic")
      local attached_count = 0
      
      for _, client in pairs(vim.lsp.get_active_clients({bufnr = bufnr})) do
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
          attached_count = attached_count + 1
          vim.notify(string.format("🔗 Manually attached navic to %s", client.name), vim.log.levels.INFO)
        end
      end
      
      if attached_count > 0 then
        vim.defer_fn(function()
          if navic.is_available(bufnr) then
            local winbar_text = '%#NavicText#%{%v:lua.require("nvim-navic").get_location()%}'
            pcall(vim.api.nvim_buf_set_option, bufnr, 'winbar', winbar_text)
            vim.notify("✅ Navic winbar enabled after manual attachment", vim.log.levels.INFO)
          else
            vim.notify("❌ Navic still not available after manual attachment", vim.log.levels.ERROR)
          end
        end, 500)
      else
        vim.notify("❌ No LSP clients with documentSymbolProvider found", vim.log.levels.WARN)
      end
    end, { desc = "Manually attach navic to all suitable LSP clients" })
    
    -- Additional trigger for window focus (helpful when switching from nvim-tree)
    vim.api.nvim_create_autocmd({"BufEnter", "WinEnter"}, {
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')
        local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
        
        if buftype == '' and filetype ~= '' then
          -- Only enable if navic is available but winbar is not set
          local navic = require("nvim-navic")
          if navic.is_available(bufnr) then
            local current_winbar = vim.api.nvim_buf_get_option(bufnr, 'winbar')
            if current_winbar == '' then
              pcall(vim.api.nvim_buf_set_option, bufnr, 'winbar', '%{%v:lua.require("nvim-navic").get_location()%}')
            end
          end
        end
      end,
    })
    
    -- Keymaps for navic
    vim.keymap.set("n", "<leader>nb", function()
      local location = navic.get_location()
      if location ~= "" then
        vim.notify("Current location: " .. location, vim.log.levels.INFO, {
          title = "Navic Breadcrumb"
        })
      else
        vim.notify("No location available", vim.log.levels.WARN)
      end
    end, { desc = "Show navic breadcrumb" })
    
    -- Toggle winbar
    vim.keymap.set("n", "<leader>nw", function()
      local success, current_winbar = pcall(vim.api.nvim_get_option_value, 'winbar', { scope = 'local' })
      if not success then current_winbar = '' end
      
      if current_winbar == '' then
        pcall(function()
          vim.opt_local.winbar = '%#NavicText#%{%v:lua.require("nvim-navic").get_location()%}'
        end)
        vim.notify("Navic winbar enabled", vim.log.levels.INFO)
      else
        pcall(function()
          vim.opt_local.winbar = ''
        end)
        vim.notify("Navic winbar disabled", vim.log.levels.INFO)
      end
    end, { desc = "Toggle navic winbar" })
    
    -- Debug navic status
    vim.keymap.set("n", "<leader>nd", function()
      local navic = require("nvim-navic")
      local bufnr = vim.api.nvim_get_current_buf()
      local available = navic.is_available(bufnr)
      local location = navic.get_location()
      local data = navic.get_data()
      local current_winbar = vim.api.nvim_buf_get_option(bufnr, 'winbar')
      
      -- Get cursor position
      local cursor = vim.api.nvim_win_get_cursor(0)
      local line = cursor[1]
      local col = cursor[2]
      
      -- Check LSP document symbols
      local has_symbols = false
      for _, client in pairs(vim.lsp.get_active_clients({bufnr = bufnr})) do
        if client.server_capabilities.documentSymbolProvider then
          has_symbols = true
          break
        end
      end
      
      vim.notify(string.format(
        "Navic Debug:\n• Available: %s\n• Location: %s\n• Data items: %s\n• Current winbar: %s\n• Cursor: line %d, col %d\n• LSP has symbols: %s\n• LSP clients: %s",
        available and "✅ Yes" or "❌ No",
        location ~= "" and location or "❌ Empty",
        data and #data or "0",
        current_winbar ~= "" and "✅ Set" or "❌ Empty",
        line, col,
        has_symbols and "✅ Yes" or "❌ No",
        table.concat(vim.tbl_map(function(client) return client.name end, vim.lsp.get_active_clients()), ", ")
      ), vim.log.levels.INFO, { title = "Navic Debug" })
      
      -- Try to manually request document symbols for debugging
      if has_symbols then
        vim.notify("Requesting document symbols...", vim.log.levels.INFO)
        vim.lsp.buf.document_symbol()
      end
    end, { desc = "Debug navic status" })
    
    -- Jump to specific breadcrumb level (experimental)
    vim.keymap.set("n", "<leader>nj", function()
      local data = navic.get_data()
      if not data or #data == 0 then
        vim.notify("No navigation data available", vim.log.levels.WARN)
        return
      end
      
      local items = {}
      for i, item in ipairs(data) do
        table.insert(items, string.format("%d: %s %s", i, item.icon, item.name))
      end
      
      vim.ui.select(items, {
        prompt = "Jump to breadcrumb level:",
        format_item = function(item)
          return item
        end,
      }, function(choice, idx)
        if choice and idx then
          local target = data[idx]
          if target then
            vim.api.nvim_win_set_cursor(0, {target.scope.start.line + 1, target.scope.start.character})
            vim.notify("Jumped to: " .. target.name, vim.log.levels.INFO)
          end
        end
      end)
    end, { desc = "Jump to breadcrumb level" })
    
    -- Manual enable both features (enhanced)
    vim.keymap.set("n", "<leader>ne", function()
      local bufnr = vim.api.nvim_get_current_buf()
      local navic = require("nvim-navic")
      local context = require('treesitter-context')
      
      -- Force enable treesitter context
      context.enable()
      vim.notify("🔥 Treesitter context force enabled", vim.log.levels.INFO)
      
      -- Force attach navic to all LSP clients first
      for _, client in pairs(vim.lsp.get_active_clients({bufnr = bufnr})) do
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
      end
      
      -- Enable navic winbar
      vim.defer_fn(function()
        if navic.is_available(bufnr) then
          local winbar_text = '%#NavicText#%{%v:lua.require("nvim-navic").get_location()%}'
          pcall(vim.api.nvim_buf_set_option, bufnr, 'winbar', winbar_text)
          vim.notify("✅ Both navic and context enabled!", vim.log.levels.INFO)
        else
          vim.notify("❌ Navic still not available", vim.log.levels.WARN)
        end
      end, 500)
    end, { desc = "Force enable both navic and context" })
    
    -- Quick command for just enabling context
    vim.keymap.set("n", "<leader>nc", function()
      local context = require('treesitter-context')
      context.enable()
      vim.notify("🔥 Treesitter context enabled", vim.log.levels.INFO)
    end, { desc = "Quick enable treesitter context" })
    
    -- Force attach navic to current LSP clients
    vim.keymap.set("n", "<leader>na", "<cmd>NavicAttachAll<cr>", { desc = "Force attach navic to LSP clients" })
    
    -- Debug LSP capabilities for navic
    vim.keymap.set("n", "<leader>nl", function()
      local bufnr = vim.api.nvim_get_current_buf()
      local clients = vim.lsp.get_active_clients({bufnr = bufnr})
      
      if #clients == 0 then
        vim.notify("❌ No LSP clients attached to current buffer", vim.log.levels.WARN)
        return
      end
      
      local info = "LSP Clients Debug:\n"
      for _, client in pairs(clients) do
        local supports_symbols = client.server_capabilities.documentSymbolProvider and "✅" or "❌"
        info = info .. string.format("• %s: documentSymbolProvider %s\n", client.name, supports_symbols)
      end
      
      vim.notify(info, vim.log.levels.INFO, { title = "LSP Debug" })
    end, { desc = "Debug LSP capabilities for navic" })
    
    -- Test LSP document symbols request
    vim.keymap.set("n", "<leader>ns", function()
      local bufnr = vim.api.nvim_get_current_buf()
      
      -- Manual LSP request for document symbols
      local params = { textDocument = vim.lsp.util.make_text_document_params() }
      
      vim.lsp.buf_request(bufnr, 'textDocument/documentSymbol', params, function(err, result, ctx)
        if err then
          vim.notify("❌ LSP Error: " .. vim.inspect(err), vim.log.levels.ERROR)
        elseif not result or vim.tbl_isempty(result) then
          vim.notify("⚠️ No document symbols returned from LSP", vim.log.levels.WARN)
        else
          vim.notify(string.format("✅ Got %d document symbols from LSP", #result), vim.log.levels.INFO)
          
          -- Show first few symbols for debugging
          local preview = ""
          for i = 1, math.min(3, #result) do
            local symbol = result[i]
            preview = preview .. string.format("• %s (%s)\n", symbol.name, symbol.kind)
          end
          
          if #result > 3 then
            preview = preview .. string.format("... and %d more", #result - 3)
          end
          
          vim.notify("Document Symbols:\n" .. preview, vim.log.levels.INFO)
        end
      end)
    end, { desc = "Test LSP document symbols request" })
    
    -- Refresh navic for current window/tab
    vim.keymap.set("n", "<leader>nr", function()
      local navic = require("nvim-navic")
      local bufnr = vim.api.nvim_get_current_buf()
      local winid = vim.api.nvim_get_current_win()
      
      -- Clear current winbar
      pcall(vim.api.nvim_buf_set_option, bufnr, 'winbar', '')
      
      -- Force reattach navic to all LSP clients
      for _, client in pairs(vim.lsp.get_active_clients({bufnr = bufnr})) do
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
          vim.notify(string.format("🔄 Re-attached navic to %s", client.name), vim.log.levels.INFO)
        end
      end
      
      -- Re-enable winbar after delay
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(bufnr) and navic.is_available(bufnr) then
          local winbar_text = '%#NavicText#%{%v:lua.require("nvim-navic").get_location()%}'
          pcall(vim.api.nvim_buf_set_option, bufnr, 'winbar', winbar_text)
          vim.notify("✅ Navic refreshed for current window", vim.log.levels.INFO)
        else
          vim.notify("❌ Navic still not available after refresh", vim.log.levels.WARN)
        end
      end, 1000)
    end, { desc = "Refresh navic for current window" })
    
    -- Debug tab/window issues
    vim.keymap.set("n", "<leader>nt", function()
      local navic = require("nvim-navic")
      local current_tab = vim.api.nvim_get_current_tabpage()
      local current_win = vim.api.nvim_get_current_win()
      local current_buf = vim.api.nvim_get_current_buf()
      
      local info = string.format(
        "Tab/Window Debug:\n• Current tab: %d\n• Current window: %d\n• Current buffer: %d\n• Buffer name: %s\n• Navic available: %s",
        current_tab,
        current_win, 
        current_buf,
        vim.fn.fnamemodify(vim.api.nvim_buf_get_name(current_buf), ':t'),
        navic.is_available(current_buf) and "✅ Yes" or "❌ No"
      )
      
      vim.notify(info, vim.log.levels.INFO, { title = "Tab Debug" })
    end, { desc = "Debug tab/window specific issues" })
    
    -- Global function to ensure navic works across tabs
    _G.ensure_navic_winbar = function()
      local navic = require("nvim-navic")
      local bufnr = vim.api.nvim_get_current_buf()
      
      if navic.is_available(bufnr) then
        local current_winbar = vim.api.nvim_buf_get_option(bufnr, 'winbar')
        if current_winbar == '' then
          local winbar_text = '%#NavicText#%{%v:lua.require("nvim-navic").get_location()%}'
          pcall(vim.api.nvim_buf_set_option, bufnr, 'winbar', winbar_text)
        end
      end
    end
    
    -- Auto-refresh when switching tabs/windows
    vim.api.nvim_create_autocmd({"TabEnter", "WinEnter", "BufWinEnter"}, {
      callback = function()
        vim.defer_fn(function()
          _G.ensure_navic_winbar()
        end, 100)
      end,
    })
    
  end,
  
  keys = {
    { "<leader>nb", function() 
        local navic = require("nvim-navic")
        local location = navic.get_location()
        if location ~= "" then
          vim.notify("Current location: " .. location, vim.log.levels.INFO)
        else
          vim.notify("No location available", vim.log.levels.WARN)
        end
      end, 
      desc = "Show navic breadcrumb" 
    },
    { "<leader>nw", function()
        local current_winbar = vim.api.nvim_get_option_value('winbar', { scope = 'local' })
        if current_winbar == '' then
          vim.opt_local.winbar = '%#NavicText#%{%v:lua.require("nvim-navic").get_location()%}'
          vim.notify("Navic winbar enabled", vim.log.levels.INFO)
        else
          vim.opt_local.winbar = ''
          vim.notify("Navic winbar disabled", vim.log.levels.INFO)
        end
      end, 
      desc = "Toggle navic winbar" 
    },
    { "<leader>nj", function()
        local navic = require("nvim-navic")
        local data = navic.get_data()
        if not data or #data == 0 then
          vim.notify("No navigation data available", vim.log.levels.WARN)
          return
        end
        
        local items = {}
        for i, item in ipairs(data) do
          table.insert(items, string.format("%d: %s %s", i, item.icon, item.name))
        end
        
        vim.ui.select(items, {
          prompt = "Jump to breadcrumb level:",
        }, function(choice, idx)
          if choice and idx then
            local target = data[idx]
            if target then
              vim.api.nvim_win_set_cursor(0, {target.scope.start.line + 1, target.scope.start.character})
              vim.notify("Jumped to: " .. target.name, vim.log.levels.INFO)
            end
          end
        end)
      end, 
      desc = "Jump to breadcrumb level" 
    },
  }
}