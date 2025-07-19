-- Laravel Routes Plugin
-- Simple, effective Laravel route browser inspired by git changes

return {
  'nvim-telescope/telescope.nvim', -- Use existing plugin as base
  name = 'laravel-routes',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    { '<leader>ar', function() require('custom.laravel_routes_simple').route_picker() end, desc = '[A]rtisan [R]outes - Laravel Routes Browser' },
    { '<leader>aR', function() require('custom.laravel_routes_simple').route_list() end, desc = '[A]rtisan [R]outes List - Simple terminal output' },
    { '<leader>ad', function() require('custom.laravel_routes_simple').debug() end, desc = '[A]rtisan [D]ebug - Debug Laravel routes' },
  },
  config = function()
    require('custom.laravel_routes_simple').setup()
  end,
}