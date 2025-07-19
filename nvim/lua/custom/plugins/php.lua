return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        php = { { "pint", "php_cs_fixer" } },
        blade = { { "blade-formatter", "prettier" } },
      },
      formatters = {
        pint = {
          command = function()
            -- Check for local Laravel Pint first
            if vim.fn.filereadable('./vendor/bin/pint') == 1 then
              return './vendor/bin/pint'
            end
            -- Fallback to global pint
            return 'pint'
          end,
          args = { '$FILENAME' },
          stdin = false,
        },
        ['blade-formatter'] = {
          command = 'blade-formatter',
          args = { '--write', '$FILENAME' },
          stdin = false,
        },
      },
    },
  },
  {
    -- Laravel Pint installer for Mason
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "pint",
        "blade-formatter",
      })
    end,
  },
}
