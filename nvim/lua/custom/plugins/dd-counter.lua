-- DD Counter Plugin
-- Count dd( occurrences in current file for Laravel debugging

return {
  'nvim-lua/plenary.nvim', -- Use existing plugin as base
  name = 'dd-counter',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  keys = {
    { '<leader>xd', function() require('custom.dd_counter').count_dd() end, desc = '[X] [D]D Count - Count dd() in current file' },
    { '<leader>xD', function() require('custom.dd_counter').find_all_dd() end, desc = '[X] [D]D Find - Find all dd() with Telescope' },
    { '<leader>xc', function() require('custom.dd_counter').clean_dd() end, desc = '[X] [C]lean - Remove all dd() from file' },
  },
  config = function()
    require('custom.dd_counter').setup()
  end,
}