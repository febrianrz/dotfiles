return {
  'stevearc/conform.nvim',
  opts = function(_, opts)
    opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
      javascript = { 'prettier' },
      typescriptreact = { 'prettier' },
      html = { 'prettier' },
      php = { 'php_cs_fixer', 'intelephense' },
      go = { 'gofmt' },
      sh = { 'shfmt' },
      lua = { 'stylua' },
    })

    -- Overwrite langsung, karena di versi baru ini function bukan table
    opts.format_on_save = {
      lsp_fallback = true,
      timeout_ms = 1000,
      stop_after_first = true,
    }
  end,
}

