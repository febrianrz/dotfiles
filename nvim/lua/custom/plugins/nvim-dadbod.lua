return {
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      'tpope/vim-dadbod',
      {
        'kristijanhusak/vim-dadbod-completion',
        ft = { 'sql', 'mysql', 'plsql', 'pgsql' },
      },
    },
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_auto_execute_table_helpers = 1
    end,
    config = function()
      -- Relative number
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'dbui',
        callback = function()
          vim.opt_local.relativenumber = true
        end,
      })

      -- Completion setup
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'sql', 'mysql', 'plsql', 'pgsql' },
        callback = function()
          require('cmp').setup.buffer {
            sources = {
              { name = 'vim-dadbod-completion' },
              { name = 'buffer' },
            },
          }
        end,
      })
    end,
    keys = {
      { '<leader>td', '<cmd>DBUIToggle<cr>', desc = 'DB UI Toggle' },
      { '<leader>ta', '<cmd>DBUIAddConnection<cr>', desc = 'DB UI Add Connection' },
    },
  },
}
