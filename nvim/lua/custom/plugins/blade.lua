return {
  {
    'jwalton512/vim-blade',
    ft = 'blade',
    config = function()
      -- Blade specific settings
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'blade',
        callback = function()
          vim.bo.commentstring = '{{-- %s --}}'
          vim.bo.suffixesadd = '.blade.php,.php'
        end,
      })
    end,
  },
  {
    'EmranMR/tree-sitter-blade',
    ft = 'blade',
    config = function()
      -- Register blade parser
      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
      parser_config.blade = {
        install_info = {
          url = 'https://github.com/EmranMR/tree-sitter-blade',
          files = { 'src/parser.c' },
          branch = 'main',
        },
        filetype = 'blade',
      }
      
      -- Set filetype for blade templates
      vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
        pattern = '*.blade.php',
        callback = function()
          vim.bo.filetype = 'blade'
        end,
      })
    end,
  },
  {
    'RicardoRamirezR/blade-nav.nvim',
    dependencies = {
      'hrsh7th/nvim-cmp',
    },
    ft = { 'blade', 'php' },
    opts = {
      close_tag_on_complete = true,
    },
    keys = {
      {
        '<leader>bc',
        function()
          require('blade-nav').goto_component()
        end,
        ft = 'blade',
        desc = '[B]lade [C]omponent - Go to component definition',
      },
      {
        '<leader>bv',
        function()
          require('blade-nav').goto_view()
        end,
        ft = 'blade',
        desc = '[B]lade [V]iew - Go to view file',
      },
    },
  },
}