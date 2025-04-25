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
        vim.keymap.set("n", "gr", vim.lsp.buf.definition, { buffer = bufnr })

        -- Kalau ada default on_attach dari LazyVim, pastikan tetap dipanggil
        if opts.on_attach then
          opts.on_attach(client, bufnr)
        end
      end

      opts.on_attach = on_attach

      opts.servers = {
        intelephense = {}, -- atau ganti ke intelephense di sini
      }

      return opts
    end,
  },
}
