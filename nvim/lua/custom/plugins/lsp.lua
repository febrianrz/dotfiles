return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    opts = function(_, opts)
      local on_attach = function(client, bufnr)
        -- keymap go to definition
        vim.keymap.set('n', 'gr', vim.lsp.buf.definition, { buffer = bufnr })

        -- Attach navic if available and client supports documentSymbolProvider
        if client.server_capabilities.documentSymbolProvider then
          local navic_ok, navic = pcall(require, "nvim-navic")
          if navic_ok then
            navic.attach(client, bufnr)
            vim.notify(string.format("✅ Navic attached to %s LSP for buffer %d", client.name, bufnr), vim.log.levels.INFO)
            
            -- Immediately try to set winbar after attachment
            vim.defer_fn(function()
              if vim.api.nvim_buf_is_valid(bufnr) and navic.is_available(bufnr) then
                local winbar_text = '%#NavicText#%{%v:lua.require("nvim-navic").get_location()%}'
                pcall(vim.api.nvim_buf_set_option, bufnr, 'winbar', winbar_text)
                vim.notify("✅ Winbar set from LSP on_attach", vim.log.levels.INFO)
              else
                vim.notify("⚠️ Navic still not available after attachment", vim.log.levels.WARN)
              end
            end, 1000)
          else
            vim.notify("❌ Failed to load navic module", vim.log.levels.ERROR)
          end
        else
          vim.notify(string.format("⚠️ %s LSP doesn't support documentSymbolProvider", client.name), vim.log.levels.WARN)
        end

        -- Kalau ada default on_attach dari LazyVim, pastikan tetap dipanggil
        if opts.on_attach then
          opts.on_attach(client, bufnr)
        end
      end

      opts.on_attach = on_attach

      -- opts.servers = {
      --   intelephense = {}, -- atau ganti ke intelephense di sini
      -- }
      opts.servers = {
        phpactor = {
          cmd = { 'phpactor', 'language-server' },
          filetypes = { 'php' },
          root_dir = require('lspconfig.util').root_pattern('composer.json', '.git'),
        },
      }

      return opts
    end,
  },
}
