return {
  {
    "github/copilot.vim",
    config = function()
      -- Disable default tab mapping to avoid conflicts
      vim.g.copilot_no_tab_map = true
      
      -- Custom keymaps for Copilot
      vim.keymap.set('i', '<C-l>', 'copilot#Accept("")', {
        expr = true,
        replace_keycodes = false,
        desc = 'Accept Copilot suggestion'
      })
      
      vim.keymap.set('i', '<C-;>', '<Plug>(copilot-next)', {
        desc = 'Next Copilot suggestion'
      })
      
      vim.keymap.set('i', '<C-,>', '<Plug>(copilot-previous)', {
        desc = 'Previous Copilot suggestion'
      })
      
      vim.keymap.set('i', '<C-\\>', '<Plug>(copilot-dismiss)', {
        desc = 'Dismiss Copilot suggestion'
      })
    end,
  },
}
