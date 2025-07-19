return {
  "folke/flash.nvim",
  event = "VeryLazy",
  opts = {
    search = {
      multi_window = true,
      forward = true,
      wrap = true,
      mode = "exact", -- exact|search|fuzzy
    },
    jump = {
      jumplist = true,
      pos = "start", -- start|end|range
      history = false,
      register = false,
      nohlsearch = false,
      autojump = false,
    },
    label = {
      uppercase = true,
      exclude = "",
      current = true,
      after = true, -- show the label after the match
      before = false, -- show the label before the match
      style = "overlay", -- eol|overlay|right_align|inline
      reuse = "lowercase", -- lowercase|all|none
      distance = true,
      min_pattern_length = 0,
      rainbow = {
        enabled = false,
        shade = 5,
      },
      format = function(opts)
        return { { opts.match.label, opts.hl_group } }
      end,
    },
    highlight = {
      backdrop = true,
      matches = true,
      priority = 5000,
      groups = {
        match = "FlashMatch",
        current = "FlashCurrent",
        backdrop = "FlashBackdrop",
        label = "FlashLabel"
      },
    },
    modes = {
      search = {
        enabled = true,
        highlight = { backdrop = false },
        jump = { history = true, register = true, nohlsearch = true },
        search = {
          mode = "search",
          max_length = false,
          multi_window = true,
          forward = true,
          wrap = true,
          incremental = false,
        },
      },
      char = {
        enabled = true,
        config = function(opts)
          opts.autohide = opts.autohide == nil and (vim.fn.mode(true):find("no") and vim.v.operator == "y")
          opts.jump_labels = opts.jump_labels
            and vim.v.count == 0
            and vim.fn.reg_executing() == ""
            and vim.fn.reg_recording() == ""
        end,
        autohide = false,
        jump_labels = false,
        multi_line = true,
        label = { exclude = "hjkliardc" },
        keys = { "f", "F", "t", "T", ";" },
        char_actions = function(motion)
          return {
            [";"] = "next", -- set to `right` to always go right
            [","] = "prev", -- set to `left` to always go left
          }
        end,
        search = { wrap = false },
        highlight = { backdrop = true },
        jump = { register = false },
      },
      treesitter = {
        labels = "abcdefghijklmnopqrstuvwxyz",
        jump = { pos = "range" },
        search = { incremental = false },
        label = { before = true, after = true, style = "inline" },
        highlight = {
          backdrop = false,
          matches = false,
        },
      },
      treesitter_search = {
        jump = { pos = "range" },
        search = { multi_window = true, wrap = true, incremental = false },
        remote_op = { restore = true },
        label = { before = false, after = true, style = "inline" },
      },
    },
    prompt = {
      enabled = true,
      prefix = { { "⚡", "FlashPromptIcon" } },
      win_config = {
        relative = "editor",
        width = 1, -- when <=1 it's a percentage of the editor width
        height = 1,
        row = -1, -- when negative it's an offset from the bottom
        col = 0, -- when negative it's an offset from the right
        zindex = 1000,
      },
    },
    remote = {
      remote_op = { restore = true, motion = true },
    }
  },
  keys = {
    {
      "<leader>j",
      mode = { "n", "x", "o" },
      function()
        require("flash").jump()
      end,
      desc = "Flash Jump"
    },
    {
      "<leader>jt",
      mode = { "n", "x", "o" },
      function()
        require("flash").treesitter()
      end,
      desc = "Flash Treesitter"
    },
    {
      "r",
      mode = "o",
      function()
        require("flash").remote()
      end,
      desc = "Remote Flash"
    },
    {
      "R",
      mode = { "o", "x" },
      function()
        require("flash").treesitter_search()
      end,
      desc = "Flash Treesitter Search"
    },
    {
      "<c-s>",
      mode = { "c" },
      function()
        require("flash").toggle()
      end,
      desc = "Toggle Flash Search"
    },
  },
  config = function(_, opts)
    require("flash").setup(opts)
    
    -- Custom highlights
    vim.api.nvim_set_hl(0, "FlashMatch", { fg = "#000000", bg = "#ffff00", bold = true })
    vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#000000", bg = "#00ff00", bold = true })
    vim.api.nvim_set_hl(0, "FlashCurrent", { fg = "#000000", bg = "#ff6600", bold = true })
    vim.api.nvim_set_hl(0, "FlashBackdrop", { fg = "#777777" })
  end
}