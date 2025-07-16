return {
  'ThePrimeagen/harpoon',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('harpoon').setup()
  end,
  keys = {
    {
      '<leader>a',
      function()
        require('harpoon.mark').add_file()
      end,
      desc = 'Harpoon: Mark file',
    },
    {
      '<C-e>',
      function()
        require('harpoon.ui').toggle_quick_menu()
      end,
      desc = 'Harpoon: Toggle UI',
    },
    {
      '<leader>d',
      function()
        require('harpoon.mark').rm_file()
      end,
      desc = 'Harpoon: Remove file',
    },
    {
      '<leader>1',
      function()
        require('harpoon.ui').nav_file(1)
      end,
      desc = 'Harpoon: Go to file 1',
    },
    {
      '<leader>2',
      function()
        require('harpoon.ui').nav_file(2)
      end,
      desc = 'Harpoon: Go to file 2',
    },
    {
      '<leader>3',
      function()
        require('harpoon.ui').nav_file(3)
      end,
      desc = 'Harpoon: Go to file 3',
    },
    {
      '<leader>4',
      function()
        require('harpoon.ui').nav_file(4)
      end,
      desc = 'Harpoon: Go to file 4',
    },
  },
}
