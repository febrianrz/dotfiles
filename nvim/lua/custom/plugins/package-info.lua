return {
  "vuki656/package-info.nvim",
  dependencies = "MunifTanjim/nui.nvim",
  config = function()
    require("package-info").setup({
      colors = {
        up_to_date = "#3C4142", -- Text color for up to date dependency virtual text
        outdated = "#d19a66", -- Text color for outdated dependency virtual text
      },
      icons = {
        enable = true, -- Whether to display icons
        style = {
          up_to_date = "|  ", -- Icon for up to date dependencies
          outdated = "|  ", -- Icon for outdated dependencies
        },
      },
      autostart = true, -- Whether to autostart when `package.json` is opened
      hide_up_to_date = false, -- It hides up to date versions when displaying virtual text
      hide_unstable_versions = false, -- It hides unstable versions from version list e.g next-11.1.3-canary3
      -- Can be `npm`, `yarn`, or `pnpm`. Used for `delete`, `install` etc...
      -- The plugin will try to auto-detect the package manager based on
      -- `yarn.lock` or `package-lock.json`. If none are found it will use the
      -- provided one, if nothing is provided it will use `npm`
      package_manager = "npm"
    })
  end,
  ft = "json", -- Only load for package.json files
  keys = {
    {
      "<leader>ns",
      '<cmd>lua require("package-info").show()<cr>',
      desc = "Show dependency versions",
      ft = "json"
    },
    {
      "<leader>nc",
      '<cmd>lua require("package-info").hide()<cr>',
      desc = "Hide dependency versions",
      ft = "json"
    },
    {
      "<leader>nt",
      '<cmd>lua require("package-info").toggle()<cr>',
      desc = "Toggle dependency versions",
      ft = "json"
    },
    {
      "<leader>nu",
      '<cmd>lua require("package-info").update()<cr>',
      desc = "Update dependency on the line",
      ft = "json"
    },
    {
      "<leader>nd",
      '<cmd>lua require("package-info").delete()<cr>',
      desc = "Delete dependency on the line",
      ft = "json"
    },
    {
      "<leader>ni",
      '<cmd>lua require("package-info").install()<cr>',
      desc = "Install a new dependency with version",
      ft = "json"
    },
    {
      "<leader>np",
      '<cmd>lua require("package-info").change_version()<cr>',
      desc = "Install a different dependency version",
      ft = "json"
    }
  }
}