return {
  'adalessa/laravel.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'tpope/vim-dotenv',
    'MunifTanjim/nui.nvim',
    'nvimtools/none-ls.nvim',
    {
      'kevinhwang91/promise-async',
      lazy = true,
    },
  },
  cmd = { 'Artisan', 'Sail', 'MakeView', 'Composer' },
  keys = {
    { '<leader>aa', '<cmd>Artisan<cr>', desc = '[A]rtisan - Laravel Artisan' },
    -- Using new custom route picker
    -- { '<leader>ar', function() require('custom.laravel_routes').route_picker() end, desc = '[A]rtisan [R]outes - Laravel Routes Browser' },
    -- { '<leader>aR', '<cmd>!php -d error_reporting=0 artisan route:list<cr>', desc = '[A]rtisan [R]outes Simple - Terminal route list' },
    { '<leader>am', '<cmd>Artisan make<cr>', desc = '[A]rtisan [M]ake - Laravel Make' },
    { '<leader>ac', '<cmd>Composer<cr>', desc = '[A]rtisan [C]omposer - Composer' },
    { '<leader>as', '<cmd>Sail<cr>', desc = '[A]rtisan [S]ail - Laravel Sail' },
    { '<leader>av', '<cmd>MakeView<cr>', desc = '[A]rtisan [V]iew - Make View' },
  },
  event = { 'VeryLazy' },
  config = function()
    -- Only setup if in Laravel project
    if vim.fn.filereadable(vim.fn.getcwd() .. '/artisan') == 1 then
      require('laravel').setup({
        lsp_server = 'intelephense',
        features = {
          null_ls = {
            enable = false, -- We use conform.nvim instead
          },
          route_info = {
            enable = true,
            position = 'right',
            middlewares = true,
            method = true,
            uri = true,
          },
        },
        split = {
          size = 15,
          direction = 'horizontal',
        },
        bind_telescope = true,
      })
    end
  end,
}