return {
  {
    'datsfilipe/vesper.nvim',
    config = function()
      require('vesper').setup({
        transparent = true,
        italics = {
          comments = false,
          keywords = false,
          functions = false,
          strings = false,
          variables = false,
        },
        overrides = {
          Normal = { fg = '#c0c0c0' }, -- Light gray instead of white
          NormalFloat = { fg = '#c0c0c0' },
        },
      })
    end,
  },
}
