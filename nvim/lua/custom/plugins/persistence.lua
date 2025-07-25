return {
  "folke/persistence.nvim",
  event = "BufReadPre", -- this will only start session saving when an actual file was opened
  opts = {
    dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"), -- directory where session files are saved
    options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" }, -- sessionoptions used for saving
    pre_save = nil, -- a function to call before saving the session
    save_empty = false, -- don't save if there are no open file buffers
  },
  keys = {
    {
      "<leader>qs",
      function() require("persistence").load() end,
      desc = "Restore Session"
    },
    {
      "<leader>ql",
      function() require("persistence").load({ last = true }) end,
      desc = "Restore Last Session"
    },
    {
      "<leader>qd",
      function() require("persistence").stop() end,
      desc = "Don't Save Current Session"
    }
  }
}