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
      -- Basic DBUI Configuration
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath 'config' .. '/db_ui'
      vim.g.db_ui_winwidth = 50
      vim.g.db_ui_show_database_icon = true
      vim.g.db_ui_win_position = 'left'
      vim.g.db_ui_execute_on_save = true
      vim.g.db_ui_use_neovim_remote = 1
      vim.g.db_ui_result_height = 1

      -- Basic table helpers
      vim.g.db_ui_table_helpers = {
        mysql = {
          ['List'] = 'SELECT * FROM "{table}" LIMIT 200;',
          ['Describe'] = 'DESCRIBE "{table}";',
          ['Count'] = 'SELECT COUNT(*) FROM "{table}";',
        },
        postgresql = {
          ['List'] = 'SELECT * FROM "{table}" LIMIT 200;',
          ['Describe'] = '\\d "{table}";',
          ['Count'] = 'SELECT COUNT(*) FROM "{table}";',
        },
      }

      -- Database connections based on your .env file
      vim.g.dbs = {
        { name = 'Procurex PRD - Tender', url = 'postgres://devadmin:Z29KHEAVCsoe7h@192.168.203.204:5432/tender' },
        { name = 'Procurex PRD - Master Data', url = 'postgres://devadmin:Z29KHEAVCsoe7h@192.168.203.204:5432/masterdata' },
        { name = 'Procurex PRD - Vendor', url = 'postgres://devadmin:Z29KHEAVCsoe7h@192.168.203.204:5432/vendor' },
        { name = 'Procurex PRD - MRSR', url = 'postgres://devadmin:Z29KHEAVCsoe7h@192.168.203.204:5432/mrsr' },
        { name = 'Procurex PRD - SSO', url = 'postgres://devadmin:Z29KHEAVCsoe7h@192.168.203.204:5432/sso' },
        { name = 'Eproc PRD', url = 'postgres://eprocadmin:Procurement2021$@192.168.188.96:5432/eprocadmin' },
      }
    end,
    config = function()
      -- SQL completion setup
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'sql', 'mysql', 'plsql', 'pgsql' },
        callback = function()
          require('cmp').setup.buffer {
            sources = {
              { name = 'vim-dadbod-completion' },
              { name = 'buffer' },
              { name = 'path' },
            },
          }
        end,
      })

      -- Set nowrap for SQL result buffers
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'dbout' },
        callback = function()
          vim.wo.wrap = false
          vim.opt_local.wrap = false
        end,
      })
    end,
    keys = {
      -- Database UI
      { '<leader>db', '<cmd>tabnew<cr><cmd>DBUI<cr>', desc = '[D]atabase [B]rowser - Open DBUI in new tab' },
      { '<leader>da', '<cmd>DBUIAddConnection<cr>', desc = '[D]atabase [A]dd - Add DB connection' },
      { '<leader>df', '<cmd>DBUIFindBuffer<cr>', desc = '[D]atabase [F]ind - Find DB buffer' },
      { '<leader>dr', '<cmd>DBUIRenameBuffer<cr>', desc = '[D]atabase [R]ename - Rename DB buffer' },
      { '<leader>dq', '<cmd>DBUILastQueryInfo<cr>', desc = '[D]atabase [Q]uery - Last query info' },

      -- Execute Query
      { '<leader>de', '<cmd>%DB<cr>', desc = '[D]atabase [E]xecute - Execute query', ft = { 'sql', 'mysql', 'plsql' } },
      { '<C-CR>', '<cmd>%DB<cr>', desc = 'Execute query (Ctrl+Enter)', ft = { 'sql', 'mysql', 'plsql' } },
      
      -- Format SQL
      { '<leader>df', function() require('custom.plugins.nvim-dadbod').format_sql() end, desc = '[D]atabase [F]ormat - Format SQL query', ft = { 'sql', 'mysql', 'plsql' } },

      -- Laravel Artisan Database Commands
      { '<leader>dR', '<cmd>!php artisan migrate<cr>', desc = '[D]atabase [R]un - Run migrations' },
      { '<leader>dB', '<cmd>!php artisan migrate:rollback<cr>', desc = '[D]atabase [B]ack - Rollback migration' },
      { '<leader>dS', '<cmd>!php artisan db:seed<cr>', desc = '[D]atabase [S]eed - Run seeders' },
      { '<leader>dF', '<cmd>!php artisan migrate:fresh --seed<cr>', desc = '[D]atabase [F]resh - Fresh migrate with seed' },
      { '<leader>dC', '<cmd>!php artisan migrate:status<cr>', desc = '[D]atabase [C]heck - Migration status' },
    },
  },
}
