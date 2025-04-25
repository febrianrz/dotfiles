return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'github/copilot.vim' }, -- or zbirenbaum/copilot.lua
      { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    keys = {
      { '<leader>cc', '<cmd>CopilotChatToggle<cr>', desc = 'Toggle Copilot Chat' },
      { '<leader>cm', '<cmd>CopilotChatModels<cr>', desc = 'Toggle Copilot Chat' },
    },
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
