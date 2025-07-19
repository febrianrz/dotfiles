return {
  'kdheepak/lazygit.nvim',
  cmd = {
    'LazyGit',
    'LazyGitConfig',
    'LazyGitCurrentFile',
    'LazyGitFilter',
    'LazyGitFilterCurrentFile',
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  config = function()
    -- LazyGit configuration
    vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
    vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
    vim.g.lazygit_floating_window_border_chars = {'╭','─', '╮', '│', '╯','─', '╰', '│'} -- customize border chars
    vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
    vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed
    vim.g.lazygit_use_custom_config_file_path = 0 -- config file path is evaluated if this value is 1
    vim.g.lazygit_config_file_path = '' -- custom config file path
  end,
  keys = {
    { '<leader>gg', '<cmd>LazyGit<cr>', desc = '[G]it [G]ui - Open LazyGit' },
    { '<leader>gf', '<cmd>LazyGitCurrentFile<cr>', desc = '[G]it [F]ile - LazyGit current file' },
    { '<leader>gF', '<cmd>LazyGitFilter<cr>', desc = '[G]it [F]ilter - LazyGit with filter' },
    { '<leader>gG', '<cmd>LazyGitConfig<cr>', desc = '[G]it [G]lobal config - LazyGit config' },
  }
}
