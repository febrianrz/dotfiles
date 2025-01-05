-- lua/plugins/notify.lua

return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  config = function()
    local notify = require("notify")

    -- Basic setup
    notify.setup({
      -- Minimum level to show
      level = "info",

      -- Animation style
      stages = "fade_in_slide_out",

      -- Default timeout for notifications
      timeout = 5000,

      -- Max number of notifications to show at once
      max_width = 50,
      max_height = nil,

      -- Icons for different levels
      icons = {
        ERROR = "",
        WARN = "",
        INFO = "",
        DEBUG = "",
        TRACE = "✎",
      },

      -- Background color (can be "dark" or "light")
      background_colour = "#000000",

      -- Minimum width for notification windows
      minimum_width = 50,

      -- Render style for notifications
      render = "default",

      -- Animation FPS
      fps = 30,

      -- Top down or bottom up
      top_down = true,
    })

    -- Make it default notification system
    vim.notify = notify

    -- Custom commands for testing notifications
    vim.api.nvim_create_user_command("NotifyTest", function()
      notify("This is a test notification", "info", {
        title = "Test Notification",
        timeout = 2000,
      })
    end, {})

    -- Utility function to show different notification levels
    local function test_notify()
      notify("This is an error", "error")
      notify("This is a warning", "warn")
      notify("This is an info", "info")
      notify("This is a debug message", "debug")
      notify("This is a trace message", "trace")
    end

    -- Create command to test all notification levels
    vim.api.nvim_create_user_command("NotifyTestAll", function()
      test_notify()
    end, {})

    -- Keymaps for testing (optional)
    vim.keymap.set("n", "<leader>nt", ":NotifyTest<CR>", { silent = true, desc = "Test Notification" })
    vim.keymap.set("n", "<leader>nta", ":NotifyTestAll<CR>", { silent = true, desc = "Test All Notifications" })

    -- History command
    vim.api.nvim_create_user_command("NotifyHistory", function()
      require("notify").history()
    end, {})

    -- Clear notifications command
    vim.api.nvim_create_user_command("NotifyClear", function()
      require("notify").dismiss({ silent = true, pending = true })
    end, {})

    -- Highlight groups (optional)
    vim.cmd([[
            highlight NotifyERRORBorder guifg=#8A1F1F
            highlight NotifyWARNBorder guifg=#79491D
            highlight NotifyINFOBorder guifg=#4F6752
            highlight NotifyDEBUGBorder guifg=#8B8B8B
            highlight NotifyTRACEBorder guifg=#4F3552
            highlight NotifyERRORIcon guifg=#F70067
            highlight NotifyWARNIcon guifg=#F79000
            highlight NotifyINFOIcon guifg=#A9FF68
            highlight NotifyDEBUGIcon guifg=#8B8B8B
            highlight NotifyTRACEIcon guifg=#D484FF
            highlight NotifyERRORTitle guifg=#F70067
            highlight NotifyWARNTitle guifg=#F79000
            highlight NotifyINFOTitle guifg=#A9FF68
            highlight NotifyDEBUGTitle guifg=#8B8B8B
            highlight NotifyTRACETitle guifg=#D484FF
        ]])
  end,
}
