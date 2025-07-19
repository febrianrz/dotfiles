return {
  "smjonas/inc-rename.nvim",
  config = function()
    require("inc-rename").setup({
      cmd_name = "IncRename", -- the name of the command
      hl_group = "Substitute", -- the highlight group used for highlighting the identifier
      preview_empty_name = false, -- whether an empty new name should be previewed
      show_message = true, -- whether to display a message when renaming
      input_buffer_type = nil, -- the type of the external input buffer to use (the default is to use a floating window)
      post_hook = nil, -- callback to run after renaming, receives the result table (from LSP handler) as an argument
    })
  end,
  keys = {
    {
      "<leader>rN",
      function()
        return ":IncRename " .. vim.fn.expand("<cword>")
      end,
      expr = true,
      desc = "Rename with live preview (inc-rename)"
    },
  }
}